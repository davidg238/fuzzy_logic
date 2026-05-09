# Toit Engine Restructure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Trim dead code, swap polygon-based centroid math for closed-form per-type math, extend the engine with `NOT` antecedents and rule weights, and add a JSON model loader. End state is a clean Toit-only engine that can load any of the existing six hand-coded models from a JSON literal and produce identical defuzzified outputs.

**Architecture:** Single `fuzzy_logic` Toit package. Engine modules in `src/` with no public geometry vocabulary. JSON loader is a new module that builds engine objects from a `Map`, with no transitive http/websocket/encoding.json dependencies — embeddable use cases pay zero RPC cost. RPC service and Python tooling are out of scope for this plan (Plan B).

**Tech Stack:** Toit (engine, tests), `btest` test framework. Test runner: `jag toit run tests/<file>.toit` (the `toit` CLI is bundled with `jag`).

## Baseline (verified 2026-05-08, branch `worktree-restructure-engine`)

| Test file | Status before plan starts |
|---|---|
| `tests/test_casco.toit` | PASSES (9/9 cases) — uses current API, golden numbers |
| `tests/test_casco_runtime.toit` | runs (print-only, no asserts) |
| `tests/test_geometry.toit` | PASSES (10/10 cases) — centroid behavior, no Point2f imports |
| `tests/test_lecture_1.toit` | PASSES (5/5 cases) — uses current API |
| `tests/test_lecture_2.toit` | PASSES (1/1 case) — uses current API |
| `tests/test_api_usability.toit` | partial (7/9 pass) — uses current API |
| `tests/test_integration.toit` | partial (22/25 pass) — uses current API |
| `tests/test_all_additional.toit` | compile fail (pre-rename API) |
| `tests/test_edge_cases.toit` | compile fail (hallucinated API: `composition.union`, `set.truncated`) |
| `tests/test_fuzzy_lib.toit` | compile fail + throws on entry |
| `tests/test_general.toit` | compile fail (pre-rename API: `Antecedent-And`) |
| `tests/test_performance.toit` | compile fail (hallucinated API: `output.sets[i]` indexing) |
| `tests/test_validation.toit` | compile fail (hallucinated API: `composition.union`, `set.truncated`) |
| `tests/test09.toit` | not yet checked — assumed legacy |

**Spec:** [`docs/superpowers/specs/2026-05-08-fuzzy-logic-restructure-design.md`](../specs/2026-05-08-fuzzy-logic-restructure-design.md)

---

## Out of scope for this plan (Plan B will cover)

- Python `fcl2json` converter
- `src/rpc_service.toit`, `serialize-state`, `update-term`
- `examples/simple.toit`, `examples/embedded.toit`, `examples/device.toit`
- README rewrite, CHANGELOG, version bump

---

## File Structure

**Files created:**
- `src/json_loader.toit` — `load-model map/Map -> FuzzyModel`. Pure Map-to-objects construction. No http/websocket/encoding.json imports.
- `tests/test_closed_form_centroid.toit` — per-set-type centroid math
- `tests/test_json_loader.toit` — schema feature coverage (every `op`, NOT, weights, multi-output consequents)
- `tests/test_engine_features.toit` — `Antecedent.fl-not` and `FuzzyRule.weight`
- `tests/test_models_via_json.toit` — round-trip every hand-coded model via JSON literals (smoke test pinning behavior across Phase 4)

**Files modified:**
- `src/antecedent.toit` — add `AntecedentNot` + `Antecedent.fl-not`
- `src/fuzzy_rule.toit` — add `weight/float := 1.0` field, multiply in `evaluate`
- `src/fuzzy_set.toit` — replace polygon-based `truncated-area`/`truncated-weighted-centroid` with closed-form; delete `polyline`, `truncated-polygon`, `truncator-l/r`, `graph-points`, `centroid-x_`, `clear-geometry-cache`, `pts_`, `area_`, `truncate`
- `src/composition.toit` — simplify `centroid-x`; delete SVG helpers (`set-names`, `centroid-line`, `set-polylines`, `svg-polyline_`, `scale-svg-polyline_`)
- `src/fuzzy_logic.toit` — drop `import .geometry` re-export

**Files deleted:**
- `src/geometry.toit` (entire file, ~184 lines)
- `examples/fuzzy_view.toit`, `fuzzy_view2.toit`, `fuzzy_view3.toit`
- `examples/server.toit`, `examples/test.toit`, `examples/advanced_01.toit`
- `examples/fcl.ohm`, `examples/fuzzy_language.ohm` (Ohm grammars superseded by Python Lark in Plan B)
- `tests/test_fuzzy_lib.toit` (compile fail + throws on entry)
- `tests/test_general.toit` (uses pre-rename API: `Antecedent-And`, `add-all-sets`, untyped `FuzzyInput "name"`)
- `tests/test_validation.toit` (compile fail, hallucinated API: `composition.union`, `set.truncated`, `is_fired` argument shape, `crisp_in =` setter)
- `tests/test_edge_cases.toit` (compile fail, hallucinated API: `calculate_set_pertinences`, `crisp_in =` setter, `set.truncated`)
- `tests/test_performance.toit` (compile fail, hallucinated API: `output.sets[i]` list indexing)
- `tests/test09.toit` (legacy)
- `tests/test_all_additional.toit`, `tests/ADDITIONAL_TESTS.md` (audit in Phase 5)
- `tests/casco.toit` (script-style print-only tests; replaced by JSON-based equivalent)

**Tests preserved (passing or near-passing under current API):**
- `tests/test_casco.toit`, `tests/test_casco_runtime.toit`, `tests/test_geometry.toit`, `tests/test_lecture_1.toit`, `tests/test_lecture_2.toit` — all keep passing through Phase 4. `test_api_usability.toit` and `test_integration.toit` are partial; Phase 5 audits and either fixes or deletes them.
- `docs/todo.md`
- `llms/instructions-long.md`, `llms/sketch-setup.md`
- `.aider.chat.history.md`, `.aider.input.history`, `.aider.tags.cache.v4/`
- `shelley.db`, `shelley.db-shm`, `shelley.db-wal`, `outputs.png`

**Files renamed:**
- `examples_fcl/` → `fcl/`

**Files preserved through this plan (cleaned in Plan B):**
- `examples/models.toit` — Phase 3 tests use it as the golden source. Plan B deletes it after JSON path is canonical.
- `examples/simple_01.toit` — smoke-test runner. Plan B replaces with `examples/simple.toit`.

---

## Phase 1 — Lossless cleanup

### Task 1: Delete dead view code

**Files:**
- Delete: `examples/fuzzy_view.toit`, `examples/fuzzy_view2.toit`, `examples/fuzzy_view3.toit`, `examples/server.toit`, `examples/test.toit`, `examples/advanced_01.toit`, `examples/fcl.ohm`, `examples/fuzzy_language.ohm`

- [ ] **Step 1: Verify nothing else in the repo references these files**

```bash
grep -rn "fuzzy_view\|fuzzy-view\|fcl\.ohm\|fuzzy_language\.ohm\|examples\.server\|examples\.test\|examples\.advanced" \
  src/ tests/ examples/ --include="*.toit" --include="*.yaml" 2>/dev/null
```
Expected output: empty (no references). If anything appears, update or delete those references in the same commit.

- [ ] **Step 2: Delete the files**

```bash
rm examples/fuzzy_view.toit examples/fuzzy_view2.toit examples/fuzzy_view3.toit \
   examples/server.toit examples/test.toit examples/advanced_01.toit \
   examples/fcl.ohm examples/fuzzy_language.ohm
```

- [ ] **Step 3: Verify the remaining example still compiles**

```bash
jag toit run examples/simple_01.toit
```
Expected: prints `Time: ... Distance: 35 ---> Speed: ...` (driver model output).

- [ ] **Step 4: Commit**

