"""Plotly Dash app that visualises a running FuzzyModel (view-only).

Layout (top to bottom):
  - Header: model name + defuzz method + connection status
  - Inputs row: one membership figure per input (no slider)
  - Rules list: one bullet per rule; fired rules bold
  - Outputs row: one output figure per output
"""

from __future__ import annotations

from dataclasses import dataclass

import dash
from dash import Input, Output, dcc, html

from fuzzy_lab.schema import Model
from fuzzy_lab.viz.plots import membership_figure, output_figure
from fuzzy_lab.viz.rpc import FuzzyClient


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

        html.H3("Inputs"),
        html.Div(id="inputs-row", children=[
            html.Div([
                dcc.Graph(id={"type": "in-fig", "var": v.name},
                          figure=membership_figure(v, _var_state(initial_state, "inputs", v.name))),
            ], style={"width": "32%", "display": "inline-block"})
            for v in model.inputs
        ]),

        html.H3("Rules"),
        html.Ul(id="rules-list"),

        html.H3("Outputs"),
        html.Div(id="outputs-row", children=[
            html.Div([
                dcc.Graph(id={"type": "out-fig", "var": v.name},
                          figure=output_figure(v, _var_state(initial_state, "outputs", v.name))),
            ], style={"width": "32%", "display": "inline-block"})
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

    for v in model.outputs:
        @app.callback(
            Output({"type": "out-fig", "var": v.name}, "figure"),
            Input("state-store", "data"),
        )
        def update_output(state, _v=v):
            return output_figure(_v, _var_state(state, "outputs", _v.name))
