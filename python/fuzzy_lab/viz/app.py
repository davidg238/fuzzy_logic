"""Plotly Dash app that visualises a running FuzzyModel.

Per-variable panel layout (inputs):
  [var name | term-state list]   ← 2-column header above the graph
  [figure]                       ← Plotly legend hidden; states live in header
  [slider]

Outputs are the mirror image: figure on top, 2-column footer below.

Top of page: file picker dropdown — selecting a different .fcl hot-
swaps the engine's model (POST /model). The topology store updates,
which causes the inputs/outputs panels to rebuild in place; no
browser reload required. Pattern-matching callbacks pick up the new
var names automatically.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

import dash
from dash import MATCH, Input, Output, State, dcc, html

from fuzzy_lab.fcl2json.parser import parse_fcl
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
TOP_BAR = {"display": "flex", "alignItems": "center", "gap": "16px",
           "padding": "8px 0"}
ERROR_VISIBLE = {"color": "red", "fontWeight": "bold",
                 "padding": "6px 0", "whiteSpace": "pre-wrap"}
ERROR_HIDDEN = {"display": "none"}


@dataclass
class AppConfig:
    base_url: str
    fcl_dir: Path
    poll_ms: int = 500


def build_app(config: AppConfig, model: Model, initial_state: dict,
              initial_topology: dict) -> dash.Dash:
    app = dash.Dash(__name__, suppress_callback_exceptions=True)

    fcl_options = _list_fcl_files(config.fcl_dir)

    app.layout = html.Div([
        html.Div([
            dcc.Dropdown(
                id="fcl-picker",
                options=fcl_options,
                placeholder="Load model from .fcl…",
                clearable=False,
                style={"flex": "0 0 320px"},
            ),
            html.Div(id="conn-status", children="connected",
                     style={"color": "green", "fontStyle": "italic"}),
        ], style=TOP_BAR),

        html.Div(id="error-text", style=ERROR_HIDDEN),

        dcc.Interval(id="tick", interval=config.poll_ms),
        dcc.Store(id="state-store", data=initial_state),
        dcc.Store(id="topology-store", data=initial_topology),
        dcc.Store(id="push-ack", data=0),

        html.H3("Inputs"),
        html.Div(id="inputs-row", style=INPUTS_ROW),

        html.H3("Rules"),
        html.Ul(id="rules-list"),

        html.H3("Outputs"),
        html.Div(id="outputs-row", style=OUTPUTS_ROW),
    ])

    _register_callbacks(app, config)
    return app


def _list_fcl_files(fcl_dir: Path) -> list[dict]:
    if not fcl_dir.is_dir():
        return []
    return [{"label": p.name, "value": str(p)}
            for p in sorted(fcl_dir.glob("*.fcl"))]


def _header_row(legend_kind: str, v: FuzzyVar) -> html.Div:
    return html.Div([
        html.Div(v.name, style=HEADER_NAME),
        html.Div(id={"type": legend_kind, "var": v.name}, style=HEADER_LEGEND),
    ], style=HEADER_ROW)


def _input_panel(v_dict: dict, vstate: dict) -> html.Div:
    v = FuzzyVar.from_dict(v_dict)
    return html.Div([
        _header_row("in-legend", v),
        dcc.Graph(id={"type": "in-fig", "var": v.name},
                  figure=membership_figure(v, vstate)),
        html.Div(
            dcc.Slider(
                id={"type": "in-slider", "var": v.name},
                min=min(t.a for t in v.terms),
                max=max(t.d for t in v.terms),
                step=0.1,
                value=vstate.get("crisp", 0.0),
                marks={int(m): str(int(m)) for m in _slider_mark_ints(v)},
                tooltip={"placement": "bottom", "always_visible": True},
                updatemode="drag",
                allow_direct_input=False,
            ),
            style=SLIDER_WRAP,
        ),
    ], style=PANEL)


def _output_panel(v_dict: dict, vstate: dict) -> html.Div:
    v = FuzzyVar.from_dict(v_dict)
    return html.Div([
        dcc.Graph(id={"type": "out-fig", "var": v.name},
                  figure=output_figure(v, vstate)),
        _header_row("out-legend", v),
    ], style=PANEL)


def _var_state(state: dict, kind: str, name: str) -> dict:
    for v in (state or {}).get(kind, []):
        if v["name"] == name:
            return v
    return {"name": name, "crisp": 0.0, "terms": []}


def _find_var_dict(topology: dict, kind: str, name: str) -> dict | None:
    for v_dict in (topology or {}).get(kind, []):
        if v_dict["name"] == name:
            return v_dict
    return None


def _slider_mark_ints(v: FuzzyVar, target: int = 10) -> list[int]:
    lo = int(min(t.a for t in v.terms))
    hi = int(max(t.d for t in v.terms))
    span = hi - lo
    if span <= 0:
        return [lo]
    stride = max(1, span // target)
    marks = list(range(lo, hi + 1, stride))
    if marks[-1] != hi:
        marks.append(hi)
    return marks


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


def _register_callbacks(app: dash.Dash, config: AppConfig) -> None:
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
        for r in (state or {}).get("rules", []):
            style = {"fontWeight": "bold"} if r.get("fired") else {}
            items.append(html.Li(r.get("name", "?"), style=style))
        return items

    @app.callback(
        Output("inputs-row", "children"),
        Output("outputs-row", "children"),
        Input("topology-store", "data"),
        State("state-store", "data"),
    )
    def rebuild_panels(topology, state):
        if not topology:
            return [], []
        return (
            [_input_panel(v, _var_state(state, "inputs", v["name"]))
             for v in topology.get("inputs", [])],
            [_output_panel(v, _var_state(state, "outputs", v["name"]))
             for v in topology.get("outputs", [])],
        )

    @app.callback(
        Output({"type": "in-legend", "var": MATCH}, "children"),
        Input("state-store", "data"),
        State({"type": "in-legend", "var": MATCH}, "id"),
    )
    def render_in_legend(state, comp_id):
        return _legend_children(_var_state(state, "inputs", comp_id["var"]), "crisp")

    @app.callback(
        Output({"type": "out-legend", "var": MATCH}, "children"),
        Input("state-store", "data"),
        State({"type": "out-legend", "var": MATCH}, "id"),
    )
    def render_out_legend(state, comp_id):
        return _legend_children(_var_state(state, "outputs", comp_id["var"]), "centroid")

    @app.callback(
        Output({"type": "in-fig", "var": MATCH}, "figure"),
        Input("state-store", "data"),
        State({"type": "in-fig", "var": MATCH}, "id"),
        State("topology-store", "data"),
    )
    def update_in_fig(state, comp_id, topology):
        v_dict = _find_var_dict(topology, "inputs", comp_id["var"])
        if v_dict is None:
            return dash.no_update
        return membership_figure(FuzzyVar.from_dict(v_dict),
                                 _var_state(state, "inputs", comp_id["var"]))

    @app.callback(
        Output({"type": "out-fig", "var": MATCH}, "figure"),
        Input("state-store", "data"),
        State({"type": "out-fig", "var": MATCH}, "id"),
        State("topology-store", "data"),
    )
    def update_out_fig(state, comp_id, topology):
        v_dict = _find_var_dict(topology, "outputs", comp_id["var"])
        if v_dict is None:
            return dash.no_update
        return output_figure(FuzzyVar.from_dict(v_dict),
                             _var_state(state, "outputs", comp_id["var"]))

    @app.callback(
        Output("push-ack", "data", allow_duplicate=True),
        Input({"type": "in-slider", "var": MATCH}, "value"),
        State({"type": "in-slider", "var": MATCH}, "id"),
        prevent_initial_call=True,
    )
    def push_input(value, comp_id):
        try:
            client.post_input(comp_id["var"], float(value))
        except Exception:
            pass
        return dash.no_update

    @app.callback(
        Output("topology-store", "data"),
        Output("error-text", "children"),
        Output("error-text", "style"),
        Input("fcl-picker", "value"),
        prevent_initial_call=True,
    )
    def on_pick(fcl_path):
        if not fcl_path:
            return dash.no_update, "", ERROR_HIDDEN
        fname = Path(fcl_path).name
        try:
            text = Path(fcl_path).read_text()
            new_model = parse_fcl(text)
            client.post_model(new_model.to_dict())
            new_topology = client.get_model()
            return new_topology, "", ERROR_HIDDEN
        except Exception as exc:
            msg = f"Error loading {fname}: {type(exc).__name__}: {exc}"
            return dash.no_update, msg, ERROR_VISIBLE
