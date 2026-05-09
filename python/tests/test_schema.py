import json
from fuzzy_lab.schema import Model


def test_round_trip(sample_tipper_dict):
    model = Model.from_dict(sample_tipper_dict)
    assert model.name == "tipper"
    assert model.defuzz_method == "COG"
    assert len(model.inputs) == 1
    assert model.inputs[0].name == "service"
    assert len(model.inputs[0].terms) == 3
    assert model.inputs[0].terms[0].name == "poor"
    assert len(model.rules) == 1
    assert model.rules[0].weight == 1.0
    # Round-trip — to_dict produces the same shape.
    assert model.to_dict() == sample_tipper_dict


def test_json_round_trip(sample_tipper_dict, tmp_path):
    path = tmp_path / "tipper.json"
    path.write_text(json.dumps(sample_tipper_dict))
    model = Model.from_json_file(path)
    out = tmp_path / "tipper-out.json"
    model.to_json_file(out)
    assert json.loads(out.read_text()) == sample_tipper_dict
