# Plan B — Python Tooling, Toit RPC, and Visualizer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the cross-language pipeline described in the 2026-05-08 spec — a Python `fcl2json` converter, Toit `RpcService` over the Plan-A engine, three new examples, a Plotly Dash visualizer, plus README/CHANGELOG/version-bump rollout.

**Architecture:** Three sub-systems built sequentially. Phase 6 (independent of Toit) is a Python Lark-based FCL parser that emits JSON matching the schema the Toit `json_loader` already accepts. Phase 7 extends `FuzzyModel` with `serialize-state` / `update-term`, adds an opt-in `RpcService` layered on the existing Toit `pkg-http` + `pkg-websocket` packages, and lands three new examples. Phase 8 is a Plotly Dash app that talks WebSocket to the RPC service, then docs and version bump.

**Tech Stack:**
- Python 3.10+, `uv` for env/deps, `lark` for the FCL grammar, `pytest` for tests, `dash` + `plotly` + `dash_extensions[websocket]` + `httpx` for the visualizer.
- Toit (existing toolchain via `jag toit run` / `jag toit pkg install`); deps `github.com/toitlang/pkg-http@1.9.3` and `pkg-websocket@1.0.0` (already in `examples/package.lock`).
- No CI; everything runs locally.

**Spec:** [`docs/superpowers/specs/2026-05-08-fuzzy-logic-restructure-design.md`](../specs/2026-05-08-fuzzy-logic-restructure-design.md), Phases 6–8.

**Pre-state:** Plan A is merged to `master` at tip `8f589ec` (or later if cleanup commits land first). Engine has closed-form centroid math, JSON loader, and `Antecedent.fl-not` + `FuzzyRule.weight`. `tests/test_models_via_json.toit` (31 cases) is the regression net.

**Pre-existing flake:** `tests/test_api_usability.toit` 2/9 cases fail; predates Plan A. Treat as the steady-state baseline; don't try to fix in this plan.

**Toolchain quirks (do not relearn):**
- Use `jag toit run` / `jag toit analyze` / `jag toit pkg install`; bare `toit` is not on PATH.
- `btest`'s `expect-equals` is typed `(int, int)` only. For floats use `expect-near`; for strings/bools use `expect-true x == y`.

---

## Out of scope (deliberately, for v1)

- Multiple `RULEBLOCK`s per FCL file
- Per-rule `ACT` and per-block `AND` / `OR` operator overrides
- Defuzz methods other than COG (warning + `defuzz_method` recorded only)
- `DEFAULT` value when no rule fires
- Saving viz edits back to FCL
- Mobile-friendly viz layout
- RPC authentication / TLS
- CI / GitHub Actions

---

## Scope reduction — 2026-05-10 (view-only viz)

Plan amended after Tasks 1–7 committed. Visualizer becomes **view-only**: MF shapes are static, live state (crisp values + per-term pertinence + rule-fired flags) refreshes by HTTP polling. No interactive term editing, no WebSocket. This removes the FuzzySet shape-validation problem entirely.

**Dropped tasks (do not implement):**
- **Task 8** (`FuzzyModel.update-term`) — no engine-side mutation needed. Uncommitted work discarded 2026-05-10.
- **Task 10** (WebSocket `/ws` push) — Dash polls `GET /state` instead (~500 ms cadence).
- **Task 17** (WS reconnect + drag handles) — both eliminated by the drop above.

**Simplified tasks:**
- **Task 9** (`RpcService`) — keep only `GET /model` and `GET /state`. Drop `POST /model`, `POST /input`, `POST /term`. No mutation surface at all.
- **Task 13** (`device.toit` + cleanup) — keep `examples/models.toit` (four tests import it, including the 31/0 regression net `test_models_via_json.toit` via `get-container-crane`). Only delete `examples/simple_01.toit` (unused). Skip Task-13 Steps 3-4 (casco refactor, `examples/models.toit` deletion) entirely. The Step-2 smoke test's POST /input curl line is also dropped (POST routes don't exist).
- **Task 14** (`viz/rpc.py`) — HTTP polling client only. Drop `dash_extensions[websocket]` dep and any WS code; `httpx` (or `requests`) is sufficient.
- **Task 16** (Dash app) — drop the WS subscribe layer; use `dcc.Interval` to poll `/state` and update figure overlays. No edit textarea/button.
- **Task 18** (README) — describe view-only viz; remove mentions of WS/editing.
- **Task 19** (CHANGELOG) — same.

**Schema/file-list deltas:**
- Remove `tests/test_update_term.toit` from "Files created (Toit side)".
- Remove `update-term` from `src/fuzzy_model.toit` "Files modified" line (only `serialize-state` lands).
- Tech-stack line: drop `dash_extensions[websocket]`.

**Remaining task count:** 13 of original 20 (Tasks 1–7 done, Tasks 9, 11–16, 18–20 remaining; Tasks 8, 10, 17 dropped).

---

## File structure

**Files created (Python side):**
- `python/pyproject.toml`
- `python/uv.lock` (committed; produced by `uv lock`)
- `python/.gitignore` (`.venv/`, `__pycache__/`, `*.egg-info/`, `dist/`)
- `python/README.md` — short dev-setup + invocation cheatsheet
- `python/fuzzy_lab/__init__.py` — empty
- `python/fuzzy_lab/schema.py` — dataclasses + JSON load/save
- `python/fuzzy_lab/fcl2json/__init__.py` — empty
- `python/fuzzy_lab/fcl2json/__main__.py` — argparse CLI entry
- `python/fuzzy_lab/fcl2json/grammar.lark`
- `python/fuzzy_lab/fcl2json/parser.py` — Lark Transformer
- `python/fuzzy_lab/viz/__init__.py` — empty
- `python/fuzzy_lab/viz/__main__.py` — argparse CLI entry
- `python/fuzzy_lab/viz/app.py` — Dash layout
- `python/fuzzy_lab/viz/plots.py` — Plotly figure builders
- `python/fuzzy_lab/viz/rpc.py` — HTTP+WS client to `RpcService`
- `python/tests/__init__.py` — empty
- `python/tests/conftest.py` — fixtures (path to `fcl/`, sample model, etc.)
- `python/tests/test_schema.py`
- `python/tests/test_fcl2json_grammar.py`
- `python/tests/test_fcl2json_round_trip.py`
- `python/tests/test_viz_plots.py`
- `python/tests/test_viz_rpc.py`

**Files created (Toit side):**
- `src/rpc_service.toit` — opt-in `RpcService` class
- `examples/simple.toit` — inline JSON literal demo
- `examples/embedded.toit` — multi-line JSON string constant for ESP32 use (no RPC)
- `examples/device.toit` — load JSON from a file/asset, start `RpcService`
- `tests/test_serialize_state.toit`
- `tests/test_update_term.toit`
- `fcl/generated/.gitkeep` — empty marker
- `fcl/generated/*.json` — committed JSON artifacts (one per `.fcl`)

**Files modified:**
- `src/fuzzy_model.toit` — add `serialize-state`, `update-term`
- `examples/package.yaml` (already declares `http` + `websocket` — no change unless Task 11 finds a missing dep)
- `package.yaml` — add `version: 0.7.0` line
- `CHANGELOG.md` — Plan-B summary
- `README.md` — full rewrite around the new pipeline

**Files deleted:**
- `examples/simple_01.toit`
- `examples/models.toit`

---

## Phase 6 — Python `fcl2json` converter

Independent of Toit. Output is `.json` files matching the schema the Plan-A `src/json_loader.toit` already consumes.

### Task 1: Scaffold `python/` with `uv`

**Files:** Create `python/pyproject.toml`, `python/uv.lock`, `python/.gitignore`, `python/README.md`, `python/fuzzy_lab/__init__.py`, `python/tests/__init__.py`.

- [ ] **Step 1: Verify `uv` is installed**

```bash
uv --version
```
If missing: `pip install uv` or `curl -LsSf https://astral.sh/uv/install.sh | sh`. Re-check.

- [ ] **Step 2: Create `python/` directory and a minimal `pyproject.toml`**

```bash
mkdir -p python/fuzzy_lab/fcl2json python/fuzzy_lab/viz python/tests
```

Create `python/pyproject.toml`:

```toml
[project]
name = "fuzzy_lab"
version = "0.1.0"
description = "FCL to JSON converter and Plotly Dash visualizer for the Toit fuzzy_logic engine"
requires-python = ">=3.10"
dependencies = [
  "lark>=1.1",
  "dash>=2.16",
  "plotly>=5.18",
  "dash-extensions>=1.0",
  "httpx>=0.27",
  "websockets>=12.0",
]

[project.scripts]
fcl2json = "fuzzy_lab.fcl2json.__main__:main"
fuzzy-lab = "fuzzy_lab.viz.__main__:main"

[project.optional-dependencies]
dev = ["pytest>=8.0"]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.hatch.build.targets.wheel]
packages = ["fuzzy_lab"]
```

- [ ] **Step 3: Create `python/.gitignore`**

```
.venv/
__pycache__/
*.egg-info/
dist/
.pytest_cache/
```

- [ ] **Step 4: Create `python/README.md`**

```markdown
# fuzzy_lab — Python tooling for fuzzy_logic

Two console scripts:

- `fcl2json <input.fcl>` — convert FCL to JSON (writes to stdout or `--output`).
- `fuzzy-lab --connect ws://host:port` — Plotly Dash visualizer.

## Setup

```
uv sync --all-extras
uv run pytest
```
```

- [ ] **Step 5: Create empty package init files**

```bash
: > python/fuzzy_lab/__init__.py
: > python/fuzzy_lab/fcl2json/__init__.py
: > python/fuzzy_lab/viz/__init__.py
: > python/tests/__init__.py
```

- [ ] **Step 6: Run `uv sync` and verify**

```bash
cd python && uv sync --all-extras
uv run python -c "import fuzzy_lab; print('ok')"
```
Expected output: `ok`. This also produces `python/uv.lock`.

- [ ] **Step 7: Commit**

```bash
git add python/
git commit -m "feat(python): scaffold fuzzy_lab project with uv

Creates pyproject.toml with lark + dash + plotly + httpx,
dev dep on pytest, and two console-script entrypoints
(fcl2json, fuzzy-lab). uv.lock pinned."
```

---

### Task 2: Define the JSON schema as Python dataclasses

**Files:** Create `python/fuzzy_lab/schema.py`, `python/tests/test_schema.py`, `python/tests/conftest.py`.

The schema mirrors the JSON shape the Toit `json_loader` already consumes (see spec §"JSON model schema"). The dataclasses serve as the single source of truth for both `fcl2json` and the visualizer.

- [ ] **Step 1: Create `python/tests/conftest.py`**

```python
from pathlib import Path
import pytest

REPO_ROOT = Path(__file__).resolve().parents[2]


@pytest.fixture
def fcl_dir() -> Path:
    return REPO_ROOT / "fcl"


@pytest.fixture
def sample_tipper_dict() -> dict:
    return {
        "name": "tipper",
        "defuzz_method": "COG",
        "inputs": [
            {
                "name": "service",
                "terms": [
                    {"name": "poor",      "a": 0, "b": 0, "c": 0, "d": 4},
                    {"name": "good",      "a": 1, "b": 4, "c": 6, "d": 9},
                    {"name": "excellent", "a": 6, "b": 9, "c": 9, "d": 9},
                ],
            },
        ],
        "outputs": [
            {
                "name": "tip",
                "terms": [
                    {"name": "cheap",   "a": 0,  "b": 5,  "c": 5,  "d": 10},
                    {"name": "average", "a": 10, "b": 15, "c": 15, "d": 20},
                ],
            },
        ],
        "rules": [
            {
                "weight": 1.0,
                "if":   {"op": "is", "var": "service", "term": "poor"},
                "then": [{"var": "tip", "term": "cheap"}],
            },
        ],
    }
