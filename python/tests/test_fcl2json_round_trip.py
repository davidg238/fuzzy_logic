"""Round-trip every .fcl through fcl2json + the Toit json_loader.

Subprocess-driven: runs `fcl2json --all` once, then for each generated JSON
spins up a tiny Toit harness via `jag toit run` that calls
`load-model`, `crisp-input`, `fuzzify`, and `defuzzify`. Exit 0 means the
schema emitted by Python is consumable by the engine without raising.

Files using membership functions unsupported in v1 (gbell/gauss/sigm or
non-trapezoidal point-lists) are excluded — `fcl2json --all` skips them
with a stderr warning, so the test must mirror that.
"""

from __future__ import annotations

import json
import subprocess
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parents[2]
PYTHON_DIR = REPO_ROOT / "python"
FCL_DIR = REPO_ROOT / "fcl"

# fcl/unsupported/ is excluded by non-recursive glob; every .fcl directly under
# fcl/ is round-trip-convertible to JSON.
SUPPORTED_FCL = sorted(FCL_DIR.glob("*.fcl"))


@pytest.fixture(scope="module")
def generated_dir(tmp_path_factory):
    out = tmp_path_factory.mktemp("generated")
    rc = subprocess.run(
        ["uv", "run", "fcl2json", "--all", str(FCL_DIR), "--out-dir", str(out)],
        cwd=PYTHON_DIR, capture_output=True, text=True,
    )
    assert rc.returncode == 0, rc.stderr
    return out


@pytest.fixture(scope="module")
def harness_dir(tmp_path_factory):
    d = tmp_path_factory.mktemp("harness")
    (d / "package.yaml").write_text(
        f"dependencies:\n  fuzzy-logic:\n    path: {REPO_ROOT}\n"
    )
    rc = subprocess.run(
        ["jag", "toit", "pkg", "install"],
        cwd=d, capture_output=True, text=True, timeout=60,
    )
    assert rc.returncode == 0, rc.stderr
    return d


# Toit triple-quoted strings end only at a literal `"""`, which JSON output
# never produces — so the JSON body can be embedded verbatim. Placeholders
# use `__NAME__` (not `{name}`) because JSON contains literal `{` / `}`.
_HARNESS_TEMPLATE = '''\
import encoding.json
import fuzzy-logic show *
import fuzzy-logic.json-loader show load-model

JSON-TEXT ::= """
__JSON_TEXT__
"""

main:
  spec := json.parse JSON-TEXT
  model := load-model spec
  inputs := [__CRISP_ARGS__]
  inputs.size.repeat: | i | model.crisp-input i inputs[i]
  model.fuzzify
  model.outputs.size.repeat: | i | model.defuzzify i
'''


@pytest.mark.parametrize("fcl_path", SUPPORTED_FCL, ids=[p.stem for p in SUPPORTED_FCL])
def test_round_trip(fcl_path, generated_dir, harness_dir):
    json_path = generated_dir / f"{fcl_path.stem}.json"
    assert json_path.exists(), f"converter did not emit {fcl_path.stem}.json"

    spec = json.loads(json_path.read_text())
    assert spec["name"]
    assert "inputs" in spec and "outputs" in spec and "rules" in spec

    crisp_args = ", ".join(["0.0"] * len(spec["inputs"]))
    harness = harness_dir / "main.toit"
    harness.write_text(
        _HARNESS_TEMPLATE
        .replace("__JSON_TEXT__", json_path.read_text())
        .replace("__CRISP_ARGS__", crisp_args)
    )
    rc = subprocess.run(
        ["jag", "toit", "run", str(harness)],
        cwd=harness_dir, capture_output=True, text=True, timeout=60,
    )
    assert rc.returncode == 0, (
        f"{fcl_path.name} failed:\nstdout={rc.stdout}\nstderr={rc.stderr}"
    )
