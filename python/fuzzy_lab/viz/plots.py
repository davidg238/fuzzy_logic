"""Plotly figure builders. All figures are pure functions of (FuzzyVar, var-state)."""

from __future__ import annotations

import plotly.graph_objects as go

from fuzzy_lab.schema import FuzzyVar


def membership_figure(var: FuzzyVar, state: dict) -> go.Figure:
    """Membership polygons for one input. Crisp value rendered as a vertical line."""
    fig = go.Figure()
    for term in var.terms:
        pertinence = next((t["pertinence"] for t in state["terms"] if t["name"] == term.name), 0.0)
        fig.add_trace(go.Scatter(
            x=[term.a, term.b, term.c, term.d],
            y=[0, 1, 1, 0],
            mode="lines",
            name=f"{term.name} ({pertinence:.2f})",
            fill="toself",
            opacity=0.3 if pertinence == 0 else 0.7,
        ))
    crisp = state.get("crisp", 0.0)
    fig.add_trace(go.Scatter(
        x=[crisp, crisp], y=[0, 1],
        mode="lines",
        name=f"crisp = {crisp:.2f}",
        line=dict(dash="dash", width=2),
    ))
    fig.update_layout(height=260, margin=dict(l=40, r=10, t=10, b=30),
                      yaxis=dict(range=[0, 1.05]))
    return fig


def output_figure(var: FuzzyVar, state: dict) -> go.Figure:
    """Output figure: stacked term polygons, truncated by pertinence; centroid line."""
    fig = go.Figure()
    for term in var.terms:
        pertinence = next((t["pertinence"] for t in state["terms"] if t["name"] == term.name), 0.0)
        fig.add_trace(go.Scatter(
            x=[term.a, term.b, term.c, term.d],
            y=[0, 1, 1, 0],
            mode="lines",
            name=f"{term.name}",
            fill="toself",
            opacity=0.2,
            line=dict(width=1),
        ))
        if pertinence > 0:
            xL = term.a + pertinence * (term.b - term.a)
            xR = term.d - pertinence * (term.d - term.c)
            fig.add_trace(go.Scatter(
                x=[term.a, xL, xR, term.d],
                y=[0, pertinence, pertinence, 0],
                mode="lines",
                name=f"{term.name} @ h={pertinence:.2f}",
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
                      yaxis=dict(range=[0, 1.05]))
    return fig