```

- [ ] **Step 2: Write the failing test in `python/tests/test_schema.py`**

```python
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
```

- [ ] **Step 3: Run, expect failure**

```bash
cd python && uv run pytest tests/test_schema.py -v
```
Expected: `ImportError: cannot import name 'Model'` (or similar).

- [ ] **Step 4: Implement `python/fuzzy_lab/schema.py`**

```python
"""Dataclasses for the fuzzy_logic JSON model schema.

Single source of truth shared by fcl2json and the visualizer; mirrors
the shape the Toit json_loader.toit consumes.
"""

from __future__ import annotations

import json
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any


@dataclass
class Term:
    name: str
    a: float
    b: float
    c: float
    d: float

    @classmethod
    def from_dict(cls, d: dict) -> "Term":
        return cls(name=d["name"], a=float(d["a"]), b=float(d["b"]),
                   c=float(d["c"]), d=float(d["d"]))

    def to_dict(self) -> dict:
        return {"name": self.name, "a": _num(self.a), "b": _num(self.b),
                "c": _num(self.c), "d": _num(self.d)}


@dataclass
class FuzzyVar:
    name: str
    terms: list[Term] = field(default_factory=list)

    @classmethod
    def from_dict(cls, d: dict) -> "FuzzyVar":
        return cls(name=d["name"], terms=[Term.from_dict(t) for t in d["terms"]])

    def to_dict(self) -> dict:
        return {"name": self.name, "terms": [t.to_dict() for t in self.terms]}


@dataclass
class Consequent:
    var: str
    term: str

    @classmethod
    def from_dict(cls, d: dict) -> "Consequent":
        return cls(var=d["var"], term=d["term"])

    def to_dict(self) -> dict:
        return {"var": self.var, "term": self.term}


@dataclass
class Rule:
    if_: dict   # expression tree {op, ...}
    then: list[Consequent]
    name: str = ""
    weight: float = 1.0

    @classmethod
    def from_dict(cls, d: dict) -> "Rule":
        return cls(
            if_=d["if"],
            then=[Consequent.from_dict(c) for c in d["then"]],
            name=d.get("name", ""),
            weight=float(d.get("weight", 1.0)),
        )

    def to_dict(self) -> dict:
        out: dict[str, Any] = {}
        if self.name:
            out["name"] = self.name
        if self.weight != 1.0:
            out["weight"] = _num(self.weight)
        out["if"] = self.if_
        out["then"] = [c.to_dict() for c in self.then]
        return out


@dataclass
class Model:
    name: str
    inputs: list[FuzzyVar] = field(default_factory=list)
    outputs: list[FuzzyVar] = field(default_factory=list)
    rules: list[Rule] = field(default_factory=list)
    defuzz_method: str = "COG"

    @classmethod
    def from_dict(cls, d: dict) -> "Model":
        return cls(
            name=d["name"],
            defuzz_method=d.get("defuzz_method", "COG"),
            inputs=[FuzzyVar.from_dict(v) for v in d.get("inputs", [])],
            outputs=[FuzzyVar.from_dict(v) for v in d.get("outputs", [])],
            rules=[Rule.from_dict(r) for r in d.get("rules", [])],
        )

    def to_dict(self) -> dict:
        return {
            "name": self.name,
            "defuzz_method": self.defuzz_method,
            "inputs": [v.to_dict() for v in self.inputs],
            "outputs": [v.to_dict() for v in self.outputs],
            "rules": [r.to_dict() for r in self.rules],
        }

    @classmethod
    def from_json_file(cls, path: Path) -> "Model":
        return cls.from_dict(json.loads(Path(path).read_text()))

    def to_json_file(self, path: Path, *, indent: int = 2) -> None:
        Path(path).write_text(json.dumps(self.to_dict(), indent=indent))


def _num(x: float) -> float | int:
    """Render whole floats as ints in JSON output (matches FCL aesthetics)."""
    if x == int(x):
        return int(x)
    return x
```

- [ ] **Step 5: Run the test, expect pass**

```bash
cd python && uv run pytest tests/test_schema.py -v
```
Expected: 2 passed.

- [ ] **Step 6: Commit**

```bash
git add python/fuzzy_lab/schema.py python/tests/test_schema.py python/tests/conftest.py
git commit -m "feat(python): JSON schema dataclasses for fuzzy_lab

Term/FuzzyVar/Consequent/Rule/Model with from_dict/to_dict/JSON
file helpers. Round-trip preserves the schema's wire shape; whole
floats render as ints to keep generated JSON readable."
```

---

### Task 3: Lark grammar for FCL

**Files:** Create `python/fuzzy_lab/fcl2json/grammar.lark`, `python/tests/test_fcl2json_grammar.py`.

The grammar covers exactly the forms used by `.fcl` files in `fcl/`. New forms cause a parse error with file:line. Out-of-scope FCL features (`AND : MIN`, `ACT : MIN`, multiple RULEBLOCKs, etc.) are tolerated by accepting and discarding their lines.

- [ ] **Step 1: Survey `.fcl` content**

```bash
grep -E "^[[:space:]]*(TERM|RULE|METHOD|DEFAULT|AND|OR|ACT|ACCU|VAR_INPUT|VAR_OUTPUT|END_VAR|FUZZIFY|END_FUZZIFY|DEFUZZIFY|END_DEFUZZIFY|RULEBLOCK|END_RULEBLOCK|FUNCTION_BLOCK|END_FUNCTION_BLOCK)" fcl/*.fcl | head -60
```
Confirm shapes: `TERM x := trape a b c d ;`, `TERM x := (a,b) (c,d) ... ;`, `TERM x := <number> ;`, `RULE n : IF <expr> THEN <var> IS <term> [, <var> IS <term>]* [WITH <weight>];`. Report any unhandled shape before proceeding.

- [ ] **Step 2: Write the failing grammar test in `python/tests/test_fcl2json_grammar.py`**

```python
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
```

- [ ] **Step 3: Run, expect failure**

```bash
cd python && uv run pytest tests/test_fcl2json_grammar.py -v
```
Expected: `FileNotFoundError: grammar.lark` (or similar).

- [ ] **Step 4: Create `python/fuzzy_lab/fcl2json/grammar.lark`**

```lark
// FCL grammar — covers the subset used by every .fcl file in fcl/.
// Out-of-scope directives (AND/OR/ACT/ACCU/DEFAULT) are accepted and
// discarded; the shape we care about is TERMs and RULEs.

function_block: "FUNCTION_BLOCK" NAME _block_body "END_FUNCTION_BLOCK"

_block_body: (var_input | var_output | fuzzify | defuzzify | ruleblock)+

var_input:  "VAR_INPUT"  var_decl* "END_VAR"
var_output: "VAR_OUTPUT" var_decl* "END_VAR"
var_decl: NAME ":" "REAL" ";"

fuzzify:   "FUZZIFY"   NAME term_decl+ "END_FUZZIFY"
defuzzify: "DEFUZZIFY" NAME term_decl+ defuzzify_extra* "END_DEFUZZIFY"

defuzzify_extra: method_decl | default_decl
method_decl:  "METHOD"  ":" NAME ";"
default_decl: "DEFAULT" ":=" SIGNED_NUMBER ";"

term_decl: "TERM" NAME ":=" term_body ";"

term_body: term_trape
         | term_trian
         | term_points
         | term_singleton

term_trape:    "trape" SIGNED_NUMBER SIGNED_NUMBER SIGNED_NUMBER SIGNED_NUMBER
term_trian:    "trian" SIGNED_NUMBER SIGNED_NUMBER SIGNED_NUMBER
term_points:   point+
term_singleton: SIGNED_NUMBER
point: "(" SIGNED_NUMBER "," SIGNED_NUMBER ")"

ruleblock: "RULEBLOCK" NAME ruleblock_extra* rule+ "END_RULEBLOCK"
ruleblock_extra: op_decl
op_decl: ("AND"|"OR"|"ACT"|"ACCU") ":" NAME ";"

rule: "RULE" RULE_ID ":" "IF" expr "THEN" consequent_list ("WITH" SIGNED_NUMBER)? ";"
RULE_ID: /[A-Za-z0-9_]+/

?expr: or_expr
?or_expr:  and_expr ("OR"i and_expr)*           -> or_expr
?and_expr: not_expr ("AND"i not_expr)*          -> and_expr
?not_expr: "NOT"i atom                          -> not_expr
         | atom
?atom: "(" expr ")"
     | is_expr
is_expr: NAME "IS"i ("NOT"i)? NAME              -> is_expr

consequent_list: consequent ("," consequent)*
consequent: NAME "IS"i NAME

NAME: /[A-Za-z_][A-Za-z0-9_]*/

%import common.SIGNED_NUMBER
%import common.WS
%ignore WS
%ignore /\/\/[^\n]*/        // line comments
%ignore /\/\*(.|\n)*?\*\//  // block comments
```

- [ ] **Step 5: Run the tests, expect pass**

```bash
cd python && uv run pytest tests/test_fcl2json_grammar.py -v
```
Expected: 12 passed (the 3 named tests + 9 parametrised). If a file fails to parse, the error message names a token; add the missing form to the grammar.

- [ ] **Step 6: Commit**

```bash
git add python/fuzzy_lab/fcl2json/grammar.lark python/tests/test_fcl2json_grammar.py
git commit -m "feat(fcl2json): Lark grammar covering every .fcl in fcl/

Earley parser. Handles TERM forms (trape, trian, point list,
singleton number), RULE with optional WITH weight, IS/IS NOT/AND/
OR/NOT expressions, line + block comments. AND/OR/ACT/ACCU
directives are accepted-and-discarded; DEFAULT is parsed but
ignored (out of scope for v1)."
```

---

### Task 4: Parser/Transformer turning grammar tree → schema dataclasses

**Files:** Create `python/fuzzy_lab/fcl2json/parser.py`. Extend `python/tests/test_fcl2json_grammar.py`.

- [ ] **Step 1: Append the failing test to `python/tests/test_fcl2json_grammar.py`**

```python
from fuzzy_lab.fcl2json.parser import parse_fcl


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
    # power output uses singleton TERMs: TERM neg_high := -27;
    out = model.outputs[0]
    neg_high = next(t for t in out.terms if t.name == "neg_high")
    assert (neg_high.a, neg_high.b, neg_high.c, neg_high.d) == (-27, -27, -27, -27)


def test_trian_term_is_a_b_b_c(fcl_dir):
    # If any .fcl uses trian a b c, parser should produce (a, b, b, c).
    # Skip if no .fcl uses trian; this test is a guard for future regressions.
    for fp in fcl_dir.glob("*.fcl"):
        if "trian " in fp.read_text():
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
```

- [ ] **Step 2: Run, expect import failure**

```bash
cd python && uv run pytest tests/test_fcl2json_grammar.py -v
```
Expected: `ImportError: cannot import name 'parse_fcl'`.

- [ ] **Step 3: Implement `python/fuzzy_lab/fcl2json/parser.py`**

```python
"""Parse FCL source text into a Model dataclass.

Reads grammar.lark sibling and walks the resulting tree with a Lark
Transformer. Point-list TERMs are normalised to (a, b, c, d) by the
canonical-shape recogniser in _points_to_abcd.
"""

from __future__ import annotations

import sys
from pathlib import Path
from typing import Any

from lark import Lark, Transformer, Token

from fuzzy_lab.schema import Consequent, FuzzyVar, Model, Rule, Term

GRAMMAR = (Path(__file__).parent / "grammar.lark").read_text()
_PARSER = Lark(GRAMMAR, start="function_block", parser="earley")


def parse_fcl(text: str) -> Model:
    tree = _PARSER.parse(text)
    return _ToModel().transform(tree)


def _num(token: Token) -> float:
    return float(token)


