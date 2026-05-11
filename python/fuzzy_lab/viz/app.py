"""Plotly Dash app that visualises a running FuzzyModel.

Per-variable panel layout (inputs):
  [var name | term-state list]   ← 2-column header above the graph
  [figure]                       ← Plotly legend hidden; states live in header
  [slider]

Outputs are the mirror image: figure on top, 2-column footer below.
"""

from __future__ import annotations

from dataclasses import dataclass

import dash
from dash import MATCH, Input, Output, dcc, html

from fuzzy_lab.schema import FuzzyVar, Model
from fuzzy_lab.viz.plots import membership_figure, output_figure, term_color
from fuzzy_lab.viz.rpc import FuzzyClient


PANEL = {"flex": "0 0 32%", "padding": "0 8px",
         "display": "flex", "flexDirection": "column"}
INPUTS_ROW = {"display": "flex", "alignItems": "flex-end",
              "flexWrap": "wrap"}
OUTPUTS_ROW = {"display": "flex", "alignItems": "flex-start",
               "flexWrap": "wrap"}
SLIDER_WRAP = {"paddingLeft": "40px", "paddingRight": "10px"}
HEADER_ROW = {"display": "flex", "alignItems": "center",
              "justifyContent": "center", "gap": "16px",
              "padding": "4px 40px 4px 40px"}
HEADER_NAME = {"flex": "0 0 auto", "fontWeight": "bold",
               "fontSize": "16px", "textAlign": "center"}
HEADER_LEGEND = {"flex": "0 1 auto", "fontSize": "16px",
                 "lineHeight": "1.3", "textAlign": "left"}


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
        html.Div(id="inputs-row", style=INPUTS_ROW, children=[
            html.Div([
                _header_row("in-legend", v),
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
                        allow_direct_input=False,
                    ),
                    style=SLIDER_WRAP,
                ),
            ], style=PANEL)
            for v in model.inputs
        ]),

        html.H3("Rules"),
        html.Ul(id="rules-list"),

        html.H3("Outputs"),
        html.Div(id="outputs-row", style=OUTPUTS_ROW, children=[
            html.Div([
                dcc.Graph(id={"type": "out-fig", "var": v.name},
                          figure=output_figure(v, _var_state(initial_state, "outputs", v.name))),
                _header_row("out-legend", v),
            ], style=PANEL)
            for v in model.outputs
        ]),
    ])

    _register_callbacks(app, config, model)
    return app


def _header_row(legend_kind: str, v: FuzzyVar) -> html.Div:
    """2-column [var-name | term-state list] row used above inputs / below outputs."""
    return html.Div([
        html.Div(v.name, style=HEADER_NAME),
        html.Div(id={"type": legend_kind, "var": v.name}, style=HEADER_LEGEND),
    ], style=HEADER_ROW)


def _var_state(state: dict, kind: str, name: str) -> dict:
    for v in state.get(kind, []):
        if v["name"] == name:
            return v
    return {"name": name, "crisp": 0.0, "terms": []}


def _slider_mark_ints(v: FuzzyVar) -> list[int]:
    lo = min(t.a for t in v.terms)
    hi = max(t.d for t in v.terms)
    return list(range(int(lo), int(hi) + 1))


def _legend_children(vstate: dict, crisp_label: str) -> list:
    rows = []
    for i, t in enumerate(vstate.get("terms", [])):
        rows.append(html.Div([
            html.Span(t["name"], style={"color": term_color(i), "fontWeight": "bold"}),
            html.Span(f" ({t['pertinence']:.2f})"),
        ]))
    rows.append(html.Div(f"{crisp_label} = {vstate.get('crisp', 0.0):.2f}",
                         style={"fontStyle": "italic"}))
    return rows


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

    @app.callback(
        Output({"type": "in-legend", "var": MATCH}, "children"),
        Input("state-store", "data"),
        Input({"type": "in-legend", "var": MATCH}, "id"),
    )
    def render_in_legend(state, comp_id):
        return _legend_children(_var_state(state, "inputs", comp_id["var"]), "crisp")

    @app.callback(
        Output({"type": "out-legend", "var": MATCH}, "children"),
        Input("state-store", "data"),
        Input({"type": "out-legend", "var": MATCH}, "id"),
    )
    def render_out_legend(state, comp_id):
        return _legend_children(_var_state(state, "outputs", comp_id["var"]), "centroid")

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