```bash
git add -A examples/
git commit -m "chore: remove dead view code and Ohm grammar artifacts

The three fuzzy_view*.toit files imported ..html.graph_layout etc. that
never existed in the tree. server.toit wired them up, test.toit and
advanced_01.toit duplicated examples/simple_01.toit. The .ohm grammars
are superseded by the Python Lark grammar in Plan B."
```

---

### Task 2: Delete stale and hallucinated-API tests

**Files:**
- Delete: `tests/test_fuzzy_lib.toit`, `tests/test_general.toit`, `tests/test_validation.toit`, `tests/test_edge_cases.toit`, `tests/test_performance.toit`, `tests/test09.toit`, `tests/test_all_additional.toit`, `tests/ADDITIONAL_TESTS.md`

- [ ] **Step 1: Confirm the baseline classification**

For each file below, run `jag toit run <file>` and confirm the failure mode matches what's listed. These all currently fail at compile time — no runnable assertions are being lost.

| File | Expected failure |
|---|---|
| `tests/test_fuzzy_lib.toit` | compile error on `antecedent5.evaluate` (and a `throw` on entry); pre-rename API |
| `tests/test_general.toit` | compile error on `Antecedent-And` (pre-rename API) |
| `tests/test_validation.toit` | compile error on `composition.union`, `set.truncated`, `is_fired index` shape |
| `tests/test_edge_cases.toit` | compile error on `set.truncated`, `calculate_set_pertinences`, `crisp_in =` |
| `tests/test_performance.toit` | compile error on `output.sets[i]` (sets is not subscriptable) |
| `tests/test09.toit`, `tests/test_all_additional.toit` | legacy — confirm via header inspection |

```bash
for f in tests/test_fuzzy_lib.toit tests/test_general.toit \
         tests/test_validation.toit tests/test_edge_cases.toit \
         tests/test_performance.toit tests/test09.toit \
         tests/test_all_additional.toit; do
  echo "=== $f ==="
  jag toit run "$f" 2>&1 | tail -3
done
```

- [ ] **Step 2: Delete the files**

```bash
rm tests/test_fuzzy_lib.toit tests/test_general.toit \
   tests/test_validation.toit tests/test_edge_cases.toit \
   tests/test_performance.toit tests/test09.toit \
   tests/test_all_additional.toit \
   tests/ADDITIONAL_TESTS.md
```

- [ ] **Step 3: Verify the remaining test files still compile or run**

```bash
for f in tests/test_*.toit; do
  echo "=== $f ==="
  jag toit run "$f" 2>&1 | tail -3
done
```
Expected (per the baseline table): `test_casco`, `test_casco_runtime`, `test_geometry`, `test_lecture_1`, `test_lecture_2` complete cleanly. `test_api_usability` and `test_integration` show partial pass/fail — that's the known-baseline state, addressed in Phase 5.

- [ ] **Step 4: Commit**

```bash
git add -A tests/
git commit -m "chore: drop stale and hallucinated-API tests

test_fuzzy_lib throws on entry and references a pre-rename
Antecedent.evaluate.

test_general uses Antecedent-And (the dash-form class that was
renamed to Antecedent.fl-and).

test_validation, test_edge_cases, and test_performance reference
methods that have never existed in this codebase
(composition.union, FuzzySet.truncated, FuzzyInput.crisp_in=,
FuzzyInput.calculate_set_pertinences, indexable FuzzyOutput.sets).

test09 and test_all_additional are legacy script-style tests.

The remaining test files (test_casco, test_casco_runtime,
test_geometry, test_lecture_1, test_lecture_2, test_api_usability,
test_integration) keep their current behavior; new coverage lands
in Phase 5."
```

---

### Task 3: Delete miscellaneous artifacts

**Files:**
- Delete: `docs/todo.md`, `llms/instructions-long.md`, `llms/sketch-setup.md`, `.aider.chat.history.md`, `.aider.input.history`, `.aider.tags.cache.v4/`, `shelley.db`, `shelley.db-shm`, `shelley.db-wal`, `outputs.png`

- [ ] **Step 1: Verify no .toit or .yaml file references these**

```bash
grep -rn "todo\.md\|instructions-long\|sketch-setup\|shelley\|outputs\.png" \
  src/ tests/ examples/ docs/ --include="*.toit" --include="*.yaml" --include="*.md" 2>/dev/null \
  | grep -v "^docs/superpowers/"
```
Expected output: empty (excluding the spec, which legitimately mentions deleting them).

- [ ] **Step 2: Delete the files**

```bash
rm -f docs/todo.md
rm -f llms/instructions-long.md llms/sketch-setup.md
rm -rf .aider.chat.history.md .aider.input.history .aider.tags.cache.v4
rm -f shelley.db shelley.db-shm shelley.db-wal
rm -f outputs.png
```

- [ ] **Step 3: Remove the now-empty `llms/` directory if it's empty**

```bash
rmdir llms 2>/dev/null || true
```
Note: `||true` because the directory may still hold files we want to keep (the deleted `toit-conventions.md` may have already left it empty).

- [ ] **Step 4: Update `.gitignore` to ignore aider artifacts going forward**

Read current `.gitignore`:
```bash
cat .gitignore
```

Append these lines if not already present:
```
.aider.*
*.db
*.db-shm
*.db-wal
```

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "chore: drop generated artifacts and obsolete docs

todo.md was generic boilerplate. instructions-long.md overlapped the
global toit-conventions skill. sketch-setup.md was orphaned. The
aider/shelley files are local-development artifacts that don't belong
in version control; .gitignore updated to keep them out."
```

---

### Task 4: Rename `examples_fcl/` to `fcl/`

**Files:**
- Rename: `examples_fcl/` → `fcl/`

- [ ] **Step 1: Verify nothing references the old name**

```bash
grep -rn "examples_fcl" \
  src/ tests/ examples/ docs/ README.md CHANGELOG.md --include="*.toit" \
  --include="*.yaml" --include="*.md" 2>/dev/null \
  | grep -v "^docs/superpowers/"
```
Expected output: empty (excluding the spec).

- [ ] **Step 2: Rename via git so history is preserved**

```bash
git mv examples_fcl fcl
```

- [ ] **Step 3: Verify the directory listing**

```bash
ls fcl/
```
Expected: `block.fcl  container-crane.fcl  ip.fcl  ip2.fcl  membershipFunctionsDemo.fcl  qualify.fcl  qualify_optimized.fcl  tipper.fcl  tipping.fcl  tipping2.fcl  triage.fcl  z.fcl`.

- [ ] **Step 4: Commit**

```bash
git commit -m "chore: rename examples_fcl/ to fcl/

These are FCL source-of-truth files, not Toit examples. Plan B's
fcl2json converter writes derived JSON into fcl/generated/."
```

---

## Phase 2 — Engine: `NOT` + rule weights

### Task 5: Add `AntecedentNot` and `Antecedent.fl-not`

**Files:**
- Modify: `src/antecedent.toit`
- Test: `tests/test_engine_features.toit` (new file)

- [ ] **Step 1: Write the failing test**

Create `tests/test_engine_features.toit`:
```toit
// Copyright (c) 2026 Ekorau LLC

import btest show *
import fuzzy-logic show *

main:
  test-start

  test "Antecedent" "fl-not inverts pertinence":
    set := FuzzySet 0.0 10.0 10.0 20.0 "tri"
    set.max 0.3                             // pertinence_ = 0.3
    not-term := Antecedent.fl-not (Antecedent.fl-set set)
    expect-near 0.7 not-term.term-eval

    set.clear
    set.max 0.0
    not-term2 := Antecedent.fl-not (Antecedent.fl-set set)
    expect-near 1.0 not-term2.term-eval

    set.clear
    set.max 1.0
    not-term3 := Antecedent.fl-not (Antecedent.fl-set set)
    expect-near 0.0 not-term3.term-eval

  test "Antecedent" "fl-not nests under fl-and":
    a := FuzzySet 0.0 10.0 10.0 20.0 "a"
    b := FuzzySet 0.0 10.0 10.0 20.0 "b"
    a.max 0.6
    b.max 0.4

    // (a AND NOT b) -> min(0.6, 1.0 - 0.4) = min(0.6, 0.6) = 0.6
    expr := Antecedent.fl-and a (Antecedent.fl-not (Antecedent.fl-set b))
    expect-near 0.6 expr.term-eval

  test-end
