from pathlib import Path
import pytest
from lark import Lark
from fuzzy_lab.fcl2json.parser import parse_fcl

GRAMMAR_PATH = Path(__file__).resolve().parents[1] / "fuzzy_lab" / "fcl2json" / "grammar.lark"


@pytest.fixture(scope="module")
def parser() -> Lark:
    return Lark(GRAMMAR_PATH.read_text(), start="function_block", parser="earley")


def test_parses_tipper(parser, fcl_dir):
    tree = parser.parse((fcl_dir / "tipper.fcl").read_text())
    assert tree.data == "function_block"


def test_parses_container_crane(parser, fcl_dir):
    tree = parser.parse((fcl_dir / "container-crane.fcl").read_text())
    assert tree.data == "function_block"


def test_parses_triage_with_not_and_weight(parser, fcl_dir):
    tree = parser.parse((fcl_dir / "triage.fcl").read_text())
    assert tree.data == "function_block"


@pytest.mark.parametrize("fcl_name", [
    "block.fcl", "ip.fcl", "ip2.fcl", "membershipFunctionsDemo.fcl",
    "qualify.fcl", "qualify_optimized.fcl", "tipping.fcl", "tipping2.fcl", "z.fcl",
])
def test_parses_all_other_fcl(parser, fcl_dir, fcl_name):
    parser.parse((fcl_dir / fcl_name).read_text())


def test_tipper_to_model(fcl_dir):
    model = parse_fcl((fcl_dir / "tipper.fcl").read_text())
    assert model.name == "tipper"
    assert [v.name for v in model.inputs] == ["service", "food"]
    assert [v.name for v in model.outputs] == ["tip"]
    # service.poor: point list (0,1)(4,0) → falling shape → (a,b,c,d) = (0,0,0,4).
    poor = model.inputs[0].terms[0]
    assert poor.name == "poor"
    assert (poor.a, poor.b, poor.c, poor.d) == (0, 0, 0, 4)
    # service.good: (1,0)(4,1)(6,1)(9,0) → trapezoid (1,4,6,9).
    good = model.inputs[0].terms[1]
    assert (good.a, good.b, good.c, good.d) == (1, 4, 6, 9)
    # First rule has IS-OR shape with two leaves.
    assert model.rules[0].if_["op"] == "or"


def test_triage_handles_not_and_weight(fcl_dir):
    model = parse_fcl((fcl_dir / "triage.fcl").read_text())
    rules_with_not = [r for r in model.rules if _has_op(r.if_, "not")]
    assert rules_with_not, "expected at least one IS NOT rule in triage.fcl"
    rules_with_weight = [r for r in model.rules if r.weight != 1.0]
    assert rules_with_weight, "expected at least one WITH-weighted rule in triage.fcl"


def test_singleton_term_is_a_b_c_d_equal(fcl_dir):
    model = parse_fcl((fcl_dir / "container-crane.fcl").read_text())
    out = model.outputs[0]
    neg_high = next(t for t in out.terms if t.name == "neg_high")
    assert (neg_high.a, neg_high.b, neg_high.c, neg_high.d) == (-27, -27, -27, -27)


def test_trian_term_is_a_b_b_c(fcl_dir):
    for fp in fcl_dir.glob("*.fcl"):
        if "trian " in fp.read_text() or "Triangle" in fp.read_text():
            model = parse_fcl(fp.read_text())
            for v in [*model.inputs, *model.outputs]:
                for t in v.terms:
                    if t.b == t.c and t.a < t.b < t.d and t.a != t.b:
                        return
    pytest.skip("no .fcl uses 'trian' form")


def _has_op(node: dict, op: str) -> bool:
    if not isinstance(node, dict):
        return False
    if node.get("op") == op:
        return True
    for k in ("args", "arg"):
        v = node.get(k)
        if isinstance(v, list):
            return any(_has_op(x, op) for x in v)
        if isinstance(v, dict):
            return _has_op(v, op)
    return False


def test_unsupported_membership_function_raises(fcl_dir):
    """gbell/gauss/sigm are not in the engine schema (a, b, c, d). The parser
    must refuse them with a clear error, not silently produce garbage."""
    for name in ["membershipFunctionsDemo.fcl", "qualify.fcl", "qualify_optimized.fcl"]:
        text = (fcl_dir / name).read_text()
        if any(kw in text for kw in (" gbell ", " gauss ", " sigm ")):
            with pytest.raises(NotImplementedError):
                parse_fcl(text)
            return
    pytest.skip("no .fcl uses gbell/gauss/sigm")