def _points_to_abcd(points: list[tuple[float, float]]) -> tuple[float, float, float, float]:
    """Recognise standard membership shapes.

    Trapezoid (4 pts): (a,0)(b,1)(c,1)(d,0).
    Triangle (3 pts): (a,0)(b,1)(d,0) → (a, b, b, d).
    Right-shoulder (2 pts): (a,0)(b,1) → (a, b, b, b).  (Rises to 1, stays 1.)
    Left-shoulder (2 pts):  (a,1)(b,0) → (a, a, a, b).  (Starts at 1, falls.)

    Anything else: throw with the original points so the caller can debug.
    """
    pts = sorted(points, key=lambda p: p[0])
    xs = [p[0] for p in pts]
    ys = [p[1] for p in pts]

    if len(pts) == 4 and ys == [0, 1, 1, 0]:
        return (xs[0], xs[1], xs[2], xs[3])
    if len(pts) == 3 and ys == [0, 1, 0]:
        return (xs[0], xs[1], xs[1], xs[2])
    if len(pts) == 2:
        if ys == [0, 1]:
            return (xs[0], xs[1], xs[1], xs[1])
        if ys == [1, 0]:
            return (xs[0], xs[0], xs[0], xs[1])

    raise ValueError(f"fcl2json: unrecognised point shape {pts}")


class _ToModel(Transformer):
    # Leaves first.

    def NAME(self, t: Token) -> str:
        return str(t)

    def RULE_ID(self, t: Token) -> str:
        return str(t)

    def SIGNED_NUMBER(self, t: Token) -> float:
        return _num(t)

    # Term bodies.

    def term_trape(self, items):
        a, b, c, d = items
        return ("abcd", (a, b, c, d))

    def term_trian(self, items):
        a, b, c = items
        return ("abcd", (a, b, b, c))

    def term_singleton(self, items):
        n, = items
        return ("abcd", (n, n, n, n))

    def point(self, items):
        x, y = items
        return (x, y)

    def term_points(self, items):
        return ("abcd", _points_to_abcd(list(items)))

    def term_body(self, items):
        return items[0]

    def term_decl(self, items):
        name = items[0]
        _, abcd = items[1]
        return Term(name=name, a=abcd[0], b=abcd[1], c=abcd[2], d=abcd[3])

    # Variable declarations.

    def var_decl(self, items):
        return items[0]   # variable name string; types not tracked

    def var_input(self, items):
        return ("inputs", list(items))   # list of variable names declared

    def var_output(self, items):
        return ("outputs", list(items))

    # Fuzzify / Defuzzify blocks: build FuzzyVar.

    def fuzzify(self, items):
        name, *terms = items
        return ("fuzzify", FuzzyVar(name=name, terms=terms))

    def defuzzify(self, items):
        # First child is the var name, then a sequence of term_decl + defuzzify_extra.
        name = items[0]
        terms = [x for x in items[1:] if isinstance(x, Term)]
        method = "COG"
        for x in items[1:]:
            if isinstance(x, dict) and "method" in x:
                method = x["method"]
        return ("defuzzify", FuzzyVar(name=name, terms=terms), method)

    def method_decl(self, items):
        return {"method": items[0]}

    def default_decl(self, items):
        return None   # discarded for v1

    def defuzzify_extra(self, items):
        return items[0]

    # Rules.

    def is_expr(self, items):
        # NAME IS [NOT] NAME — Lark gives 2 or 3 NAME items depending on optional NOT.
        if len(items) == 2:
            var, term = items
            return {"op": "is", "var": var, "term": term}
        var, term = items[0], items[-1]
        return {"op": "not", "arg": {"op": "is", "var": var, "term": term}}

    def not_expr(self, items):
        inner, = items
        return {"op": "not", "arg": inner}

    def and_expr(self, items):
        return _fold("and", list(items))

    def or_expr(self, items):
        return _fold("or", list(items))

    def consequent(self, items):
        var, term = items
        return Consequent(var=var, term=term)

    def consequent_list(self, items):
        return list(items)

    def rule(self, items):
        # rule: RULE_ID expr consequent_list (SIGNED_NUMBER)?
        if len(items) == 4:
            name, expr, then, weight = items
        else:
            name, expr, then = items
            weight = 1.0
        return Rule(if_=expr, then=list(then), name=str(name), weight=float(weight))

    def op_decl(self, items):
        return None   # discarded

    def ruleblock_extra(self, items):
        return items[0]

    def ruleblock(self, items):
        return [r for r in items[1:] if isinstance(r, Rule)]

    def function_block(self, items):
        # First item: NAME (block name).
        name = items[0]
        inputs: list[FuzzyVar] = []
        outputs: list[FuzzyVar] = []
        rules: list[Rule] = []
        defuzz_method = "COG"
        for child in items[1:]:
            if isinstance(child, tuple):
                kind = child[0]
                if kind == "fuzzify":
                    inputs.append(child[1])
                elif kind == "defuzzify":
                    outputs.append(child[1])
                    defuzz_method = child[2]
            elif isinstance(child, list) and child and isinstance(child[0], Rule):
                rules.extend(child)

        if defuzz_method != "COG":
            print(f"warning: defuzz method '{defuzz_method}' is recorded but only COG is honored",
                  file=sys.stderr)

        return Model(name=name, inputs=inputs, outputs=outputs,
                     rules=rules, defuzz_method=defuzz_method)


def _fold(op: str, args: list[Any]) -> Any:
    """Lark gives an N-arg list for AND/OR; nest into binary tree."""
    if len(args) == 1:
        return args[0]
    left = args[0]
    for right in args[1:]:
        left = {"op": op, "args": [left, right]}
    return left
```

- [ ] **Step 4: Run, expect pass**

```bash
cd python && uv run pytest tests/test_fcl2json_grammar.py -v
```
Expected: all tests in the file pass. If `_points_to_abcd` rejects a shape, the error message names the points; extend the recogniser if the shape is real (e.g., a 5-point form), or fail loudly if the FCL is malformed.

- [ ] **Step 5: Commit**

```bash
git add python/fuzzy_lab/fcl2json/parser.py python/tests/test_fcl2json_grammar.py
git commit -m "feat(fcl2json): tree → Model transformer

parse_fcl(text) returns a Model. Point-list TERMs normalise to
(a, b, c, d) for trapezoid / triangle / shoulder shapes; trian
becomes (a, b, b, c); singleton n becomes (n, n, n, n). IS NOT
folds to nested {op:not, arg:{op:is,...}}. AND/OR with 3+ operands
fold left-to-right into binary trees. Out-of-scope directives are
discarded; non-COG METHOD warns to stderr."
```

---

### Task 5: CLI entry + per-file conversion + `--all` batch

**Files:** Create `python/fuzzy_lab/fcl2json/__main__.py`. Extend `python/tests/test_fcl2json_grammar.py` (or add a new test file).

- [ ] **Step 1: Add the failing CLI test**

Append to `python/tests/test_fcl2json_grammar.py`:

```python
import subprocess


def test_cli_writes_json(fcl_dir, tmp_path):
    out = tmp_path / "tipper.json"
    rc = subprocess.run(
        ["uv", "run", "fcl2json", str(fcl_dir / "tipper.fcl"), "--output", str(out)],
        cwd=Path(__file__).resolve().parents[1],   # cwd = python/
        capture_output=True, text=True,
    )
    assert rc.returncode == 0, rc.stderr
    assert out.exists()
    import json as _json
    obj = _json.loads(out.read_text())
    assert obj["name"] == "tipper"
    assert obj["defuzz_method"] == "COG"


def test_cli_all_option(fcl_dir, tmp_path):
    rc = subprocess.run(
        ["uv", "run", "fcl2json", "--all", str(fcl_dir), "--out-dir", str(tmp_path)],
        cwd=Path(__file__).resolve().parents[1],
        capture_output=True, text=True,
    )
    assert rc.returncode == 0, rc.stderr
    # Every .fcl should have produced a .json.
    fcls = sorted(p.stem for p in fcl_dir.glob("*.fcl"))
    jsons = sorted(p.stem for p in tmp_path.glob("*.json"))
    assert jsons == fcls
```

- [ ] **Step 2: Run, expect failure**

```bash
cd python && uv run pytest tests/test_fcl2json_grammar.py::test_cli_writes_json -v
```
Expected: `fcl2json` not found (no entry point yet).

- [ ] **Step 3: Implement `python/fuzzy_lab/fcl2json/__main__.py`**

```python
"""fcl2json CLI: convert FCL source files into the engine's JSON schema."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from fuzzy_lab.fcl2json.parser import parse_fcl


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(prog="fcl2json", description="Convert FCL → JSON")
    p.add_argument("source", nargs="?", help="single .fcl path")
    p.add_argument("--all", dest="all_dir", help="convert every .fcl in <dir>")
    p.add_argument("--output", "-o", help="output JSON path (single-file mode)")
    p.add_argument("--out-dir", help="output dir for --all mode (default: <all-dir>/generated)")
    p.add_argument("--indent", type=int, default=2)
    args = p.parse_args(argv)

    if bool(args.source) == bool(args.all_dir):
        p.error("specify either a single source or --all, not both")

    try:
        if args.all_dir:
            return _convert_all(Path(args.all_dir), args.out_dir, args.indent)
        return _convert_one(Path(args.source), args.output, args.indent)
    except Exception as exc:
        print(f"fcl2json: {exc}", file=sys.stderr)
        return 1


def _convert_one(source: Path, output: str | None, indent: int) -> int:
    model = parse_fcl(source.read_text())
    text = json.dumps(model.to_dict(), indent=indent)
    if output:
        Path(output).write_text(text)
    else:
        sys.stdout.write(text + "\n")
    return 0


def _convert_all(src_dir: Path, out_dir: str | None, indent: int) -> int:
    out = Path(out_dir) if out_dir else src_dir / "generated"
    out.mkdir(parents=True, exist_ok=True)
    for fcl in sorted(src_dir.glob("*.fcl")):
        model = parse_fcl(fcl.read_text())
        (out / f"{fcl.stem}.json").write_text(json.dumps(model.to_dict(), indent=indent))
        print(f"  {fcl.name} -> {out / (fcl.stem + '.json')}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
```

- [ ] **Step 4: Re-sync uv so the script entry point is registered**

```bash
cd python && uv sync --all-extras
```

- [ ] **Step 5: Run the CLI tests, expect pass**

```bash
cd python && uv run pytest tests/test_fcl2json_grammar.py -v
```
Expected: all tests in the file pass.

- [ ] **Step 6: Commit**

```bash
git add python/fuzzy_lab/fcl2json/__main__.py python/tests/test_fcl2json_grammar.py
git commit -m "feat(fcl2json): argparse CLI with --all batch mode

fcl2json <file> [--output OUT] for single-file conversion;
fcl2json --all <dir> [--out-dir DIR] for batch mode (default
output dir <dir>/generated/). Invalid grammar produces a non-zero
exit and a fcl2json: <message> line on stderr."
```

---

### Task 6: Round-trip test — every `.fcl` converts and loads in Toit

**Files:** Create `python/tests/test_fcl2json_round_trip.py`. Generate `fcl/generated/*.json`.

- [ ] **Step 1: Write the round-trip test**

```python
"""For every .fcl in fcl/, run fcl2json and then jag toit run to load
the produced JSON via src/json_loader.toit. Asserts the engine
accepts the converter's output."""

import json
import subprocess
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parents[2]
PYTHON_DIR = REPO_ROOT / "python"


@pytest.fixture(scope="module")
def fcl_files():
    return sorted((REPO_ROOT / "fcl").glob("*.fcl"))