```

- [ ] **Step 2: Run the test, expect failure**

```bash
jag toit run tests/test_engine_features.toit
```
Expected: compile error — `Antecedent.fl-not` not defined.

- [ ] **Step 3: Add `AntecedentNot` to `src/antecedent.toit`**

Replace the body of `src/antecedent.toit` (preserving copyright + imports) with:

```toit
// Copyright (c) 2021, 2022, 2026 Ekorau LLC

import math
import .fuzzy-set show FuzzySet
import .fuzzy-rule show RuleTerm

abstract class Antecedent implements RuleTerm:

  term1 /RuleTerm? := null
  term2 /RuleTerm? := null

  constructor .term1 .term2:

  constructor.fl-set fuzzy-set/FuzzySet:
    return AntecedentSet fuzzy-set

  constructor.fl-and terma/RuleTerm termb/RuleTerm:
    return AntecedentAnd terma termb

  constructor.fl-or terma/RuleTerm termb/RuleTerm:
    return AntecedentOr terma termb

  constructor.fl-not term/RuleTerm:
    return AntecedentNot term

  abstract term-eval -> float


class AntecedentSet extends Antecedent:

  constructor term:
    super term null

  stringify -> string:
    return (term1 as FuzzySet).name

  term-eval -> float:
    return term1.term-eval


class AntecedentAnd extends Antecedent:

  constructor term1/RuleTerm term2/RuleTerm:
    super term1 term2

  stringify -> string:
    return "($term1 and $term2)"

  term-eval -> float:
    return max 0.0 (min term1.term-eval term2.term-eval)


class AntecedentOr extends Antecedent:

  constructor term1/RuleTerm term2/RuleTerm:
    super term1 term2

  stringify -> string:
    return "($term1 or $term2)"

  term-eval -> float:
    return max 0.0 (max term1.term-eval term2.term-eval)


class AntecedentNot extends Antecedent:

  constructor term/RuleTerm:
    super term null

  stringify -> string:
    return "(not $term1)"

  term-eval -> float:
    return 1.0 - term1.term-eval
```

- [ ] **Step 4: Run the test, expect pass**

```bash
jag toit run tests/test_engine_features.toit
```
Expected: all tests in the "fl-not inverts pertinence" and "fl-not nests under fl-and" groups pass; "ok" lines for each test.

- [ ] **Step 5: Commit**

```bash
git add src/antecedent.toit tests/test_engine_features.toit
git commit -m "feat(engine): add Antecedent.fl-not and AntecedentNot

Needed for FCL rules like 'IF airway IS NOT maintained' (triage.fcl).
term-eval returns 1.0 - inner.term-eval."
```

---

### Task 6: Add `FuzzyRule.weight`

**Files:**
- Modify: `src/fuzzy_rule.toit`
- Test: `tests/test_engine_features.toit` (extend)

- [ ] **Step 1: Write the failing test**

Append to `tests/test_engine_features.toit` before `test-end`:

```toit
  test "FuzzyRule" "weight scales antecedent power":
    in-set := FuzzySet 0.0 10.0 10.0 20.0 "a"
    out-set := FuzzySet 0.0 10.0 10.0 20.0 "b"

    in-set.max 1.0  // antecedent power = 1.0

    // weight = 1.0 (default): consequent receives full power
    rule-default := FuzzyRule.fl-if
        (Antecedent.fl-set in-set)
        --fl-then=(Consequent.output out-set)
    out-set.clear
    in-set.max 1.0
    rule-default.evaluate
    expect-near 1.0 out-set.pertinence

    // weight = 0.5: consequent receives 0.5
    out-set.clear
    in-set.max 1.0
    rule-half := FuzzyRule.fl-if
        (Antecedent.fl-set in-set)
        --fl-then=(Consequent.output out-set)
        --weight=0.5
    rule-half.evaluate
    expect-near 0.5 out-set.pertinence

  test "FuzzyRule" "weight=0 mutes the rule":
    in-set := FuzzySet 0.0 10.0 10.0 20.0 "a"
    out-set := FuzzySet 0.0 10.0 10.0 20.0 "b"
    in-set.max 1.0
    rule := FuzzyRule.fl-if
        (Antecedent.fl-set in-set)
        --fl-then=(Consequent.output out-set)
        --weight=0.0
    rule.evaluate
    expect-near 0.0 out-set.pertinence
```

- [ ] **Step 2: Run the test, expect failure**

```bash
jag toit run tests/test_engine_features.toit
```
Expected: compile error — `--weight` named argument not recognized on `FuzzyRule.fl-if`.

- [ ] **Step 3: Implement `weight` in `src/fuzzy_rule.toit`**

Replace `src/fuzzy_rule.toit` with:

```toit
// Copyright (c) 2021, 2026 Ekorau LLC

import .antecedent show Antecedent
import .consequent show Consequent

interface RuleTerm:
  term-eval -> float

class FuzzyRule:

  fired := false
  antecedent_/Antecedent
  fl-then/Consequent? := null
  name/string := ""
  weight/float := 1.0

  constructor.fl-if .antecedent_/Antecedent --.fl-then/Consequent --name="" --weight=1.0:
    this.weight = weight.to-float

  evaluate -> bool:
    antecedent-power := antecedent_.term-eval
    fired = antecedent-power > 0.0
    fl-then.evaluate antecedent-power * weight
    return fired

  stringify -> string:
    prefix := ""
    if not name.is-empty:
      prefix = "$name: "
    weight-suffix := weight == 1.0 ? "" : " with $weight"
    return "$(prefix)if $antecedent_ then $fl-then$weight-suffix"
```

- [ ] **Step 4: Run the test, expect pass**

```bash
jag toit run tests/test_engine_features.toit
```
Expected: all tests pass.

- [ ] **Step 5: Run `examples/simple_01.toit` to confirm no regression**

```bash
jag toit run examples/simple_01.toit
```
Expected: same `Time: ... Distance: 35 ---> Speed: ...` output as before (default weight = 1.0).

- [ ] **Step 6: Commit**

```bash
git add src/fuzzy_rule.toit tests/test_engine_features.toit
git commit -m "feat(engine): add FuzzyRule weight (default 1.0)

Antecedent power is multiplied by weight before activating the
consequent. Needed for FCL rules like 'THEN ... WITH 0.8'
(triage.fcl). Existing rules built without --weight default to 1.0
and behave unchanged."
```

---

## Phase 3 — JSON loader

The loader builds engine objects from a `Map`. It must not import `http`, `websocket`, or `encoding.json` — keeping the embedded use-case dep-free.

### Task 7: Skeleton `load-model` that builds inputs and outputs

**Files:**
- Create: `src/json_loader.toit`
- Test: `tests/test_json_loader.toit` (new file)

- [ ] **Step 1: Write the failing test**

Create `tests/test_json_loader.toit`:
```toit
// Copyright (c) 2026 Ekorau LLC

import btest show *
import fuzzy-logic show *
import fuzzy-logic.json-loader show load-model

main:
  test-start

  test "JsonLoader" "loads inputs and outputs with terms":
    json := {
      "name": "tipper",
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
      "rules": [],
    }
    model := load-model json
    expect-equals "tipper" model.name
    expect-equals 1 model.inputs.size
    expect-equals "service" model.inputs[0].name
    expect-equals 3 model.inputs[0].fsets.size
    expect-equals "poor" model.inputs[0].fsets[0].name
    expect-equals 1 model.outputs.size
    expect-equals "tip" model.outputs[0].name
    expect-equals 2 model.outputs[0].fsets.size

  test-end
```

- [ ] **Step 2: Run the test, expect failure**

```bash
jag toit run tests/test_json_loader.toit
```
Expected: compile error — module `fuzzy-logic.json-loader` not found.

- [ ] **Step 3: Create `src/json_loader.toit` with the inputs/outputs path only**

```toit
// Copyright (c) 2026 Ekorau LLC

