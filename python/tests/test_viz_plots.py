"""Tests for fuzzy_lab.viz.plots."""

from fuzzy_lab.schema import Model
from fuzzy_lab.viz.plots import membership_figure, output_figure


def test_membership_figure_has_one_trace_per_term(sample_tipper_dict):
    model = Model.from_dict(sample_tipper_dict)
    state = {
        "inputs": [{"name": "service", "crisp": 6.0,
                    "terms": [{"name": "poor", "pertinence": 0.0},
                              {"name": "good", "pertinence": 0.7},
                              {"name": "excellent", "pertinence": 0.0}]}],
        "outputs": [], "rules": [],
    }
    fig = membership_figure(model.inputs[0], state["inputs"][0])
    # 3 term polygons + 1 vertical crisp line == 4 traces
    assert len(fig.data) == 4


def test_output_figure_has_centroid_marker(sample_tipper_dict):
    model = Model.from_dict(sample_tipper_dict)
    state = {
        "inputs": [], "rules": [],
        "outputs": [{"name": "tip", "crisp": 17.5,
                     "terms": [{"name": "cheap", "pertinence": 0.0},
                               {"name": "average", "pertinence": 0.5}]}],
    }
    fig = output_figure(model.outputs[0], state["outputs"][0])
    centroid_traces = [t for t in fig.data if "centroid" in (t.name or "").lower()]
    assert centroid_traces, "expected a centroid annotation/trace in the output figure"