def test_round_trip_via_subprocess(fcl_files, tmp_path_factory):
    """fcl2json → JSON → load-model in Toit → defuzzify → no exceptions."""
    out = tmp_path_factory.mktemp("generated")
    rc = subprocess.run(
        ["uv", "run", "fcl2json", "--all", str(REPO_ROOT / "fcl"), "--out-dir", str(out)],
        cwd=PYTHON_DIR, capture_output=True, text=True,
    )
    assert rc.returncode == 0, rc.stderr

    # Build a tiny Toit harness that loads the JSON and runs fuzzify/defuzzify.
    harness = tmp_path_factory.mktemp("harness") / "main.toit"
    pkg_yaml = harness.parent / "package.yaml"
    pkg_yaml.write_text(
        "dependencies:\n"
        "  fuzzy-logic:\n"
        f"    path: {REPO_ROOT}\n"
    )

    for fcl in fcl_files:
        json_path = out / f"{fcl.stem}.json"
        assert json_path.exists(), fcl.stem
        spec = json.loads(json_path.read_text())
        # Sanity: top-level shape must match what json_loader expects.
        assert spec["name"]
        assert "inputs" in spec and "outputs" in spec and "rules" in spec

        # Compose a one-shot Toit program that loads + fuzzifies + defuzzifies.
        crisp_args = ", ".join(["0.0"] * len(spec["inputs"]))
        # Toit triple-quoted strings (`"""..."""`) accept `"` without escaping;
        # they only end at a literal `"""`, which the JSON output never produces.
        harness.write_text(_HARNESS_TEMPLATE.format(
            json_text=json_path.read_text(),
            crisp_args=crisp_args,
        ))
        rc = subprocess.run(
            ["jag", "toit", "run", str(harness)],
            capture_output=True, text=True, timeout=30,
        )
        assert rc.returncode == 0, f"{fcl.name}:\n{rc.stderr}"


_HARNESS_TEMPLATE = """\
import encoding.json
import fuzzy-logic show *
import fuzzy-logic.json-loader show load-model

main:
  spec := json.parse \"\"\"{json_text}\"\"\"
  model := load-model spec
  inputs := [{crisp_args}]
  inputs.size.repeat: | i | model.crisp-input i inputs[i]
  model.fuzzify
  model.outputs.size.repeat: | i | model.defuzzify i
"""
```

Note: this test invokes `jag` per-file inside pytest. Allow ~30s timeout each.

- [ ] **Step 2: Run, expect failure if any .fcl produces invalid JSON for the loader**

```bash
cd python && uv run pytest tests/test_fcl2json_round_trip.py -v
```
Expected: all `.fcl` round-trip green. If a file fails, the stderr has the Toit error — fix the parser, not the engine. (If a real engine bug surfaces, stop and report.)

- [ ] **Step 3: Generate the committed `fcl/generated/*.json` artifacts**

```bash
mkdir -p fcl/generated
cd python && uv run fcl2json --all "$(pwd)/.." --out-dir "$(pwd)/../fcl/generated"
ls ../fcl/generated/
```
Expected: 12 `.json` files (one per `.fcl`, except `triage.java` which is a sibling Java file, not FCL).

- [ ] **Step 4: Add a `.gitkeep` so `fcl/generated/` is tracked even if empty**

```bash
: > fcl/generated/.gitkeep
```

- [ ] **Step 5: Commit (two commits: round-trip test, then artifacts)**

```bash
git add python/tests/test_fcl2json_round_trip.py
git commit -m "test(fcl2json): round-trip every .fcl through fcl2json + Toit json_loader

Subprocess-driven test: fcl2json --all → fcl/generated → tiny Toit
harness loads each JSON via load-model and runs fuzzify/defuzzify.
Catches schema drift between Python emission and Toit consumption."

git add fcl/generated/
git commit -m "chore(fcl): commit fcl2json artifacts for every .fcl

Single source of truth in fcl/*.fcl. Generated JSON committed for
visibility (engine and viz can consume them without invoking Python)."
```

---

## Phase 7 — Toit engine API additions, RPC service, new examples

### Task 7: Add `FuzzyModel.serialize-state`

**Files:** Modify `src/fuzzy_model.toit`. Create `tests/test_serialize_state.toit`.

Per spec §"Engine API additions": `serialize-state -> Map` returns runtime data for the `/state` push.

```
{
  inputs: [{name, crisp, terms: [{name, pertinence}]}],
  outputs: [{name, crisp, terms: [{name, pertinence}]}],
  rules: [{name, fired}],
}
```

- [ ] **Step 1: Write the failing test in `tests/test_serialize_state.toit`**

```toit
// Copyright (c) 2026 Ekorau LLC

import btest show *
import fuzzy-logic show *
import fuzzy-logic.json-loader show load-model

main:
  test-start

  test "serialize-state" "before fuzzify, all pertinences are 0":
    model := load-model SAMPLE
    state := model.serialize-state
    expect-true state["inputs"] is List
    expect-equals 1 state["inputs"].size
    expect-true (state["inputs"][0]["name"]) == "x"
    expect-near 0.0 state["inputs"][0]["crisp"]
    state["inputs"][0]["terms"].do: | t | expect-near 0.0 t["pertinence"]
    state["outputs"].do: | o |
      o["terms"].do: | t | expect-near 0.0 t["pertinence"]

  test "serialize-state" "after fuzzify, fired rule is reflected":
    model := load-model SAMPLE
    model.crisp-input 0 8.0
    model.fuzzify
    state := model.serialize-state
    expect-near 8.0 state["inputs"][0]["crisp"]
    fired := state["rules"][0]["fired"]
    expect-true fired

  test "serialize-state" "rule names round-trip":
    model := load-model SAMPLE
    state := model.serialize-state
    expect-true state["rules"][0]["name"] == "r1"

  test-end

SAMPLE ::= {
  "name": "tiny",
  "inputs": [{"name": "x", "terms": [
    {"name": "lo", "a": 0, "b": 0,  "c": 0,  "d": 10},
    {"name": "hi", "a": 0, "b": 10, "c": 10, "d": 10},
  ]}],
  "outputs": [{"name": "y", "terms": [
    {"name": "off", "a": 0, "b": 0, "c": 0, "d": 0},
    {"name": "on",  "a": 0, "b": 5, "c": 5, "d": 10},
  ]}],
  "rules": [
    {"name": "r1",
     "if":   {"op": "is", "var": "x", "term": "hi"},
     "then": [{"var": "y", "term": "on"}]},
  ],
}
```

- [ ] **Step 2: Run, expect failure**

```bash
jag toit run tests/test_serialize_state.toit
```
Expected: `Unresolved identifier: 'serialize-state'` (or similar).

- [ ] **Step 3: Implement `serialize-state` in `src/fuzzy_model.toit`**

Append to the `FuzzyModel` class (do not touch existing methods):

```toit
  /// Returns runtime state as a Map suitable for the RPC `/state` push.
  /// Distinct from /model (topology); this is just the dynamic data.
  serialize-state -> Map:
    return {
      "inputs":  inputs.map: | input | {
        "name":  input.name,
        "crisp": crisp-inputs[inputs.index-of input],
        "terms": input.fsets.map: | s | {"name": s.name, "pertinence": s.pertinence},
      },
      "outputs": outputs.map: | output | {
        "name":  output.name,
        // defuzzify is idempotent — caches on first call. Returning 0 before
        // fuzzify+defuzzify isn't meaningful runtime data, so just call it.
        "crisp": output.fsets.any: | s | s.is-pertinent
            ? output.defuzzify
            : 0.0,
        "terms": output.fsets.map: | s | {"name": s.name, "pertinence": s.pertinence},
      },
      "rules": rules.map: | rule | {"name": rule.name, "fired": rule.fired},
    }
```

Note: `defuzzify` is idempotent and caches its result inside `Composition.crisp-out_`. The `output.fsets.any` guard avoids invoking it before any fuzzify pass has run (when no set is pertinent there's nothing to defuzzify, and the cached result would be `null / 0.0`).

- [ ] **Step 4: Run, expect pass**

```bash
jag toit run tests/test_serialize_state.toit
```
Expected: 3 tests pass.

- [ ] **Step 5: Run the regression net**

```bash
jag toit run tests/test_models_via_json.toit
```
Expected: 31/0.

- [ ] **Step 6: Commit**

```bash
git add src/fuzzy_model.toit tests/test_serialize_state.toit
git commit -m "feat(engine): add FuzzyModel.serialize-state

Returns a Map shaped for the RPC /state push: per-input crisp value
and term pertinences; per-output crisp value and term pertinences;
per-rule name + fired flag. Distinct from /model (which is the
unchanging topology)."
```

---

### Task 8: ~~Add `FuzzyModel.update-term`~~ [DROPPED 2026-05-10 — view-only viz, no mutation API]

**Files:** Modify `src/fuzzy_model.toit`. Create `tests/test_update_term.toit`.

Per spec §"Engine API additions": `update-term var-name term-name a b c d` mutates one term's vertices in place.

- [ ] **Step 1: Write the failing test in `tests/test_update_term.toit`**

```toit
// Copyright (c) 2026 Ekorau LLC

import btest show *
import fuzzy-logic show *
import fuzzy-logic.json-loader show load-model

main:
  test-start

  test "update-term" "input term mutates in place":
    model := load-model SAMPLE
    model.update-term "x" "hi" 0.0 8.0 8.0 10.0
    set := model.inputs[0].fsets[1]
    expect-near 0.0  set.test-a
    expect-near 8.0  set.test-b
    expect-near 8.0  set.test-c
    expect-near 10.0 set.test-d

  test "update-term" "output term mutates and downstream defuzzify reflects":
    m1 := load-model SAMPLE
    m1.crisp-input 0 8.0
    m1.fuzzify
    before := m1.defuzzify 0
    m2 := load-model SAMPLE
    m2.update-term "y" "on" 0.0 9.0 9.0 10.0
    m2.crisp-input 0 8.0
    m2.fuzzify
    after := m2.defuzzify 0
    // "on" centroid moved right; output should rise.
    expect-true after > before

  test "update-term" "unknown var/term throws":
    model := load-model SAMPLE
    expect-throws: model.update-term "nope" "lo" 0.0 0.0 0.0 0.0
    expect-throws: model.update-term "x"    "nope" 0.0 0.0 0.0 0.0

  test-end

SAMPLE ::= {
  "name": "tiny",
  "inputs": [{"name": "x", "terms": [
    {"name": "lo", "a": 0, "b": 0,  "c": 0,  "d": 10},
    {"name": "hi", "a": 0, "b": 10, "c": 10, "d": 10},
  ]}],
  "outputs": [{"name": "y", "terms": [
    {"name": "off", "a": 0, "b": 0, "c": 0, "d": 0},
    {"name": "on",  "a": 0, "b": 5, "c": 5, "d": 10},
  ]}],
  "rules": [
    {"name": "r1",
     "if":   {"op": "is", "var": "x", "term": "hi"},
     "then": [{"var": "y", "term": "on"}]},
  ],
}
```

- [ ] **Step 2: Run, expect failure**

```bash
jag toit run tests/test_update_term.toit
```
Expected: unresolved `update-term`.

- [ ] **Step 3: Implement `update-term` in `src/fuzzy_model.toit`**

Replace the existing `FuzzySet` with a fresh one (since the existing `a_/b_/c_/d_` are immutable by design — we'd otherwise need new setters). Cleaner: append a `replace-set_` helper to `fuzzy-in-out.toit`'s `InputOutput` and call into it from `update-term`.

Add to `src/fuzzy_in_out.toit` `InputOutput` class:

```toit
  replace-set old-name/string new-set/FuzzySet -> none:
    fsets.size.repeat: | i |
      if fsets[i].name == old-name:
        fsets[i] = new-set
        range_ = null
        return
    throw "fuzzy_in_out: unknown term '$old-name'"
```

Add to `src/fuzzy_model.toit` `FuzzyModel`:

```toit
  /// Replace the term named term-name on the variable named var-name
  /// with a new FuzzySet built from (a, b, c, d). Used by the RPC layer
  /// for live drag-edit support.
  update-term var-name/string term-name/string a/num b/num c/num d/num -> none:
    target := find-var_ var-name
    new-set := FuzzySet a b c d term-name
    target.replace-set term-name new-set

  find-var_ name/string -> InputOutput:
    inputs.do:  | v | if v.name == name: return v
    outputs.do: | v | if v.name == name: return v
    throw "fuzzy_model: unknown variable '$name'"
```

(Add `import .fuzzy-in-out show InputOutput FuzzyInput FuzzyOutput` if needed; the file currently imports `*` from that module so it should already be in scope.)

- [ ] **Step 4: Run, expect pass**

```bash
jag toit run tests/test_update_term.toit
```
Expected: 3 tests pass.

- [ ] **Step 5: Run the regression net + new state test**

```bash
jag toit run tests/test_serialize_state.toit
jag toit run tests/test_models_via_json.toit
```
Expected: both green.

- [ ] **Step 6: Commit**

```bash
git add src/fuzzy_model.toit src/fuzzy_in_out.toit tests/test_update_term.toit
git commit -m "feat(engine): add FuzzyModel.update-term for live edits

Replaces the FuzzySet for a given (var, term) with a fresh one
constructed from (a, b, c, d). Throws on unknown var/term. Caller
runs fuzzify/defuzzify after to refresh state. Used by the RPC
layer's /term endpoint to support drag-edit handles in the viz."
```

---

### Task 9: New module `src/rpc_service.toit` — HTTP routes [SIMPLIFIED 2026-05-10]

> **Scope-reduction note:** Implement **only** `GET /model` and `GET /state`. Skip the three POST routes (`POST /model`, `POST /input`, `POST /term`) and their body-parsing blocks. View-only viz never calls them; dropping them removes the mutation-validation surface entirely.

**Files:** Create `src/rpc_service.toit`. Verify `examples/package.yaml` already has http+websocket (it does, per current state).

- [ ] **Step 1: Confirm http+websocket are already declared**

```bash
cat examples/package.yaml
```
Expected: `http` and `websocket` entries already present.

- [ ] **Step 2: Create `src/rpc_service.toit` (HTTP only — WebSocket lands in Task 10)**

```toit
// Copyright (c) 2026 Ekorau LLC

import encoding.json
import http
import net

import .fuzzy-model show FuzzyModel
import .json-loader show load-model

/**
Opt-in RPC layer over $FuzzyModel. Importing this module pulls
in http + encoding.json — engine consumers that don't need RPC
should import only fuzzy-logic and (optionally) json-loader.

Endpoints:

| Path     | Method | Body                  | Response               |
|----------|--------|-----------------------|------------------------|
| /model   | GET    |                       | current model topology |
| /model   | POST   | full model JSON       | { "ok": true }         |
| /input   | POST   | {var, value}          | { "ok": true }         |
| /term    | POST   | {var, term, a,b,c,d}  | { "ok": true }         |
| /state   | GET    |                       | model.serialize-state  |

Device + host run the same service; only the net.Interface differs.
*/
class RpcService:
  model_/FuzzyModel
  net_/net.Interface
  port/int

  constructor model/FuzzyModel network/net.Interface --port=8080:
    model_ = model
    net_ = network
    this.port = port

  start -> none:
    server := http.Server --max-tasks=4
    socket := net_.tcp-listen port
    server.listen socket:: | request/http.RequestIncoming response/http.ResponseWriter |
      handle_ request response

  handle_ request/http.RequestIncoming response/http.ResponseWriter -> none:
    method := request.method
    path := request.path
    if method == "GET" and path == "/model":
      respond-json_ response (model-topology_)
      return
    if method == "GET" and path == "/state":
      respond-json_ response model_.serialize-state
      return
    if method == "POST" and path == "/model":
      body := json.decode request.body.read-all
      // Replace in-memory model in place.
      new-model := load-model body
      model_ = new-model
      respond-json_ response {"ok": true}
      return
    if method == "POST" and path == "/input":
      body := json.decode request.body.read-all
      var-name := body["var"]
      value := body["value"]
      input-idx := -1
      model_.inputs.size.repeat: | i |
        if model_.inputs[i].name == var-name: input-idx = i
      if input-idx == -1: respond-error_ response 404 "unknown var '$var-name'"; return
      model_.crisp-input input-idx value.to-float
      model_.fuzzify
      respond-json_ response {"ok": true}
      return
    if method == "POST" and path == "/term":
      body := json.decode request.body.read-all
      model_.update-term body["var"] body["term"]
          body["a"] body["b"] body["c"] body["d"]
      // Re-fuzzify so /state reflects the change immediately.
      model_.fuzzify
      respond-json_ response {"ok": true}
      return
    respond-error_ response 404 "unknown route $method $path"

  model-topology_ -> Map:
    /// Returns the full {name, inputs, outputs, rules} shape, reflecting any
    /// update-term mutations (i.e., current term parameters).
    inputs := model_.inputs.map: | v | {"name": v.name,
        "terms": v.fsets.map: | s | {"name": s.name,
            "a": s.test-a, "b": s.test-b, "c": s.test-c, "d": s.test-d}}
    outputs := model_.outputs.map: | v | {"name": v.name,
        "terms": v.fsets.map: | s | {"name": s.name,
            "a": s.test-a, "b": s.test-b, "c": s.test-c, "d": s.test-d}}
    rules := model_.rules.map: | r | {
        "name": r.name,
        "weight": r.weight,
        // if/then trees aren't reconstructed here; clients use /model only for
        // names/parameters, not rule structure.
    }
    return {"name": model_.name, "inputs": inputs, "outputs": outputs, "rules": rules}

  respond-json_ response/http.ResponseWriter body/any -> none:
    response.headers.set "Content-Type" "application/json"
    response.write (json.encode body)

  respond-error_ response/http.ResponseWriter status/int message/string -> none:
    response.headers.set "Content-Type" "application/json"
    response.write-headers status
    response.write (json.encode {"error": message})