import .antecedent show Antecedent
import .consequent show Consequent
import .fuzzy-in-out show FuzzyInput FuzzyOutput
import .fuzzy-model show FuzzyModel
import .fuzzy-rule show FuzzyRule RuleTerm
import .fuzzy-set show FuzzySet

/**
Builds a $FuzzyModel from a $Map shaped per the schema in
docs/superpowers/specs/2026-05-08-fuzzy-logic-restructure-design.md.

Imports nothing beyond engine modules: callers do not pull in
http, websocket, or encoding.json.
*/
load-model json/Map -> FuzzyModel:
  model := FuzzyModel json["name"]

  json["inputs"].do: | spec/Map |
    input := FuzzyInput.sets (build-sets_ spec["terms"]) --name=spec["name"]
    model.add-input input

  json["outputs"].do: | spec/Map |
    output := FuzzyOutput.sets (build-sets_ spec["terms"]) --name=spec["name"]
    model.add-output output

  // Rules wired up in a later task.
  return model

build-sets_ specs/List -> List:
  result := []
  specs.do: | t/Map |
    result.add (FuzzySet
        t["a"].to-float
        t["b"].to-float
        t["c"].to-float
        t["d"].to-float
        t["name"])
  return result
```

- [ ] **Step 4: Run the test, expect pass**

```bash
jag toit run tests/test_json_loader.toit
```
Expected: the "loads inputs and outputs with terms" test passes.

- [ ] **Step 5: Commit**

```bash
git add src/json_loader.toit tests/test_json_loader.toit
git commit -m "feat(loader): build FuzzyModel inputs and outputs from JSON

Skeleton load-model handles the schema's name/inputs/outputs/terms
fields. Rule wiring lands in the next commit."
```

---

### Task 8: Build rule expression trees

**Files:**
- Modify: `src/json_loader.toit`
- Test: `tests/test_json_loader.toit` (extend)

- [ ] **Step 1: Write the failing test**

Append to `tests/test_json_loader.toit` before `test-end`:
```toit
  test "JsonLoader" "loads simple IS rule":
    json := {
      "name": "tiny",
      "inputs": [{"name": "x", "terms": [
        {"name": "low",  "a": 0, "b": 0, "c": 0, "d": 5},
        {"name": "high", "a": 5, "b": 10, "c": 10, "d": 10},
      ]}],
      "outputs": [{"name": "y", "terms": [
        {"name": "off", "a": 0, "b": 0, "c": 0, "d": 0},
        {"name": "on",  "a": 1, "b": 1, "c": 1, "d": 1},
      ]}],
      "rules": [
        {"if":   {"op": "is", "var": "x", "term": "high"},
         "then": [{"var": "y", "term": "on"}]},
      ],
    }
    model := load-model json
    expect-equals 1 model.rules.size
    model.crisp-input 0 8.0
    model.fuzzify
    out := model.defuzzify 0
    expect-near 1.0 out

  test "JsonLoader" "loads AND, OR, NOT, weight":
    json := {
      "name": "ops",
      "inputs": [
        {"name": "x", "terms": [
          {"name": "lo", "a": 0, "b": 0, "c": 0, "d": 10},
          {"name": "hi", "a": 0, "b": 10, "c": 10, "d": 10},
        ]},
        {"name": "y", "terms": [
          {"name": "lo", "a": 0, "b": 0, "c": 0, "d": 10},
          {"name": "hi", "a": 0, "b": 10, "c": 10, "d": 10},
        ]},
      ],
      "outputs": [{"name": "z", "terms": [
        {"name": "off", "a": 0, "b": 0, "c": 0, "d": 0},
        {"name": "on",  "a": 1, "b": 1, "c": 1, "d": 1},
      ]}],
      "rules": [
        {
          "weight": 0.5,
          "if": {
            "op": "and",
            "args": [
              {"op": "or", "args": [
                {"op": "is", "var": "x", "term": "hi"},
                {"op": "is", "var": "y", "term": "hi"},
              ]},
              {"op": "not", "arg": {"op": "is", "var": "x", "term": "lo"}},
            ],
          },
          "then": [{"var": "z", "term": "on"}],
        },
      ],
    }
    model := load-model json
    expect-equals 1 model.rules.size
    expect-near 0.5 model.rules[0].weight

  test "JsonLoader" "loads multi-output consequent":
    json := {
      "name": "multi",
      "inputs": [{"name": "x", "terms": [
        {"name": "any", "a": 0, "b": 5, "c": 5, "d": 10},
      ]}],
      "outputs": [
        {"name": "a", "terms": [{"name": "on", "a": 0, "b": 5, "c": 5, "d": 10}]},
        {"name": "b", "terms": [{"name": "on", "a": 0, "b": 5, "c": 5, "d": 10}]},
      ],
      "rules": [
        {"if":   {"op": "is", "var": "x", "term": "any"},
         "then": [
           {"var": "a", "term": "on"},
           {"var": "b", "term": "on"},
         ]},
      ],
    }
    model := load-model json
    model.crisp-input 0 5.0
    model.fuzzify
    expect-near 5.0 (model.defuzzify 0)
    expect-near 5.0 (model.defuzzify 1)
```

- [ ] **Step 2: Run, expect failure**

```bash
jag toit run tests/test_json_loader.toit
```
Expected: tests "loads simple IS rule", "loads AND, OR, NOT, weight", "loads multi-output consequent" fail because rules aren't built yet.

- [ ] **Step 3: Wire up rule construction in `src/json_loader.toit`**

Replace the `load-model` body and add helpers; the file becomes:

```toit
// Copyright (c) 2026 Ekorau LLC

import .antecedent show Antecedent
import .consequent show Consequent
import .fuzzy-in-out show FuzzyInput FuzzyOutput
import .fuzzy-model show FuzzyModel
import .fuzzy-rule show FuzzyRule RuleTerm
import .fuzzy-set show FuzzySet

/**
Builds a $FuzzyModel from a $Map shaped per the schema in
docs/superpowers/specs/2026-05-08-fuzzy-logic-restructure-design.md.

Imports nothing beyond engine modules: callers do not pull in
http, websocket, or encoding.json.
*/
load-model json/Map -> FuzzyModel:
  model := FuzzyModel json["name"]

  // Index every set by (var-name, term-name) so rule expressions can resolve
  // their leaves by string lookup.
  set-index := {:}

  json["inputs"].do: | spec/Map |
    sets := build-sets_ spec["terms"]
    input := FuzzyInput.sets sets --name=spec["name"]
    model.add-input input
    sets.do: | s/FuzzySet | set-index["$(spec["name"])::$s.name"] = s

  json["outputs"].do: | spec/Map |
    sets := build-sets_ spec["terms"]
    output := FuzzyOutput.sets sets --name=spec["name"]
    model.add-output output
    sets.do: | s/FuzzySet | set-index["$(spec["name"])::$s.name"] = s

  json["rules"].do: | spec/Map |
    antecedent := build-antecedent_ spec["if"] set-index
    consequent := build-consequent_ spec["then"] set-index
    weight := spec.get "weight" --if-absent=: 1.0
    name   := spec.get "name"   --if-absent=: ""
    rule := FuzzyRule.fl-if antecedent
        --fl-then=consequent
        --name=name
        --weight=weight.to-float
    model.add-rule rule

  return model

build-sets_ specs/List -> List:
  result := []
  specs.do: | t/Map |
    result.add (FuzzySet
        t["a"].to-float
        t["b"].to-float
        t["c"].to-float
        t["d"].to-float
        t["name"])
  return result

