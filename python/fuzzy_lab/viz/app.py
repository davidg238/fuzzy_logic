"""Plotly Dash app that visualises a running FuzzyModel.

Layout (top to bottom):
  - Header: model name + defuzz method + connection status
  - Inputs row: variable name above each panel; figure; slider
  - Rules list: one bullet per rule; fired rules bold
  - Outputs row: figure on top, variable name below each panel
"""

from __future__ import annotations

from dataclasses import dataclass

import dash
from dash import Input, Output, dcc, html

from fuzzy_lab.schema import FuzzyVar, Model
from fuzzy_lab.viz.plots import membership_figure, output_figure
from fuzzy_lab.viz.rpc import FuzzyClient


CENTER_LABEL = {"textAlign": "center", "margin": "4px 0", "fontWeight": "bold"}
PANEL = {"width": "32%", "display": "inline-block",
         "verticalAlign": "top", "padding": "0 8px"}
SLIDER_WRAP = {"paddingLeft": "40px", "paddingRight": "10px"}


@dataclass
class AppConfig:
    base_url: str
    poll_ms: int = 500


def build_app(config: AppConfig, model: Model, initial_state: dict) -> dash.Dash:
    app = dash.Dash(__name__, suppress_callback_exceptions=True)

    app.layout = html.Div([
        html.H2(f"{model.name}  (defuzz: {model.defuzz_method})"),
        html.Div(id="conn-status", children="connected",
                 style={"color": "green", "fontStyle": "italic"}),

        dcc.Interval(id="tick", interval=config.poll_ms),
        dcc.Store(id="state-store", data=initial_state),
        dcc.Store(id="push-ack", data=0),

        html.H3("Inputs"),
        html.Div(id="inputs-row", children=[
            html.Div([
                html.Div(v.name, style=CENTER_LABEL),
                dcc.Graph(id={"type": "in-fig", "var": v.name},
                          figure=membership_figure(v, _var_state(initial_state, "inputs", v.name))),
                html.Div(
                    dcc.Slider(
                        id={"type": "in-slider", "var": v.name},
                        min=min(t.a for t in v.terms),
                        max=max(t.d for t in v.terms),
                        step=0.1,
                        value=_var_state(initial_state, "inputs", v.name).get("crisp", 0.0),
                        marks={int(m): str(int(m)) for m in _slider_mark_ints(v)},
                        tooltip={"placement": "bottom", "always_visible": True},
                        updatemode="drag",
                    ),
                    style=SLIDER_WRAP,
                ),
            ], style=PANEL)
            for v in model.inputs
        ]),

        html.H3("Rules"),
        html.Ul(id="rules-list"),

        html.H3("Outputs"),
        html.Div(id="outputs-row", children=[
            html.Div([
                dcc.Graph(id={"type": "out-fig", "var": v.name},
                          figure=output_figure(v, _var_state(initial_state, "outputs", v.name))),
                html.Div(v.name, style=CENTER_LABEL),
            ], style=PANEL)
            for v in model.outputs
        ]),
    ])

    _register_callbacks(app, config, model)
    return app


def _var_state(state: dict, kind: str, name: str) -> dict:
    for v in state.get(kind, []):
        if v["name"] == name:
            return v
    return {"name": name, "crisp": 0.0, "terms": []}


def _slider_mark_ints(v: FuzzyVar) -> list[int]:
    lo = min(t.a for t in v.terms)
    hi = max(t.d for t in v.terms)
    return list(range(int(lo), int(hi) + 1))


def _register_callbacks(app: dash.Dash, config: AppConfig, model: Model) -> None:
    client = FuzzyClient(config.base_url)

    @app.callback(
        Output("state-store", "data"),
        Output("conn-status", "children"),
        Output("conn-status", "style"),
        Input("tick", "n_intervals"),
    )
    def poll_state(_n):
        try:
            state = client.get_state()
        except Exception as exc:
            return dash.no_update, f"disconnected: {exc}", {"color": "red"}
        return state, "connected", {"color": "green"}

    @app.callback(
        Output("rules-list", "children"),
        Input("state-store", "data"),
    )
    def render_rules(state):
        items = []
        for r in state.get("rules", []):
            style = {"fontWeight": "bold"} if r.get("fired") else {}
            items.append(html.Li(r.get("name", "?"), style=style))
        return items

    for v in model.inputs:
        @app.callback(
            Output({"type": "in-fig", "var": v.name}, "figure"),
            Input("state-store", "data"),
        )
        def update_input(state, _v=v):
            return membership_figure(_v, _var_state(state, "inputs", _v.name))

        @app.callback(
            Output("push-ack", "data", allow_duplicate=True),
            Input({"type": "in-slider", "var": v.name}, "value"),
            prevent_initial_call=True,
        )
        def push_input(value, _v=v):
            try:
                client.post_input(_v.name, float(value))
            except Exception:
                pass
            return dash.no_update

    for v in model.outputs:
        @app.callback(
            Output({"type": "out-fig", "var": v.name}, "figure"),
            Input("state-store", "data"),
        )
        def update_output(state, _v=v):
            return output_figure(_v, _var_state(state, "outputs", _v.name))