```

- [ ] **Step 3: Verify it compiles**

```bash
jag toit analyze src/rpc_service.toit
```
Expected: no errors. If any complaint about `http.RequestIncoming` / `http.ResponseWriter` shape, consult `~/.cache/jaguar/sdks/<ver>/lib/http/server.toit` and adjust call sites — keep external API stable.

- [ ] **Step 4: Run the existing suite (still green; no consumers yet)**

```bash
for f in tests/test_*.toit; do
  out=$(jag toit run "$f" 2>&1)
  echo "$f -> $(echo "$out" | tail -1)"
done
```
Expected: all green except the documented `test_api_usability.toit` flake.

- [ ] **Step 5: Commit**

```bash
git add src/rpc_service.toit
git commit -m "feat(rpc): RpcService HTTP routes over FuzzyModel

Opt-in module — engine consumers that don't import .rpc-service
pull in zero http/websocket/encoding.json deps. Routes /model
GET+POST, /input POST, /term POST, /state GET. Errors return JSON
{error}. WebSocket /ws lands next."
```

---

### Task 10: ~~Extend `RpcService` with WebSocket `/ws` push~~ [DROPPED 2026-05-10 — Dash polls `GET /state` instead]

**Files:** Modify `src/rpc_service.toit`.

The WebSocket carries bidirectional messages: client sends `{"input": {...}}` or `{"term": {...}}`; server responds with `{"state": <serialize-state>}` after every change (and on initial connect).

- [ ] **Step 1: Add the `/ws` route to `RpcService.handle_`**

Inside the `handle_` if-chain, before the final 404, add:

```toit
    if method == "GET" and path == "/ws":
      websocket := http.upgrade-websocket request response
      task:: handle-ws_ websocket
      return
```

(`http.upgrade-websocket` is the helper exposed by `pkg-http` 1.9.x. If absent, use `websocket.WebSocket.from-server` directly per `pkg-websocket`'s README.)

- [ ] **Step 2: Add `handle-ws_` method**

Append to the class:

```toit
  ws-clients_ := []   // active WebSocket sessions; broadcast pushes go to all.

  handle-ws_ ws/any -> none:
    ws-clients_.add ws
    // Send initial state.
    ws.send (json.encode {"state": model_.serialize-state})
    try:
      while true:
        frame := ws.receive
        if frame == null: return
        msg := json.decode frame
        apply-ws-message_ msg
        broadcast-state_
    finally:
      ws-clients_.remove ws

  apply-ws-message_ msg/Map -> none:
    if msg.contains "input":
      body := msg["input"]
      input-idx := -1
      model_.inputs.size.repeat: | i |
        if model_.inputs[i].name == body["var"]: input-idx = i
      if input-idx >= 0:
        model_.crisp-input input-idx body["value"].to-float
        model_.fuzzify
    if msg.contains "term":
      body := msg["term"]
      model_.update-term body["var"] body["term"]
          body["a"] body["b"] body["c"] body["d"]
      model_.fuzzify

  broadcast-state_ -> none:
    payload := json.encode {"state": model_.serialize-state}
    ws-clients_.do: | ws |
      catch: ws.send payload   // tolerate dead clients; cleanup happens on next receive.
```

Also update the http endpoints `/input` and `/term` so they call `broadcast-state_` after mutation, so HTTP and WS clients agree on state.

- [ ] **Step 3: Smoke-test the service end-to-end (manual; no automated test for the WS layer in this plan)**

Document the smoke procedure in a comment block at the top of `src/rpc_service.toit`:

```toit
/**
Smoke test (host mode):

1. Run examples/device.toit on host (binds 127.0.0.1:8080).
2. curl http://127.0.0.1:8080/model        → topology JSON
3. curl http://127.0.0.1:8080/state        → all pertinences zero
4. curl -X POST -d '{"var":"distance","value":35}' http://127.0.0.1:8080/input
5. curl http://127.0.0.1:8080/state        → fired rule reflected
6. websocat ws://127.0.0.1:8080/ws         → initial {state: ...} push;
   send {"input": {"var": "distance", "value": 70}} → next {state} reflects.
*/
```

- [ ] **Step 4: Verify compile + tests still green**

```bash
jag toit analyze src/rpc_service.toit
for f in tests/test_*.toit; do
  out=$(jag toit run "$f" 2>&1)
  echo "$f -> $(echo "$out" | tail -1)"
done
```
Expected: green except documented flake.

- [ ] **Step 5: Commit**

```bash
git add src/rpc_service.toit
git commit -m "feat(rpc): WebSocket /ws push for live state

On connect: server pushes {state}. Client may send
{input:{var,value}} or {term:{var,term,a,b,c,d}}; server applies
and re-broadcasts state to every connected client. HTTP /input and
/term mutations also broadcast so HTTP and WS stay in sync."
```

---

### Task 11: New example `examples/simple.toit`

**Files:** Create `examples/simple.toit`.

Minimum-deps demo: inline JSON literal, no RPC.

- [ ] **Step 1: Write `examples/simple.toit`**

```toit
// Copyright (c) 2026 Ekorau LLC
// Inline-JSON demo: smallest path to a defuzzified output. No RPC.

import fuzzy-logic show *
import fuzzy-logic.json-loader show load-model

MODEL ::= {
  "name": "tipper",
  "defuzz_method": "COG",
  "inputs": [
    {"name": "service", "terms": [
      {"name": "poor",      "a": 0, "b": 0, "c": 0, "d": 4},
      {"name": "good",      "a": 1, "b": 4, "c": 6, "d": 9},
      {"name": "excellent", "a": 6, "b": 9, "c": 9, "d": 9},
    ]},
  ],
  "outputs": [
    {"name": "tip", "terms": [
      {"name": "cheap",   "a": 0,  "b": 5,  "c": 5,  "d": 10},
      {"name": "average", "a": 10, "b": 15, "c": 15, "d": 20},
      {"name": "generous","a": 20, "b": 25, "c": 25, "d": 30},
    ]},
  ],
  "rules": [
    {"if": {"op": "is", "var": "service", "term": "poor"},      "then": [{"var": "tip", "term": "cheap"}]},
    {"if": {"op": "is", "var": "service", "term": "good"},      "then": [{"var": "tip", "term": "average"}]},
    {"if": {"op": "is", "var": "service", "term": "excellent"}, "then": [{"var": "tip", "term": "generous"}]},
  ],
}