build-antecedent_ node/Map set-index/Map -> RuleTerm:
  op := node["op"]
  if op == "is":
    key := "$(node["var"])::$(node["term"])"
    set := set-index.get key --if-absent=: throw "json_loader: unknown set '$key'"
    return Antecedent.fl-set set
  if op == "and":
    args := node["args"]
    return Antecedent.fl-and
        (build-antecedent_ args[0] set-index)
        (build-antecedent_ args[1] set-index)
  if op == "or":
    args := node["args"]
    return Antecedent.fl-or
        (build-antecedent_ args[0] set-index)
        (build-antecedent_ args[1] set-index)
  if op == "not":
    return Antecedent.fl-not (build-antecedent_ node["arg"] set-index)
  throw "json_loader: unknown op '$op'"

build-consequent_ specs/List set-index/Map -> Consequent:
  sets := []
  specs.do: | t/Map |
    key := "$(t["var"])::$(t["term"])"
    set := set-index.get key --if-absent=: throw "json_loader: unknown set '$key'"
    sets.add set
  return Consequent.outputs sets
```

- [ ] **Step 4: Run, expect pass**

```bash
jag toit run tests/test_json_loader.toit
```
Expected: all four tests pass.

- [ ] **Step 5: Commit**

```bash
git add src/json_loader.toit tests/test_json_loader.toit
git commit -m "feat(loader): build rule expression trees from JSON

Recursive walk turns {op: and|or|not|is, ...} into nested Antecedent
constructors. Sets are indexed by (var, term) so leaves resolve by
string lookup. Optional weight defaults to 1.0; multi-output
consequents become Consequent.outputs."
```

---

### Task 9: Pin every hand-coded model via JSON

This task reproduces each of the six models in `examples/models.toit` as a JSON literal and asserts the JSON-loaded model produces the same defuzzified output as the hand-coded one for a representative crisp-input vector. These tests pin Phase 4's centroid-rewrite behavior — they must pass identically before and after the rewrite.

**Files:**
- Create: `tests/test_models_via_json.toit`

- [ ] **Step 1: Write the failing test (driver model only)**

Create `tests/test_models_via_json.toit`:
```toit
// Copyright (c) 2026 Ekorau LLC
// Pins behavior across the closed-form centroid rewrite (Phase 4).

import btest show *
import fuzzy-logic show *
import fuzzy-logic.json-loader show load-model
import ..examples.models show *

main:
  test-start

  test "ModelsViaJson" "driver model matches hand-coded":
    json-model := load-model DRIVER-JSON
    hand-model := get-driver

    [10.0, 35.0, 70.0, 95.0].do: | x/float |
      json-model.crisp-input 0 x
      json-model.fuzzify
      hand-model.crisp-input 0 x
      hand-model.fuzzify
      expect-near (hand-model.defuzzify 0) (json-model.defuzzify 0)

  test-end

DRIVER-JSON ::= {
  "name": "driver",
  "inputs": [
    {"name": "distance", "terms": [
      {"name": "small", "a": 0,  "b": 20, "c": 20,  "d": 40},
      {"name": "safe",  "a": 30, "b": 50, "c": 50,  "d": 70},
      {"name": "big",   "a": 60, "b": 80, "c": 100, "d": 100},
    ]},
  ],
  "outputs": [
    {"name": "speed", "terms": [
      {"name": "slow",    "a": 0,  "b": 10, "c": 10, "d": 20},
      {"name": "average", "a": 10, "b": 20, "c": 30, "d": 40},
      {"name": "fast",    "a": 30, "b": 40, "c": 40, "d": 50},
    ]},
  ],
  "rules": [
    {"if": {"op": "is", "var": "distance", "term": "small"},
     "then": [{"var": "speed", "term": "slow"}]},
    {"if": {"op": "is", "var": "distance", "term": "safe"},
     "then": [{"var": "speed", "term": "average"}]},
    {"if": {"op": "is", "var": "distance", "term": "big"},
     "then": [{"var": "speed", "term": "fast"}]},
  ],
}
```

- [ ] **Step 2: Run the test, expect pass**

```bash
jag toit run tests/test_models_via_json.toit
```
Expected: "driver model matches hand-coded" passes.

If it fails because the JSON's set boundaries don't match `examples/models.toit:get-driver`, re-read `examples/models.toit:27-49` and update `DRIVER-JSON` to match exactly.

- [ ] **Step 3: Commit driver coverage**

```bash
git add tests/test_models_via_json.toit
git commit -m "test: pin driver model behavior via JSON loader

JSON literal mirrors examples/models.toit:get-driver. Asserts the
JSON-loaded model produces the same defuzzified output for a sweep
of crisp inputs. This pin is what Phase 4 must not break."
```

- [ ] **Step 4: Add the remaining five models, one test block each**

For each of `fan-speed`, `air-conditioning`, `casco`, `container-crane`, `driver_advanced`, do the following:

1. Read the corresponding `get-X` function in `examples/models.toit` to extract exact set boundaries and rules.
2. Add a `<MODEL>-JSON ::= { ... }` constant to `tests/test_models_via_json.toit`.
3. Add a `test "ModelsViaJson" "<model> model matches hand-coded":` block that:
   - For models with N inputs, sweeps crisp inputs at the midpoints/edges of each input's range.
   - Asserts `expect-near (hand-model.defuzzify i) (json-model.defuzzify i)` for every output `i`.

For the `driver_advanced` model only: it has three inputs and two outputs. Use the test cases the existing `tests/test_casco.toit` style follows — pick three crisp-input vectors that exercise different rule combinations.

For the `casco` model: re-use the nine TEST cases already documented in `tests/test_casco.toit:18-97` so the golden numbers there carry over.

After each model is added, run:
```bash
jag toit run tests/test_models_via_json.toit
```
Expected: every block passes. If a block fails, the JSON literal does not match the hand-coded model — fix the literal, do not mutate the engine.

- [ ] **Step 5: Commit each model addition individually**

After each model is green, commit it on its own:
```bash
git add tests/test_models_via_json.toit
git commit -m "test: pin <model-name> model behavior via JSON loader"
```
(Six commits total — one per model — keeps Phase 4 regression bisects fast.)

---

## Phase 4 — Closed-form centroid math

This phase replaces the polygon-based centroid implementation in `src/fuzzy_set.toit` with a closed-form formula that does not need `Point2f`, `intersection`, or any geometry classes.

**Math reference** (for review while implementing):

For a generic set with vertices `(a, b, c, d)` (rising edge a→b, top b→c, falling edge c→d) truncated at height `h = pertinence_`:

- Left intersection: `xL = a + h * (b - a)` (degenerates to `a` when `a == b`)
- Right intersection: `xR = d - h * (d - c)` (degenerates to `d` when `c == d`)
- Truncated polygon vertices CCW: `(a,0), (d,0), (xR,h), (xL,h)`

Applying the shoelace formula to that quadrilateral yields:

```
truncated-area              = h * ((d - a) + (xR - xL)) / 2
truncated-weighted-centroid = h * (d² + d·xR + xR² - xL² - a·xL - a²) / 6
```

These formulas hold for every non-singleton subclass (the degeneracies at a==b and c==d collapse correctly). `SingletonSet` keeps its existing special case.

### Task 10: Replace the base-class centroid implementation

**Files:**
- Modify: `src/fuzzy_set.toit`

- [ ] **Step 1: Read the current `src/fuzzy_set.toit:11-128`** (base class definition + geometry methods)

```bash
jag toit run examples/simple_01.toit
```
Note the current driver-model output — used as a sanity reference.

- [ ] **Step 2: Replace `src/fuzzy_set.toit` body**

The full new file. (Subclass overrides for `polyline`/`truncated-polygon`/`graph-points` are deleted entirely; only the abstract `lookup_` remains specialized per type.)

```toit
// Copyright (c) 2021, 2026 Ekorau LLC

import .fuzzy-rule show RuleTerm

F-error3 ::= 0.0009  // Floating-point tolerance, retained for compare-to.

y-rising p q r -> float:
  return (p - q) / (r - q)

y-falling p q r -> float:
  return 1.0 - (p - q) / (r - q)


