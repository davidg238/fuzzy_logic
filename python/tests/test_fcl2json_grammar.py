from pathlib import Path
import pytest
from lark import Lark

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