main:
  model := load-model MODEL
  model.crisp-input 0 7.5
  model.fuzzify
  print "service=7.5 -> tip=$(%.2f model.defuzzify 0)"
```

- [ ] **Step 2: Run it**

```bash
jag toit run examples/simple.toit
```
Expected: output line `service=7.5 -> tip=<value>` (~16-19 depending on rule firing).

- [ ] **Step 3: Commit**

```bash
git add examples/simple.toit
git commit -m "feat(examples): add examples/simple.toit (inline-JSON demo)

Smallest path through the engine: inline Map literal → load-model
→ crisp-input → fuzzify → defuzzify. No RPC, no http/websocket
deps in the compiled image."
```

---

### Task 12: New example `examples/embedded.toit`

**Files:** Create `examples/embedded.toit`.

ESP32-friendly variant: model is a multi-line string (parsed once with `encoding.json`), no RPC.

- [ ] **Step 1: Write `examples/embedded.toit`**

```toit
// Copyright (c) 2026 Ekorau LLC
// Model as a text constant, parsed with encoding.json. ESP32-friendly:
// no http, no websocket. Suitable for shipping a model in a .toit binary.

import encoding.json
import fuzzy-logic show *
import fuzzy-logic.json-loader show load-model

MODEL ::= """
{
  "name": "container_crane",
  "inputs": [
    {"name": "distance", "terms": [
      {"name": "too_far", "a": -5, "b": -5, "c": -5, "d": 0},
      {"name": "zero",    "a": -5, "b":  0, "c":  0, "d": 5},
      {"name": "close",   "a":  0, "b":  5, "c":  5, "d": 10},
      {"name": "medium",  "a":  5, "b": 10, "c": 10, "d": 22},
      {"name": "far",     "a": 10, "b": 22, "c": 22, "d": 22}
    ]},
    {"name": "angle", "terms": [
      {"name": "neg_big",  "a": -50, "b": -50, "c": -50, "d": -5},
      {"name": "zero",     "a":  -5, "b":   0, "c":   0, "d":  5},
      {"name": "pos_big",  "a":   5, "b":  50, "c":  50, "d": 50}
    ]}
  ],
  "outputs": [
    {"name": "power", "terms": [
      {"name": "neg_high",  "a": -27, "b": -27, "c": -27, "d": -27},
      {"name": "zero",      "a":   0, "b":   0, "c":   0, "d":   0},
      {"name": "pos_high",  "a":  27, "b":  27, "c":  27, "d":  27}
    ]}
  ],
  "rules": [
    {"if": {"op": "and", "args": [
       {"op": "is", "var": "distance", "term": "far"},
       {"op": "is", "var": "angle",    "term": "zero"}
     ]}, "then": [{"var": "power", "term": "pos_high"}]}
  ]
}
"""

main:
  spec := json.parse MODEL
  model := load-model spec
  model.crisp-input 0 15.0   // distance
  model.crisp-input 1 0.0    // angle
  model.fuzzify
  print "(d=15, a=0) -> power=$(%.2f model.defuzzify 0)"
```

- [ ] **Step 2: Run it**

```bash
jag toit run examples/embedded.toit
```
Expected: a numeric output near +27 (rule fires fully).

- [ ] **Step 3: Commit**

```bash
git add examples/embedded.toit
git commit -m "feat(examples): add examples/embedded.toit (string-literal model)

Multi-line JSON string, parsed with encoding.json. Demonstrates
the ESP32-shipping pattern: model embedded in the binary, no
http/websocket dependencies pulled in."
```

---

### Task 13: New example `examples/device.toit` + cleanup [SIMPLIFIED 2026-05-10]

> **Scope-reduction note:** Keep `examples/models.toit` — four tests import it (`test_casco.toit`, `test_casco_runtime.toit`, `test_lecture_2.toit`, and the 31/0 regression net `test_models_via_json.toit` via `get-container-crane`). Only delete `examples/simple_01.toit` (no references). **Skip Steps 3, 4, and the second commit of Step 6.** Step-2 smoke test: drop the `curl -X POST /input` line — POST routes were removed in the simplified Task 9. Replace it with two `curl /state` calls bracketing a `model.fuzzify` invocation if you want to show state change (or just remove the POST line and verify `/model` + `/state` GET work).

**Files:** Create `examples/device.toit`. Delete `examples/simple_01.toit` and `examples/models.toit`.

Loads a JSON file (`fcl/generated/tipper.json`) and starts `RpcService` on `0.0.0.0:8080`. On the host, this is the smoke-test target for the viz; on a device, it serves the same HTTP+WS over the device's network interface.

- [ ] **Step 1: Write `examples/device.toit`**

```toit
// Copyright (c) 2026 Ekorau LLC
// Loads a JSON model from disk and starts RpcService on :8080.
// On host: smoke target for the Plotly Dash viz.
// On device: open the same port over the device's net interface.

import encoding.json
import fuzzy-logic show *
import fuzzy-logic.json-loader show load-model
import fuzzy-logic.rpc-service show RpcService
import host.file as file
import net

MODEL-PATH ::= "fcl/generated/tipper.json"

main:
  text := (file.Stream.for-read MODEL-PATH).read.to-string
  model := load-model (json.parse text)
  network := net.open
  service := RpcService model network --port=8080
  print "fuzzy_logic RpcService listening on :8080 (model=$model.name)"
  service.start
```

(For ESP32, `host.file` would be replaced with `assets`; that's beyond v1's scope. Document the swap in a comment.)

- [ ] **Step 2: Run it on host**

```bash
jag toit run examples/device.toit &
sleep 1
curl -s http://127.0.0.1:8080/model | head -c 300
curl -s -X POST -H 'Content-Type: application/json' \
  -d '{"var":"service","value":7.5}' http://127.0.0.1:8080/input
curl -s http://127.0.0.1:8080/state | head -c 300
kill %1
wait 2>/dev/null
```
Expected: `/model` returns the topology, `/input` returns `{"ok":true}`, `/state` shows non-zero pertinences for the `good` term and a non-zero crisp-out on `tip`.

- [ ] **Step 3: Delete obsolete examples**

```bash
git rm examples/simple_01.toit examples/models.toit
```

- [ ] **Step 4: Refactor casco tests off `examples/models.toit`**

`tests/test_casco.toit` and `tests/test_casco_runtime.toit` import `..examples.models` — both must be updated before deletion is committed. Delete the runtime smoke (it's a no-assertion timing print) and rewrite the asserted test to load from `fcl/generated/casco.json`:

```toit
// Copyright (c) 2026 Ekorau LLC

import btest show *
import encoding.json
import fuzzy-logic show *
import fuzzy-logic.json-loader show load-model
import host.file as file

main:
  test-start
  test "Casco" "loads from generated JSON":
    text := (file.Stream.for-read "fcl/generated/casco.json").read.to-string
    model := load-model (json.parse text)
    expect-true model.name == "casco"
  test-end
```

(Adjust the model-name assertion to whatever `fcl/generated/casco.json` actually reports.) Delete `tests/test_casco_runtime.toit`.

- [ ] **Step 5: Verify the suite is green after refactors**

```bash
for f in tests/test_*.toit; do
  out=$(jag toit run "$f" 2>&1)
  echo "$f -> $(echo "$out" | tail -1)"
done
```
Expected: all green except the documented `test_api_usability.toit` flake. The refactored `test_casco.toit` runs.

- [ ] **Step 6: Commit (two commits)**

```bash
git add examples/device.toit
git rm examples/simple_01.toit examples/models.toit
git commit -m "feat(examples): add examples/device.toit; drop obsolete examples

simple_01.toit and models.toit are replaced by simple.toit /
embedded.toit / device.toit (the JSON-loader trio). device.toit
loads fcl/generated/tipper.json and starts RpcService on :8080
for host-mode smoke-testing the visualizer."

git add tests/test_casco.toit
git rm tests/test_casco_runtime.toit
git commit -m "test(casco): load model from JSON instead of examples/models

examples/models.toit was deleted alongside the new JSON-based
examples; this test now loads fcl/generated/casco.json."
```

---

## Phase 8 — Plotly Dash visualizer + docs

### Task 14: `python/fuzzy_lab/viz/rpc.py` — HTTP client [SIMPLIFIED 2026-05-10]

> **Scope-reduction note:** HTTP polling only. Skip every WebSocket section and the `dash_extensions[websocket]` dep. The client surface is two methods: `get_model()` and `get_state()` — both plain `httpx.get` calls. No subscribe/reconnect logic. The original Task body's WS code blocks should be ignored entirely.

**Files:** Create `python/fuzzy_lab/viz/rpc.py`, `python/tests/test_viz_rpc.py`.

- [ ] **Step 1: Write the failing test**

```python
"""Tests for fuzzy_lab.viz.rpc — uses a small in-process HTTP fake
to verify the client speaks the protocol correctly."""

import asyncio
import json
import threading
from contextlib import contextmanager
from http.server import BaseHTTPRequestHandler, HTTPServer

import pytest

from fuzzy_lab.viz.rpc import FuzzyClient


class _Handler(BaseHTTPRequestHandler):
    state = {"calls": []}

    def _send(self, code, body):
        payload = json.dumps(body).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def log_message(self, *_): pass

    def do_GET(self):
        if self.path == "/model":
            self._send(200, {"name": "fake", "inputs": [], "outputs": [], "rules": []})
            return
        if self.path == "/state":
            self._send(200, {"inputs": [], "outputs": [], "rules": []})
            return
        self._send(404, {"error": "no"})

    def do_POST(self):
        n = int(self.headers.get("Content-Length", 0))
        body = json.loads(self.rfile.read(n))
        _Handler.state["calls"].append((self.path, body))
        self._send(200, {"ok": True})


@contextmanager
def fake_server():
    server = HTTPServer(("127.0.0.1", 0), _Handler)
    port = server.server_address[1]
    t = threading.Thread(target=server.serve_forever, daemon=True)
    t.start()
    try:
        yield f"http://127.0.0.1:{port}"
    finally:
        server.shutdown()


def test_get_model_and_state():
    with fake_server() as base:
        c = FuzzyClient(base.replace("http", "ws") + "/ws", http_base=base)
        m = asyncio.run(c.get_model())
        s = asyncio.run(c.get_state())
        assert m["name"] == "fake"
        assert s["inputs"] == []


def test_post_input():
    with fake_server() as base:
        c = FuzzyClient(base.replace("http", "ws") + "/ws", http_base=base)
        asyncio.run(c.post_input("service", 7.5))
        assert ("/input", {"var": "service", "value": 7.5}) in _Handler.state["calls"]
```

- [ ] **Step 2: Run, expect failure**

```bash
cd python && uv run pytest tests/test_viz_rpc.py -v
```
Expected: import error.

- [ ] **Step 3: Implement `python/fuzzy_lab/viz/rpc.py`**

```python
"""HTTP + WebSocket client for the Toit RpcService."""

from __future__ import annotations

import asyncio
import json
from typing import Any, AsyncIterator

import httpx
import websockets


class FuzzyClient:
    def __init__(self, ws_url: str, *, http_base: str | None = None):
        self.ws_url = ws_url
        self.http_base = http_base or _http_from_ws(ws_url)

    async def get_model(self) -> dict[str, Any]:
        async with httpx.AsyncClient() as h:
            r = await h.get(f"{self.http_base}/model")
            r.raise_for_status()
            return r.json()

    async def get_state(self) -> dict[str, Any]:
        async with httpx.AsyncClient() as h:
            r = await h.get(f"{self.http_base}/state")
            r.raise_for_status()
            return r.json()

    async def post_input(self, var: str, value: float) -> None:
        async with httpx.AsyncClient() as h:
            r = await h.post(f"{self.http_base}/input", json={"var": var, "value": value})
            r.raise_for_status()

    async def post_term(self, var: str, term: str, a: float, b: float, c: float, d: float) -> None:
        async with httpx.AsyncClient() as h:
            r = await h.post(f"{self.http_base}/term",
                             json={"var": var, "term": term, "a": a, "b": b, "c": c, "d": d})
            r.raise_for_status()

    async def stream_state(self) -> AsyncIterator[dict[str, Any]]:
        """Connect /ws, yield successive state pushes. Caller handles reconnect."""
        async with websockets.connect(self.ws_url) as ws:
            async for raw in ws:
                msg = json.loads(raw)
                if "state" in msg:
                    yield msg["state"]