abstract class FuzzySet implements RuleTerm:

  a_/float
  b_/float
  c_/float
  d_/float

  pertinence_/float := 0.0
  name := ""

  constructor.with-points a b c d .name="":
    a_ = a.to-float
    b_ = b.to-float
    c_ = c.to-float
    d_ = d.to-float

  constructor a/num b/num c/num d/num aname="":
    if a == b and b == c and c == d: return SingletonSet a b c d aname
    if a == b and b == c:             return LraTriangularSet a b c d aname
    if b == c and c == d:             return RraTriangularSet a b c d aname
    if b == c:                        return TriangularSet a b c d aname
    if a == b:                        return LTrapezoidalSet a b c d aname
    if c == d:                        return RTrapezoidalSet a b c d aname
    return TrapezoidalSet a b c d aname

  clear -> none:
    pertinence_ = 0.0

  compare-to other/FuzzySet -> any:
    if a_ < other.a_: return -1
    if a_ > other.a_: return 1
    if a_ == other.a_ and b_ == other.b_ and c_ == other.c_ and d_ == other.d_: return 0
    if pertinence_ < other.pertinence_: return -1
    if pertinence_ > other.pertinence_: return 1
    return 0

  is-pertinent -> bool:
    return pertinence_ > 0.0

  pertinence -> float:
    return pertinence_

  term-eval -> float:
    return pertinence_

  fuzzify crisp-val/num -> none:
    pertinence_ = lookup_ crisp-val.to-float

  range -> List:
    return [a_, d_]

  abstract lookup_ val/float -> float

  max val/float -> none:
    if pertinence_ < val:
      pertinence_ = val

  truncated-area -> float:
    h := pertinence_
    xL := a_ + h * (b_ - a_)
    xR := d_ - h * (d_ - c_)
    return h * ((d_ - a_) + (xR - xL)) / 2.0

  truncated-weighted-centroid -> float:
    h := pertinence_
    xL := a_ + h * (b_ - a_)
    xR := d_ - h * (d_ - c_)
    return h * (d_*d_ + d_*xR + xR*xR - xL*xL - a_*xL - a_*a_) / 6.0

  stype: return ""

  stringify: return "$name/$(%.1f pertinence_)"

  // Test accessors.
  test-a -> float: return a_
  test-b -> float: return b_
  test-c -> float: return c_
  test-d -> float: return d_


class SingletonSet extends FuzzySet:

  constructor a aname="":
    super.with-points a a a a aname

  constructor a b c d name:
    super.with-points a b c d name

  stype: return "sing"

  lookup_ cVal/float -> float:
    return (a_ - cVal).abs < F-error3 ? 1.0 : 0.0

  truncated-weighted-centroid -> float:
    return a_

  truncated-area -> float:
    return 0.0


class LTrapezoidalSet extends FuzzySet:

  constructor a c d name:
    super.with-points a a c d name

  constructor a b c d name:
    super.with-points a b c d name

  stype: return "trap.l"

  lookup_ cVal/float -> float:
    if cVal <= c_:    return 1.0
    if cVal >= d_:    return 0.0
    return y-falling cVal c_ d_


class RTrapezoidalSet extends FuzzySet:

  constructor a b c name:
    super.with-points a b c c name

  constructor a b c d name:
    super.with-points a b c d name

  stype: return "trap.r"

  lookup_ cVal/float -> float:
    if cVal <= a_:    return 0.0
    if cVal >= b_:    return 1.0
    return y-rising cVal a_ b_


class TrapezoidalSet extends FuzzySet:

  constructor a b c d name:
    super.with-points a b c d name

  stype: return "trap"

  lookup_ cVal/float -> float:
    if cVal <= a_ or cVal >= d_:        return 0.0
    if cVal >= b_ and cVal <= c_:       return 1.0
    if cVal < b_:                       return y-rising cVal a_ b_
    return y-falling cVal c_ d_


class LraTriangularSet extends FuzzySet:

  constructor a d name:
    super.with-points a a a d name

  constructor a b c d name:
    super.with-points a b c d name

  stype: return "tri.lra"

  lookup_ cVal/float -> float:
    if cVal <= a_ or cVal >= d_:        return 0.0
    return y-falling cVal c_ d_


class RraTriangularSet extends FuzzySet:

  constructor a b c d name:
    super.with-points a b c d name

  constructor a d name:
    super.with-points a d d d name

  stype: return "tri.rra"

  lookup_ cVal/float -> float:
    if cVal <= a_ or cVal >= d_:        return 0.0
    return y-rising cVal a_ b_


class TriangularSet extends FuzzySet:

  constructor a b d name:
    super.with-points a b b d name

  constructor a b c d name:
    super.with-points a b c d name

  stype: return "tri"

  lookup_ cVal/float -> float:
    if cVal <= a_ or cVal >= d_:        return 0.0
    if cVal < b_:                       return y-rising cVal a_ b_
    if cVal > b_:                       return y-falling cVal c_ d_
    return 1.0
```

- [ ] **Step 3: Run all current tests, including the JSON-pinned models**

```bash
for f in tests/test_engine_features.toit tests/test_json_loader.toit \
         tests/test_models_via_json.toit tests/test_geometry.toit \
         tests/test_casco.toit tests/test_casco_runtime.toit \
         tests/test_validation.toit tests/test_edge_cases.toit \
         tests/test_api_usability.toit tests/test_integration.toit \
         tests/test_performance.toit; do
  echo "=== $f ==="
  jag toit run "$f" || echo "FAILED: $f"
done
```
Expected: every test passes. The `test_models_via_json.toit` block is the most important confirmation — JSON-loaded models still match the hand-coded ones.

If `expect-near` fails: the closed-form formula is wrong for that subclass — re-derive against the polygon shoelace and fix in this commit before moving on.

- [ ] **Step 4: Run `examples/simple_01.toit` and confirm output matches the Step 1 reference**

```bash
jag toit run examples/simple_01.toit
```
Expected: same `Time: ... Distance: 35 ---> Speed: ...` value as in Step 1 (within float tolerance).

- [ ] **Step 5: Commit**

```bash
git add src/fuzzy_set.toit
git commit -m "refactor(engine): closed-form centroid per FuzzySet subclass

Replaces the polygon-based truncated-area/centroid that depended on
Point2f, intersection, and the truncated-polygon vertex lists.
truncated-area and truncated-weighted-centroid in the base class
compute via shoelace inlined as float arithmetic on (a, b, c, d, h);
SingletonSet retains its area=0, weighted=a special case.

Also removes polyline, truncated-polygon, truncator-l/r,
graph-points, centroid-x_, truncate, clear-geometry-cache, area_,
and pts_. The geometry vocabulary is gone from the public surface.

Verified via tests/test_models_via_json.toit: every hand-coded
model produces the same defuzzified output as before."
```

---

### Task 11: Strip SVG helpers from `src/composition.toit`

**Files:**
- Modify: `src/composition.toit`

- [ ] **Step 1: Replace `src/composition.toit` with the trimmed version**

```toit
// Copyright (c) 2021, 2026 Ekorau LLC

import .fuzzy-in-out show FuzzyOutput
import .fuzzy-set show FuzzySet SingletonSet

/*
A composition aggregates the truncated areas of every pertinent set
in a $FuzzyOutput and reports the defuzzified crisp value (centre of
gravity).
*/
class Composition:

  foutput_ /FuzzyOutput
  crisp-out_ /float? := null

  constructor .foutput_/FuzzyOutput:

  clear -> none:
    crisp-out_ = null

  defuzzify -> float:
    if crisp-out_ == null:
      crisp-out_ = centroid-x collect-pertinent_
    return crisp-out_

  collect-pertinent_ -> List:
    subset := []
    foutput_.fsets.do:
      if it.is-pertinent:
        subset.add it
    return subset

  centroid-x subset/List -> float:
    if subset.size == 1 and subset[0] is SingletonSet:
      return subset[0].truncated-weighted-centroid
    weighted := 0.0
    tot-area := 0.0
    subset.do:
      tot-area += it.truncated-area
      weighted += it.truncated-weighted-centroid
    return weighted / tot-area
