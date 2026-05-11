"""Plotly figure builders. All figures are pure functions of (FuzzyVar, var-state)."""

from __future__ import annotations

import plotly.colors as pc
import plotly.graph_objects as go

from fuzzy_lab.schema import FuzzyVar


_PALETTE = pc.qualitative.Plotly


def term_color(idx: int) -> str:
    """Color assigned to the term at position `idx` in declaration order."""
    return _PALETTE[idx % len(_PALETTE)]


def membership_figure(var: FuzzyVar, state: dict) -> go.Figure:
    """Membership polygons for one input. Crisp value rendered as a vertical line."""
    fig = go.Figure()
    for i, term in enumerate(var.terms):
        pertinence = next((t["pertinence"] for t in state["terms"] if t["name"] == term.name), 0.0)
        color = term_color(i)
        fig.add_trace(go.Scatter(
            x=[term.a, term.b, term.c, term.d],
            y=[0, 1, 1, 0],
            mode="lines",
            name=f"{term.name} ({pertinence:.2f})",
            line=dict(color=color),
            fillcolor=color,
            fill="toself",
            opacity=0.3 if pertinence == 0 else 0.7,
        ))
    crisp = state.get("crisp", 0.0)
    fig.add_trace(go.Scatter(
        x=[crisp, crisp], y=[0, 1],
        mode="lines",
        name=f"crisp = {crisp:.2f}",
        line=dict(dash="dash", width=2, color="#555"),
    ))
    fig.update_layout(height=260, margin=dict(l=40, r=10, t=10, b=30),
                      yaxis=dict(range=[0, 1.05]), showlegend=False)
    return fig


def output_figure(var: FuzzyVar, state: dict) -> go.Figure:
    """Output figure: stacked term polygons, truncated by pertinence; centroid line."""
    fig = go.Figure()
    for i, term in enumerate(var.terms):
        pertinence = next((t["pertinence"] for t in state["terms"] if t["name"] == term.name), 0.0)
        color = term_color(i)
        fig.add_trace(go.Scatter(
            x=[term.a, term.b, term.c, term.d],
            y=[0, 1, 1, 0],
            mode="lines",
            name=f"{term.name}",
            line=dict(color=color, width=1),
            fillcolor=color,
            fill="toself",
            opacity=0.2,
        ))
        if pertinence > 0:
            xL = term.a + pertinence * (term.b - term.a)
            xR = term.d - pertinence * (term.d - term.c)
            fig.add_trace(go.Scatter(
                x=[term.a, xL, xR, term.d],
                y=[0, pertinence, pertinence, 0],
                mode="lines",
                name=f"{term.name} @ h={pertinence:.2f}",
                line=dict(color=color),
                fillcolor=color,
                fill="toself",
                opacity=0.6,
            ))
    crisp = state.get("crisp", 0.0)
    fig.add_trace(go.Scatter(
        x=[crisp, crisp], y=[0, 1],
        mode="lines",
        name=f"centroid = {crisp:.2f}",
        line=dict(dash="dash", width=2, color="red"),
    ))
    fig.update_layout(height=260, margin=dict(l=40, r=10, t=10, b=30),
                      yaxis=dict(range=[0, 1.05]), showlegend=False)
    return fig