def _http_from_ws(ws_url: str) -> str:
    if ws_url.startswith("wss://"):
        return "https://" + ws_url[len("wss://"):].rsplit("/", 1)[0]
    if ws_url.startswith("ws://"):
        return "http://" + ws_url[len("ws://"):].rsplit("/", 1)[0]
    raise ValueError(f"unrecognised ws url: {ws_url}")
```

- [ ] **Step 4: Run, expect pass**

```bash
cd python && uv run pytest tests/test_viz_rpc.py -v
```
Expected: 2 passed.

- [ ] **Step 5: Commit**

```bash
git add python/fuzzy_lab/viz/rpc.py python/tests/test_viz_rpc.py
git commit -m "feat(viz): HTTP+WebSocket client for the Toit RpcService

FuzzyClient wraps GET /model, GET /state, POST /input, POST /term
over httpx, plus an async stream_state() generator over a /ws
connection. Reconnect logic lives one layer up, in app.py."
```

---

### Task 15: `python/fuzzy_lab/viz/plots.py` — figure builders

**Files:** Create `python/fuzzy_lab/viz/plots.py`, `python/tests/test_viz_plots.py`.

- [ ] **Step 1: Write the failing test**

```python
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
    # One trace per term (closed polygon) plus one for the crisp marker line.
    assert len(fig.data) == 4   # 3 terms + 1 vertical line


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
```

- [ ] **Step 2: Run, expect failure**

```bash
cd python && uv run pytest tests/test_viz_plots.py -v
```
Expected: import error.

- [ ] **Step 3: Implement `python/fuzzy_lab/viz/plots.py`**

```python
"""Plotly figure builders. All figures are pure functions of (FuzzyVar, var-state)."""

from __future__ import annotations

import plotly.graph_objects as go

from fuzzy_lab.schema import FuzzyVar


def membership_figure(var: FuzzyVar, state: dict) -> go.Figure:
    """Membership polygons for one input. Crisp value rendered as a vertical line."""
    fig = go.Figure()
    for term in var.terms:
        pertinence = next((t["pertinence"] for t in state["terms"] if t["name"] == term.name), 0.0)
        # Draw the trapezoid even when pertinence==0 so the user sees the topology.
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
    fig.update_layout(title=var.name, height=260, margin=dict(l=40, r=10, t=30, b=30),
                      yaxis=dict(range=[0, 1.05]))
    return fig


def output_figure(var: FuzzyVar, state: dict) -> go.Figure:
    """Output figure: stacked term polygons, truncated by pertinence; centroid line."""
    fig = go.Figure()
    for term in var.terms:
        pertinence = next((t["pertinence"] for t in state["terms"] if t["name"] == term.name), 0.0)
        # Show the full term outline.
        fig.add_trace(go.Scatter(
            x=[term.a, term.b, term.c, term.d],
            y=[0, 1, 1, 0],
            mode="lines",
            name=f"{term.name}",
            fill="toself",
            opacity=0.2,
            line=dict(width=1),
        ))
        # And the truncated polygon (the part that contributed to defuzzify).
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
    fig.update_layout(title=var.name, height=260, margin=dict(l=40, r=10, t=30, b=30),
                      yaxis=dict(range=[0, 1.05]))
    return fig
```

- [ ] **Step 4: Run, expect pass**

```bash
cd python && uv run pytest tests/test_viz_plots.py -v
```
Expected: 2 passed.

- [ ] **Step 5: Commit**

```bash
git add python/fuzzy_lab/viz/plots.py python/tests/test_viz_plots.py
git commit -m "feat(viz): membership + output Plotly figure builders

Pure functions of (FuzzyVar, runtime-state). Membership figure
draws every term as a translucent polygon; current pertinence
darkens the active term; crisp input renders as a vertical dashed
line. Output figure overlays truncated polygons (the bit that fed
the centroid) on the term outlines and marks the centroid in red."
```

---

### Task 16: `python/fuzzy_lab/viz/app.py` + `__main__.py` — Dash layout [SIMPLIFIED 2026-05-10]

> **Scope-reduction note:** View-only layout. Use `dcc.Interval` (~500 ms) to poll `GET /state` and refresh figure overlays (crisp markers + per-term pertinence). Drop: edit textarea, "apply" button, `POST /term` calls, WebSocket subscribe component, drag-handle wiring. MF curves come from `GET /model` (fetched once on load, or whenever `/state` shows a model-revision change — simplest: once on load).

**Files:** Create `python/fuzzy_lab/viz/app.py`, `python/fuzzy_lab/viz/__main__.py`.

This task wires the figures into a Dash app, sets up the WebSocket subscription, sliders that POST `/input`, and plot-edit handlers that POST `/term`. It is the largest single file in the plan; tests cover only the pure logic — Dash callbacks are exercised manually.

- [ ] **Step 1: Implement `python/fuzzy_lab/viz/app.py`**

```python
"""Plotly Dash app that visualises a running FuzzyModel.

Layout (top to bottom):
  - Header: model name + connection status
  - Inputs row: one panel per input (membership figure + slider)
  - Rules row: list of rule names; fired rules highlighted
  - Outputs row: one panel per output (output figure + crisp value)
"""

from __future__ import annotations

import asyncio
import json
import threading
from dataclasses import dataclass

import dash
from dash import Input, Output, State, dcc, html
from dash_extensions.enrich import DashProxy
from dash_extensions import WebSocket

from fuzzy_lab.schema import Model
from fuzzy_lab.viz.plots import membership_figure, output_figure
from fuzzy_lab.viz.rpc import FuzzyClient


@dataclass
class AppConfig:
    ws_url: str
    http_base: str