```

- [ ] **Step 2: Run all tests**

```bash
for f in tests/test_*.toit; do
  echo "=== $f ==="
  jag toit run "$f" || echo "FAILED: $f"
done
```
Expected: every test still passes.

- [ ] **Step 3: Commit**

```bash
git add src/composition.toit
git commit -m "refactor(engine): drop SVG helpers from Composition

set-names, centroid-line, set-polylines, svg-polyline_, and
scale-svg-polyline_ existed only for the dead HTML view code in
examples/. Composition's only public surface now is defuzzify.

Also renames the private collect-truncated to collect-pertinent_
since 'truncate' was the polygon-mutating operation we just removed.
No behavior change."
```

---

### Task 12: Delete `src/geometry.toit` and stop re-exporting it

**Files:**
- Delete: `src/geometry.toit`
- Modify: `src/fuzzy_logic.toit`

- [ ] **Step 1: Confirm no source file imports geometry**

```bash
grep -rn "import .*geometry\|geometry show\|Point2f\|NoPoint2f\|Stack\b" \
  src/ tests/ examples/ --include="*.toit" 2>/dev/null
```
Expected: empty (after the tests/test_geometry.toit and the previous tasks' rewrites).

If `tests/test_geometry.toit` imports geometry directly, fix it now (it should only import `fuzzy-logic show FuzzyOutput FuzzySet` per the existing file content — verify against `tests/test_geometry.toit:1-10`).

- [ ] **Step 2: Delete the file**

```bash
rm src/geometry.toit
```

- [ ] **Step 3: Update `src/fuzzy_logic.toit` to drop the import**

```toit
// Copyright (c) 2021, 2022, 2026 Ekorau LLC

import .antecedent
import .composition
import .consequent
import .fuzzy-in-out
import .fuzzy-model
import .fuzzy-rule
import .fuzzy-set

export *
```

- [ ] **Step 4: Run the full test suite**

```bash
for f in tests/test_*.toit; do
  echo "=== $f ==="
  jag toit run "$f" || echo "FAILED: $f"
done
```
Expected: every test passes.

- [ ] **Step 5: Run the example to sanity-check**

```bash
jag toit run examples/simple_01.toit
```
Expected: same `Distance: 35 ---> Speed: ...` output.

- [ ] **Step 6: Commit**

```bash
git add -A src/
git commit -m "refactor(engine): delete src/geometry.toit

Stack, convex-hull, polar-sort, leftmost-lowest, is-point/above,
xy-sort, intersection, Point2f, NoPoint2f are all unused after the
closed-form centroid rewrite. fuzzy_logic.toit no longer
re-exports geometry; the engine has zero geometry vocabulary."
```

---

### Task 13: Strip `polylines` from `FuzzyInput` and `clear` cleanup

**Files:**
- Modify: `src/fuzzy_in_out.toit`

`FuzzyInput.polylines` (returns a list of polylines) was only consumed by the deleted view code. Remove it. `seg` (a list-slicing helper) at the top of the file is also unused.

- [ ] **Step 1: Verify nothing references the symbols being deleted**

```bash
grep -rn "\.polylines\b\|fuzzy-in-out show .*seg" \
  src/ tests/ examples/ --include="*.toit" 2>/dev/null
```
Expected: empty.

- [ ] **Step 2: Replace `src/fuzzy_in_out.toit`**

```toit
// Copyright (c) 2021, 2026 Ekorau LLC

import .composition show Composition

class InputOutput:

  fsets/List := []
  range_/List? := null
  name/string

  constructor.sets .fsets/List --.name="":

  constructor .name="":


  add-set a-set -> none:
    fsets.add a-set
    range_ = null

  add-all-sets sets/List -> none:
    fsets.add-all sets
    range_ = null

  clear -> none:
    fsets.do: it.clear
    range_ = null

  range -> List:
    if range_ == null:
      range_ = [0, 0]
      fsets.do:
        range_[0] = min range_[0] it.range[0]
        range_[1] = max range_[1] it.range[1]
    return range_

  set-names -> List:
    names := []
    fsets.do: names.add it.name
    return names


class FuzzyInput extends InputOutput:

  constructor.sets sets/List --name="":
    super.sets sets --name=name

  constructor name="":
    super name

  fuzzify crisp-in/num -> none:
    fsets.do: it.fuzzify crisp-in

  stringify -> string:
    in-str := "in: $name\n"
    fsets.do:
      in-str = in-str + "    " + it.stringify + "\n"
    return "$in-str"


class FuzzyOutput extends InputOutput:

  composition_ /Composition? := null

  constructor.sets sets/List --name="":
    super.sets sets --name=name
    composition_ = Composition this

  constructor name="":
    super name
    composition_ = Composition this

  clear -> none:
    composition_.clear
    super

  composition -> Composition:
    return composition_

  defuzzify -> float:
    return composition_.defuzzify

  stringify -> string:
    out-str := "out: $name\n"
    fsets.do:
      out-str = out-str + "    " + it.stringify + "\n"
    return "$out-str"
```

- [ ] **Step 3: Run all tests**

```bash
for f in tests/test_*.toit; do
  echo "=== $f ==="
  jag toit run "$f" || echo "FAILED: $f"
done
```
Expected: every test passes.

- [ ] **Step 4: Commit**

```bash
git add src/fuzzy_in_out.toit
git commit -m "refactor(engine): drop FuzzyInput.polylines and seg helper