def build_app(config: AppConfig, model: Model, initial_state: dict) -> dash.Dash:
    app = DashProxy(__name__, suppress_callback_exceptions=True)

    app.layout = html.Div([
        html.H2(id="header", children=f"{model.name} (defuzz: {model.defuzz_method})"),
        html.Div(id="conn-status", children="connecting…",
                 style={"color": "orange", "fontStyle": "italic"}),
        WebSocket(id="ws", url=config.ws_url),
        dcc.Store(id="state-store", data=initial_state),

        html.H3("Inputs"),
        html.Div(id="inputs-row", children=[
            html.Div([
                dcc.Graph(id={"type": "in-fig", "var": v.name},
                          figure=membership_figure(v, _var_state(initial_state, "inputs", v.name))),
                dcc.Slider(id={"type": "in-slider", "var": v.name},
                           min=min(t.a for t in v.terms), max=max(t.d for t in v.terms),
                           step=0.1,
                           value=_var_state(initial_state, "inputs", v.name).get("crisp", 0.0)),
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


def _register_callbacks(app, config, model):
    @app.callback(
        Output("state-store", "data"),
        Output("conn-status", "children"),
        Output("conn-status", "style"),
        Input("ws", "message"),
    )
    def on_ws(message):
        if not message:
            raise dash.exceptions.PreventUpdate
        msg = json.loads(message["data"])
        return msg["state"], "connected", {"color": "green"}

    @app.callback(
        Output("rules-list", "children"),
        Input("state-store", "data"),
    )
    def render_rules(state):
        items = []
        for r in state["rules"]:
            style = {"fontWeight": "bold"} if r["fired"] else {}
            items.append(html.Li(r["name"], style=style))
        return items

    for v in model.inputs:
        var_name = v.name

        @app.callback(
            Output({"type": "in-fig", "var": var_name}, "figure"),
            Input("state-store", "data"),
            State({"type": "in-fig", "var": var_name}, "figure"),
            prevent_initial_call=False,
        )
        def update_input(state, _prev, _v=v):
            return membership_figure(_v, _var_state(state, "inputs", _v.name))

        @app.callback(
            Output({"type": "in-slider", "var": var_name}, "value"),
            Input({"type": "in-slider", "var": var_name}, "value"),
            prevent_initial_call=True,
        )
        def push_input(value, _v=v):
            asyncio.run(_post_input(config.http_base, _v.name, value))
            return value

    for v in model.outputs:
        var_name = v.name

        @app.callback(
            Output({"type": "out-fig", "var": var_name}, "figure"),
            Input("state-store", "data"),
            prevent_initial_call=False,
        )
        def update_output(state, _v=v):
            return output_figure(_v, _var_state(state, "outputs", _v.name))


async def _post_input(http_base, var, value):
    client = FuzzyClient(ws_url="ws://placeholder/ws", http_base=http_base)
    await client.post_input(var, value)
```

- [ ] **Step 2: Implement `python/fuzzy_lab/viz/__main__.py`**

```python
"""fuzzy-lab CLI: launch the Dash visualizer pointed at an RpcService."""

import argparse
import asyncio
import sys

from fuzzy_lab.schema import Model
from fuzzy_lab.viz.app import AppConfig, build_app
from fuzzy_lab.viz.rpc import FuzzyClient


def main(argv=None):
    p = argparse.ArgumentParser(prog="fuzzy-lab")
    p.add_argument("--connect", default="ws://127.0.0.1:8080/ws",
                   help="WebSocket URL of the RpcService")
    p.add_argument("--port", type=int, default=8050, help="Dash port")
    args = p.parse_args(argv)

    client = FuzzyClient(args.connect)
    try:
        model_dict = asyncio.run(client.get_model())
        state = asyncio.run(client.get_state())
    except Exception as exc:
        print(f"fuzzy-lab: failed to fetch /model: {exc}", file=sys.stderr)
        return 1

    model = Model.from_dict(model_dict)
    config = AppConfig(ws_url=args.connect, http_base=client.http_base)
    app = build_app(config, model, state)
    app.run(debug=False, host="127.0.0.1", port=args.port)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
```

- [ ] **Step 3: Re-sync entry points**

```bash
cd python && uv sync --all-extras
```

- [ ] **Step 4: Manual smoke-test (no automated test for the Dash callbacks)**

```bash
# Terminal 1: start the Toit service.
jag toit run examples/device.toit

# Terminal 2: launch the viz against it.
cd python && uv run fuzzy-lab --connect ws://127.0.0.1:8080/ws

# Browser: open http://127.0.0.1:8050/.
# Verify: model name in header, three input panels (service/food/—), one output, sliders move the input crisp value, output panel updates.
```

- [ ] **Step 5: Commit**

```bash
git add python/fuzzy_lab/viz/app.py python/fuzzy_lab/viz/__main__.py
git commit -m "feat(viz): Plotly Dash app with WebSocket state stream

build_app produces a single-page layout: header, inputs row with
slider per input, rules list (fired in bold), outputs row.
WebSocket pushes update the state Store on every server change;
slider moves POST /input. Drag-edit lands in the next commit."
```

---

### Task 17: ~~WebSocket reconnect with backoff + drag-handle support~~ [DROPPED 2026-05-10 — neither WS nor editing in scope]

**Files:** Modify `python/fuzzy_lab/viz/app.py`.

`dash_extensions.WebSocket` reconnects automatically with internal logic; the additional work is grey-out on disconnect and routing Plotly's drag-edit events back to `/term`.

- [ ] **Step 1: Add disconnect detection**

In `app.py`, register a callback on `ws.state` (provided by `dash_extensions.WebSocket`):

```python
    @app.callback(
        Output("conn-status", "children", allow_duplicate=True),
        Output("conn-status", "style", allow_duplicate=True),
        Input("ws", "state"),
        prevent_initial_call=True,
    )
    def on_ws_state(s):
        # 1=open, 2=closing, 3=closed.
        if s in (None, 3):
            return "disconnected — reconnecting…", {"color": "red"}
        if s == 1:
            return "connected", {"color": "green"}
        raise dash.exceptions.PreventUpdate
```

- [ ] **Step 2: Add a manual term-edit panel per input (deliberate scope reduction vs spec)**

The spec calls for Plotly drag handles on the membership polygons (`editable: true` shapes → `relayoutData` callbacks → `/term` POST). After the rest of the pipeline is in place (server `/term`, RPC client, schema), implementing this is mostly Plotly bookkeeping but is fiddly enough — mapping `relayoutData` keys like `shapes[0].x0` back to `(var, term, a, b, c, d)` — that it deserves its own pass. For v1 close-out we land a manual control instead.

Under each input's membership figure in `app.py`, add an inputs row (`html.Details` with a small form):

```python
            html.Details([
                html.Summary("edit terms"),
                html.Div([
                    html.Div([
                        html.Label(f"{t.name}:"),
                        dcc.Input(id={"type": "term-edit", "var": v.name, "term": t.name},
                                  value=f"{t.a},{t.b},{t.c},{t.d}",
                                  style={"width": "180px"}),
                        html.Button("apply",
                                    id={"type": "term-apply", "var": v.name, "term": t.name},
                                    n_clicks=0),
                    ]) for t in v.terms
                ])
            ]),
```

Then wire the apply buttons:

```python
        for term in v.terms:
            term_name = term.name
            @app.callback(
                Output({"type": "term-edit", "var": var_name, "term": term_name}, "value"),
                Input({"type": "term-apply", "var": var_name, "term": term_name}, "n_clicks"),
                State({"type": "term-edit", "var": var_name, "term": term_name}, "value"),
                prevent_initial_call=True,
            )
            def apply_term(_n, value, _v=var_name, _t=term_name):
                a, b, c, d = (float(x) for x in value.split(","))
                asyncio.run(_post_term(config.http_base, _v, _t, a, b, c, d))
                return value
```

Add the helper at module level (next to `_post_input`):

```python
async def _post_term(http_base, var, term, a, b, c, d):
    client = FuzzyClient(ws_url="ws://placeholder/ws", http_base=http_base)
    await client.post_term(var, term, a, b, c, d)
```

Drag-handle support is a v1.1 follow-up.

Document the deviation in `CHANGELOG.md`'s 0.7.0 section under a "Known limitations" sub-bullet (Task 19 picks this up).

- [ ] **Step 3: Manual smoke-test**

Re-run the smoke-test from Task 16 Step 4. Pull the network plug on the Toit side; observe the banner go red and recover when reconnected.

- [ ] **Step 4: Commit**

```bash
git add python/fuzzy_lab/viz/app.py
git commit -m "feat(viz): connection-state banner + term-edit hookup

WebSocket state changes drive a green/red banner. Term-edit is a
manual textarea + button per input (drag-handle routing is a
v1.1 follow-up — Plotly's relayoutData mapping for editable
shapes is fiddly enough to deserve its own pass)."
```

---

### Task 18: README rewrite

**Files:** Modify `README.md`.

The current `README.md` has Plan-A-era flag comments (`pre-restructure section: broken`). Rewrite around the FCL → JSON → engine → viz pipeline.

- [ ] **Step 1: Read the current README to understand what to preserve**

```bash
cat README.md | head -80
```

Note any author / license attribution that must survive the rewrite.

- [ ] **Step 2: Replace `README.md` with a fresh document**

```markdown
# fuzzy_logic

A Toit fuzzy inference engine for ESP32 and host environments. Loads models from JSON literals or files, evaluates fuzzy rules, and (optionally) exposes a live HTTP+WebSocket API for a Plotly Dash visualizer.

## Installation

In your Toit project's `package.yaml`:

```yaml
dependencies:
  fuzzy-logic:
    url: github.com/<owner>/fuzzy_logic
    version: ^0.7.0
```

Then `jag toit pkg install`.

## Minimal example

```toit
import fuzzy-logic show *
import fuzzy-logic.json-loader show load-model

MODEL ::= {
  "name": "tipper",
  "inputs":  [{"name":"service","terms":[{"name":"good","a":1,"b":4,"c":6,"d":9}]}],
  "outputs": [{"name":"tip",    "terms":[{"name":"average","a":10,"b":15,"c":15,"d":20}]}],
  "rules":   [{"if":{"op":"is","var":"service","term":"good"},
              "then":[{"var":"tip","term":"average"}]}],
}

main:
  model := load-model MODEL
  model.crisp-input 0 5.0
  model.fuzzify
  print "tip = $(%.2f model.defuzzify 0)"
```

This pulls in only the engine + JSON loader. No HTTP, no WebSocket.

## Authoring models in FCL

Hand-write `.fcl` files using the standard subset (FUNCTION_BLOCK, VAR_INPUT/OUTPUT, FUZZIFY/DEFUZZIFY with `trape` / `trian` / point-list / singleton TERMs, RULEBLOCK with `IF/THEN/WITH`). Convert with the Python tool:

```
cd python && uv sync --all-extras
uv run fcl2json ../fcl/tipper.fcl > ../fcl/generated/tipper.json
uv run fcl2json --all ../fcl --out-dir ../fcl/generated
```

The Toit engine consumes the generated JSON via `load-model`.

## Live visualization

Start the RPC service alongside your model:

```toit
import fuzzy-logic.rpc-service show RpcService
…
service := RpcService model network --port=8080
service.start
```

Then run the Dash visualizer:

```
cd python && uv run fuzzy-lab --connect ws://<device-ip>:8080/ws
```

Open `http://127.0.0.1:8050/` — sliders move crisp inputs, the rules list highlights firing rules, output centroids update in real time.

## Repository layout

```
src/                 Toit engine modules (closed-form centroid math, JSON loader, RPC service)
fcl/                 Hand-written FCL source files
fcl/generated/       Generated JSON artifacts (committed)
examples/            Three runnable examples (simple / embedded / device)
tests/               Toit test suite (btest)
python/              fuzzy_lab — fcl2json + Plotly Dash viz
docs/superpowers/    Specs and implementation plans
```

## Versioning

Semantic-ish. Plan-A-era 0.6.x removed geometry helpers from the public API; 0.7.0 adds the JSON loader, NOT/weight, RPC service, and Python tooling.

## License

See `LICENSE`. Engine math derives from work originally licensed under `LICENSE_ALVES` and `LICENSE_Toitware`; both licenses preserved.
```

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "docs: rewrite README around the FCL → JSON → engine → viz pipeline"
```

---

### Task 19: Bump version + CHANGELOG

**Files:** Modify `package.yaml`, `CHANGELOG.md`.

- [ ] **Step 1: Add version to `package.yaml`**

```yaml
# Toit Package File.
name: fuzzy_logic
description: A library for running fuzzy logic algorithms
version: 0.7.0
```

- [ ] **Step 2: Update `CHANGELOG.md`** — prepend a `## 0.7.0 — 2026-05-XX` section

```markdown
## 0.7.0 — 2026-05-XX

**Engine**
- Closed-form centroid math per FuzzySet subclass (replaces the polygon-based approach in 0.6.x).
- `Antecedent.fl-not` and `FuzzyRule.weight`.
- `FuzzyModel.serialize-state` and `FuzzyModel.update-term`.
- New module `fuzzy-logic.json-loader` (`load-model map -> FuzzyModel`); zero http/websocket/encoding.json deps.
- New module `fuzzy-logic.rpc-service` (`RpcService`); opt-in import — pulls http + websocket + encoding.json.

**Tooling (Python)**
- `fcl2json` console script: convert `.fcl` files to the engine's JSON schema.
- `fuzzy-lab` console script: Plotly Dash visualizer over the RpcService.

**Removed (breaking)**
- `src/geometry.toit` (Point2f, intersection, Stack, polar-sort, etc.).
- SVG helpers in `src/composition.toit`.
- `polyline`, `truncated-polygon`, `truncator-l/r`, `graph-points`, polygon-based `truncated-area`/`centroid-x_` in `src/fuzzy_set.toit`.
- `examples/fuzzy_view*.toit`, `examples/server.toit`, `examples/test.toit`, `examples/advanced_01.toit`, `examples/models.toit`, `examples/simple_01.toit`.
- Stale tests using pre-rename API surfaces.

**Other**
- `examples_fcl/` renamed to `fcl/`; generated JSON committed to `fcl/generated/`.
- Cleaned out `.aider.*`, `shelley.db*`, `outputs.png`, `docs/todo.md`, `llms/`.

**Known limitations (v1)**
- Visualizer term editing is a manual textarea+apply control. Plotly drag-handle support is deferred to v1.1.
- Only `COG` defuzzification is honored. Non-COG `METHOD:` values in `.fcl` produce a stderr warning at conversion time and are recorded in the JSON's `defuzz_method` field for forward compat.
- One `RULEBLOCK` per `FUNCTION_BLOCK`. Per-rule `ACT` and per-block `AND`/`OR` operator overrides are accepted-and-discarded by the parser.
```

- [ ] **Step 3: Commit**

```bash
git add package.yaml CHANGELOG.md
git commit -m "release: 0.7.0 — JSON loader, NOT+weight, RPC service, Python tooling

Major version step. Breaks: geometry.toit and SVG helpers removed
from the public surface; six dead examples deleted. Adds: JSON
loader, NOT/weight, serialize-state, update-term, RpcService,
fcl2json + Plotly Dash visualizer (Python)."
```

---

### Task 20: Final green-board confirmation

**Files:** none.

- [ ] **Step 1: Run the Toit test suite**

```bash
for f in tests/test_*.toit; do
  out=$(jag toit run "$f" 2>&1)
  echo "$f -> $(echo "$out" | tail -1)"
done
```
Expected: all green except the documented `test_api_usability.toit` flake (3 cases). The new tests `test_serialize_state`, `test_update_term` pass; the regression net `test_models_via_json.toit` is 31/0.

- [ ] **Step 2: Run the Python test suite**

```bash
cd python && uv run pytest -v
```
Expected: every test passes.

- [ ] **Step 3: Manual end-to-end smoke**

```bash
# Terminal 1
jag toit run examples/device.toit

# Terminal 2
cd python && uv run fuzzy-lab --connect ws://127.0.0.1:8080/ws
# Browser: http://127.0.0.1:8050/
# Move a slider → output centroid updates.
```

- [ ] **Step 4: Verify deliverables checklist**

```
[ ] python/ project compiles + tests green via uv
[ ] fcl/generated/ has one .json per .fcl
[ ] src/rpc_service.toit exists, opt-in (engine consumers don't pull in http)
[ ] examples/simple.toit, examples/embedded.toit, examples/device.toit run
[ ] examples/simple_01.toit and examples/models.toit removed
[ ] package.yaml has version: 0.7.0
[ ] CHANGELOG.md has a 0.7.0 section
[ ] README.md rewritten around the new pipeline
[ ] No new geometry / SVG vocabulary leaked into src/
```

- [ ] **Step 5: No commit needed (verification only)**

---

## Plan-end checklist

After all 20 tasks land:

- `git log --oneline master..HEAD` shows ~20-25 focused commits since the Plan-A merge tip.
- `tests/` directory contains: `test_engine_features.toit`, `test_closed_form_centroid.toit`, `test_json_loader.toit`, `test_models_via_json.toit`, `test_serialize_state.toit`, `test_update_term.toit`, `test_geometry.toit`, `test_integration.toit`, `test_lecture_*.toit`, `test_api_usability.toit`, plus the (possibly rewritten) `test_casco.toit`. All green except the flake.
- `python/` is a self-contained `uv` project; `pytest` green.
- `fcl/generated/` contains one `.json` per `.fcl`.
- `examples/` contains `simple.toit`, `embedded.toit`, `device.toit` only (plus the `package.yaml`/`package.lock`).
- `package.yaml` declares `version: 0.7.0`.
- `README.md` and `CHANGELOG.md` reflect the new shape.

Hand off to release: tag `0.7.0`, push, announce.