Both existed only for the deleted view code in examples/. The engine
now exposes no view-shaped helpers."
```

---

## Phase 5 — Test cull and rebuild

### Task 14: Audit remaining tests; delete legacy script-style tests

**Files:**
- Delete: `tests/casco.toit` (script-style print-only file, not a test)
- Inspect: every other `tests/*.toit` to confirm it uses the current API

- [ ] **Step 1: List remaining test files**

```bash
ls tests/*.toit
```

- [ ] **Step 2: Verify each compiles cleanly**

```bash
for f in tests/*.toit; do
  echo "=== $f ==="
  jag toit compile --analyze "$f" 2>&1 | head -10
done
```
Expected: zero analyzer errors. If a file emits errors (e.g. missing imports, deleted symbols), open the file and either update it to the current API or move it to the delete list with a brief justification in the commit message.

- [ ] **Step 3: Delete `tests/casco.toit`**

It's a print-only script (`print "test 01, expect 7.5, got ..."`) — `tests/test_casco.toit` covers the same cases with proper assertions. It also imports `..examples.models` which Plan B will delete.

```bash
rm tests/casco.toit
```

- [ ] **Step 4: Confirm everything still passes**

```bash
for f in tests/test_*.toit; do
  echo "=== $f ==="
  jag toit run "$f" || echo "FAILED: $f"
done
```
Expected: all green.

- [ ] **Step 5: Commit**

```bash
git add -A tests/
git commit -m "chore(tests): drop tests/casco.toit script

Print-only file with no assertions. tests/test_casco.toit provides
the asserted version of the same nine cases."
```

---

### Task 15: Add per-set-type closed-form centroid tests

**Files:**
- Create: `tests/test_closed_form_centroid.toit`

These tests verify the closed-form formulas across a sweep of pertinence values and set shapes, independent of any model. They are the regression net if a future refactor changes the centroid math.

- [ ] **Step 1: Write the test file**

```toit
// Copyright (c) 2026 Ekorau LLC

import btest show *
import fuzzy-logic show *

main:
  test-start

  test "ClosedForm" "TriangularSet area at h=1.0":
    // Triangle 0,5,5,10 truncated at h=1 has area 5 (base 10, height 1, /2 = 5).
    set := FuzzySet 0.0 5.0 5.0 10.0 "tri"
    set.max 1.0
    expect-near 5.0 set.truncated-area
    // Centroid x by symmetry = 5.
    expect-near 5.0 (set.truncated-weighted-centroid / set.truncated-area)

  test "ClosedForm" "TriangularSet area at h=0.5":
    // Truncated triangle: bottom width 10, top width 5, height 0.5.
    // Trapezoidal area = (10+5)/2 * 0.5 = 3.75.
    set := FuzzySet 0.0 5.0 5.0 10.0 "tri"
    set.max 0.5
    expect-near 3.75 set.truncated-area
    expect-near 5.0  (set.truncated-weighted-centroid / set.truncated-area)

  test "ClosedForm" "TrapezoidalSet area at h=1.0":
    // Trapezoid 0,2,8,10 has parallel sides 2 (top) and 10 (bottom), height 1.
    // Area = (2+10)/2 * 1 = 6.
    set := FuzzySet 0.0 2.0 8.0 10.0 "trap"
    set.max 1.0
    expect-near 6.0 set.truncated-area
    expect-near 5.0 (set.truncated-weighted-centroid / set.truncated-area)

  test "ClosedForm" "LTrapezoidalSet at h=1.0":
    // 0,0,5,10 with h=1: bottom 0..10, top 0..5. Area = (10+5)/2 = 7.5.
    set := FuzzySet 0.0 0.0 5.0 10.0 "ltrap"
    set.max 1.0
    expect-near 7.5 set.truncated-area
    // Centroid x of this asymmetric trapezoid:
    // shoelace gives weighted-centroid = ?  Verify against polygon math:
    // polygon (0,0),(10,0),(5,1),(0,1)
    // area = 7.5 (above)
    // 6*A*Cx = (0+10)*(0*0 - 10*0) + (10+5)*(10*1 - 5*0) + (5+0)*(5*1 - 0*1) + (0+0)*(0*0 - 0*1)
    //       = 0 + 150 + 25 + 0 = 175
    // Cx = 175 / (6 * 7.5) = 175 / 45 = 3.8888...
    expect-near 3.8888888 (set.truncated-weighted-centroid / set.truncated-area)

  test "ClosedForm" "RTrapezoidalSet at h=1.0":
    // 0,5,10,10 mirror of above. Centroid x = 10 - 3.888... = 6.111...
    set := FuzzySet 0.0 5.0 10.0 10.0 "rtrap"
    set.max 1.0
    expect-near 7.5 set.truncated-area
    expect-near 6.1111111 (set.truncated-weighted-centroid / set.truncated-area)

  test "ClosedForm" "SingletonSet area is zero, weighted centroid is a":
    set := FuzzySet 7.0 7.0 7.0 7.0 "sing"
    set.max 1.0
    expect-equals 0.0 set.truncated-area
    expect-equals 7.0 set.truncated-weighted-centroid

  test "ClosedForm" "untruncated set has zero area":
    set := FuzzySet 0.0 5.0 5.0 10.0 "tri"
    set.max 0.0
    expect-equals 0.0 set.truncated-area
    expect-equals 0.0 set.truncated-weighted-centroid

  test-end
```

- [ ] **Step 2: Run, expect pass**

```bash
jag toit run tests/test_closed_form_centroid.toit
```
Expected: all tests pass. If any centroid value disagrees with the inline math, the closed-form formula in `fuzzy_set.toit` is wrong — fix that file (not the test).

- [ ] **Step 3: Commit**

```bash
git add tests/test_closed_form_centroid.toit
git commit -m "test: add per-set-type closed-form centroid coverage

Sweeps area and centroid values across triangle, trapezoid (general,
left, right), and singleton at h=1.0 and h=0.5. Each expected value
is derived inline by shoelace so the test self-documents."
```

---

### Task 16: Ensure `test_engine_features.toit` covers the integration of NOT and weights

**Files:**
- Modify: `tests/test_engine_features.toit`

- [ ] **Step 1: Add the json-loader import**

Add after the existing `import fuzzy-logic show *` line in `tests/test_engine_features.toit`:
```toit
import fuzzy-logic.json-loader show load-model
```

- [ ] **Step 2: Append a combined-feature test before `test-end`**

```toit
  test "Engine" "NOT and weight together via JSON":
    model := load-model {
      "name": "combined",
      "inputs": [{"name": "x", "terms": [
        {"name": "lo", "a": 0, "b": 0,  "c": 0,  "d": 10},
        {"name": "hi", "a": 0, "b": 10, "c": 10, "d": 10},
      ]}],
      "outputs": [{"name": "y", "terms": [
        {"name": "off", "a": 0, "b": 0, "c": 0, "d": 0},
        {"name": "on",  "a": 0, "b": 5, "c": 5, "d": 10},
      ]}],
      "rules": [
        {"weight": 0.5,
         "if": {"op": "not", "arg": {"op": "is", "var": "x", "term": "lo"}},
         "then": [{"var": "y", "term": "on"}]},
      ],
    }
    // x=8: "lo" pertinence = 0.2 (y-falling 8 0 10), so NOT = 0.8.
    // Rule weight 0.5 → consequent activated at 0.4.
    // "on" set 0,5,5,10 (TriangularSet) truncated at h=0.4: centroid by symmetry = 5.
    model.crisp-input 0 8.0
    model.fuzzify
    expect-near 5.0 (model.defuzzify 0)
```

- [ ] **Step 2: Run, expect pass**

```bash
jag toit run tests/test_engine_features.toit
```
Expected: every test in the file passes.

- [ ] **Step 3: Commit**

```bash
git add tests/test_engine_features.toit
git commit -m "test: add NOT + weight + JSON loader integration case

Proves the three Phase 2/3 features compose: a NOT antecedent on a
non-zero fuzzified input, scaled by weight 0.5 on a triangular
output, defuzzifies to the expected centroid."
```

---

### Task 17: Final test-suite green-board confirmation

**Files:** none (verification step)

- [ ] **Step 1: Run every remaining test**

```bash
for f in tests/test_*.toit; do
  echo "=== $f ==="
  jag toit run "$f" || echo "FAILED: $f"
done
```
Expected: every test prints "ok" lines and ends without "FAILED:".

If any test fails, fix it before declaring the plan done. Do not introduce skips or `xfail` markers.

- [ ] **Step 2: Run the example smoke test**

```bash
jag toit run examples/simple_01.toit
```
Expected: same driver-model output as at the start of the plan.

- [ ] **Step 3: Verify the engine has no geometry vocabulary**

```bash
grep -rn "Point2f\|NoPoint2f\|Stack\|convex-hull\|polar-sort\|leftmost-lowest" \
  src/ --include="*.toit" 2>/dev/null
```
Expected: empty.

```bash
grep -rn "polyline\|truncated-polygon\|truncator-l\|truncator-r\|graph-points\|svg-polyline" \
  src/ --include="*.toit" 2>/dev/null
```
Expected: empty.

- [ ] **Step 4: Verify the JSON loader has no transitive RPC deps**

```bash
jag toit compile --analyze src/json_loader.toit 2>&1
```
Expected: no errors.

```bash
grep -E "^import" src/json_loader.toit
```
Expected: only `import .antecedent`, `import .consequent`, `import .fuzzy-in-out`, `import .fuzzy-model`, `import .fuzzy-rule`, `import .fuzzy-set`. No `http`, no `websocket`, no `encoding.json`, no `net`.

- [ ] **Step 5: No commit needed (verification only)**

---

## Plan-end checklist

After all tasks above are checked off:

- [ ] `git log --oneline` shows ~17 focused commits since the spec commit (`c28b95b`).
- [ ] `tests/` directory contains only test files that compile and pass.
- [ ] `src/geometry.toit` is gone; `src/json_loader.toit` is in place.
- [ ] `examples/simple_01.toit`, `examples/models.toit`, `tests/test_casco.toit`, `tests/test_casco_runtime.toit` still run unchanged. (Plan B removes them.)
- [ ] `examples_fcl/` is renamed to `fcl/`.
- [ ] `.aider.*`, `shelley.db*`, `outputs.png`, `docs/todo.md`, `llms/instructions-long.md`, `llms/sketch-setup.md` are gone from the working tree (and from `git ls-files`).

Hand off to Plan B (cross-language integration: Python `fcl2json`, RPC service, Plotly Dash viz, examples replacement, README rewrite).
