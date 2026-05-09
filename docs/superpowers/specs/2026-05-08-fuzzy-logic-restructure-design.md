# Fuzzy Logic Library — Restructure Design

**Status:** approved 2026-05-08
**Scope:** weed out cruft, enable FCL model loads, drop geometry from the engine, add a Python visualizer.

## Context

The Toit `fuzzy_logic` package has accumulated several rounds of evolution: a polygon-clipping experiment in `geometry.toit`, three abandoned HTML view implementations in `examples/`, an Ohm FCL grammar that never landed, a hand-coded model file, and a test suite mixing pre-rename APIs with current ones. About 1,800 lines of view code in `examples/` references html helper modules that don't exist in the tree; 184 lines of `geometry.toit` are mostly unused beyond `Point2f` and one `intersection` routine.

The redirection: pure inference engine in Toit, model authoring via FCL parsed on the host into JSON, all visualization in a Python Plotly Dash app talking to the engine over HTTP+WebSocket.

## Decisions driving the design

| Decision | Choice |
|---|---|
| Visualization location | Python host tool, via RPC |
| FCL loading | Host-side parser → JSON; Toit loads JSON |
| Geometry approach | Closed-form centroid per set type; drop polygon machinery |
| Test suite | Cull stale tests, rebuild around the new API |
| Manipulation scope | Inputs (sliders) + drag handles on set (a, b, c, d) corners |
| Python stack | Plotly Dash, Lark for FCL |
| Repo layout | Single repo; Toit `package.yaml` stays at root; Python under `python/` |

## Repo layout

```
fuzzy_logic/
├── package.yaml              (Toit package root, unchanged)
├── README.md                 (rewritten around the new pipeline)
├── CHANGELOG.md
├── LICENSE, LICENSE_*        (kept)
├── src/                       Toit engine — published as the package
│   ├── fuzzy_logic.toit       (re-exports the engine; NO rpc_service)
│   ├── fuzzy_model.toit
│   ├── fuzzy_in_out.toit
│   ├── fuzzy_set.toit         (closed-form centroid; no polylines/SVG)
│   ├── fuzzy_rule.toit        (rule weight added)
│   ├── antecedent.toit        (NOT added)
│   ├── consequent.toit
│   ├── composition.toit       (defuzzify only; no SVG)
│   ├── json_loader.toit       (NEW; pure Map→FuzzyModel)
│   └── rpc_service.toit       (NEW; opt-in import; needs http/websocket)
├── examples/
│   ├── simple.toit            (inline JSON literal; minimum-solver demo)
│   ├── embedded.toit          (JSON string constant; ESP32-friendly, no RPC)
│   └── device.toit            (loads JSON, starts RpcService)
├── tests/                     (rebuilt focused suite)
├── fcl/                       (renamed from examples_fcl/)
│   ├── tipper.fcl … (.fcl source of truth)
│   └── generated/             (.json artifacts produced by fcl2json)
├── python/                    (auxiliary tooling — NOT part of the Toit package)
│   ├── pyproject.toml
│   ├── fuzzy_lab/
│   │   ├── schema.py          (dataclasses; shared by converter and viz)
│   │   ├── fcl2json/          (Lark grammar + parser, CLI entry)
│   │   └── viz/               (Plotly Dash app + WS client)
│   └── tests/
└── docs/
    └── superpowers/specs/     (this spec)
```

### What gets deleted

- `src/geometry.toit` — entire file
- `src/composition.toit` SVG helpers (`set-polylines`, `centroid-line`, `svg-polyline_`, `scale-svg-polyline_`, `set-names` view)
- `src/fuzzy_set.toit` — `polyline`, `truncated-polygon`, `truncator-l/r`, polygon-based `centroid-x_`, polygon-based `truncated-area`, `graph-points`
- `examples/fuzzy_view.toit`, `fuzzy_view2.toit`, `fuzzy_view3.toit` — three broken view files
- `examples/models.toit` — replaced by FCL files + JSON loader
- `examples/server.toit`, `examples/test.toit`, `examples/advanced_01.toit` — folded into the new examples
- `tests/test_fuzzy_lib.toit` (throws), `tests/test_general.toit`, `tests/test_lecture_*.toit` (old API)
- Other stale tests audited individually in Phase 5
- `docs/todo.md` (generic boilerplate)
- `llms/instructions-long.md` (overlaps the global toit-conventions skill), `llms/sketch-setup.md` (orphan)
- `.aider.chat.history.md`, `.aider.input.history`, `.aider.tags.cache.v4/`
- `shelley.db`, `shelley.db-shm`, `shelley.db-wal`, `outputs.png`

## JSON model schema

Single source of truth shared by the FCL converter, the Toit JSON loader, the RPC service, and the visualizer.

```json
{
  "name": "tipper",
  "defuzz_method": "COG",
  "inputs": [
    {
      "name": "service",
      "terms": [
        { "name": "poor",      "a": 0, "b": 0, "c": 0, "d": 4 },
        { "name": "good",      "a": 1, "b": 4, "c": 6, "d": 9 },
        { "name": "excellent", "a": 6, "b": 9, "c": 9, "d": 9 }
      ]
    }
  ],
  "outputs": [
    {
      "name": "tip",
      "terms": [
        { "name": "cheap",    "a": 0,  "b": 5,  "c": 5,  "d": 10 },
        { "name": "average",  "a": 10, "b": 15, "c": 15, "d": 20 },
        { "name": "generous", "a": 20, "b": 25, "c": 25, "d": 30 }
      ]
    }
  ],
  "rules": [
    {
      "name": "rule1",
      "weight": 1.0,
      "if": {
        "op": "or",
        "args": [
          { "op": "is", "var": "service", "term": "poor" },
          { "op": "is", "var": "food",    "term": "rancid" }
        ]
      },
      "then": [
        { "var": "tip", "term": "cheap" }
      ]
    }
  ]
}
```

**Schema rules**
- Every TERM is `{name, a, b, c, d}`. The Toit `FuzzySet` constructor classifies the shape from value equality (singleton if a=b=c=d, LRA-triangular if a=b=c, etc.). The JSON does not carry a `type` field. The Python converter normalizes FCL forms (`trian a b c` → `{a, b, b, c}`; `trape a b c d` → `{a, b, c, d}`; bare `0` → `{0,0,0,0}`).
- Rule expression tree: `op` ∈ `"and" | "or" | "not" | "is"`. `and`/`or` carry `args` (list, length 2 — non-binary cases are nested). `not` carries `arg`. `is` is a leaf with `var` and `term`.
- `then` is always a list, even for single-output rules, matching the engine's `Consequent.outputs`.
- `weight` is optional, default 1.0. Engine multiplies antecedent power by weight before activating consequents.
- `defuzz_method` is recorded but only `"COG"` is honored in v1. Other values produce a warning at load time.

**Out of scope for v1**: per-rule activation methods (`ACT : MIN`), per-block AND/OR operator overrides, `DEFAULT` value when no rule fires, multiple `RULEBLOCK`s. The Python parser ignores these; defaults match the engine's hard-coded behavior (min for AND, max for OR, COG defuzz, default 0).

## Toit engine changes

### Closed-form centroid math

Each `FuzzySet` subclass implements two methods that take the current `pertinence` and return scalars directly. No `Point2f`, no `intersection`, no shoelace, no polygon vertices.

For a generic trapezoid `(a, b, c, d)` truncated at height `h`:
- left intersection x = `a + h·(b - a)`
- right intersection x = `d - h·(d - c)`
- truncated shape is itself a trapezoid; area and centroid_x derive in closed form

The seven subclasses (Singleton, LTrapezoidal, RTrapezoidal, Trapezoidal, LraTriangular, RraTriangular, Triangular) each get a specialized version. The general `Trapezoidal` formula handles the full case; the others are simplifications. `SingletonSet` keeps its current special behavior (weighted centroid = `a`, area = 0, with the `subset.size == 1 and is SingletonSet` short-circuit in `Composition.centroid-x`).

`Composition.defuzzify` becomes one pass: `Σ(area_i × centroid_x_i) / Σ(area_i)` over pertinent sets.

### New module: `src/json_loader.toit`

Pure Map → object construction. No `http`, no `websocket`, no `encoding.json`. Importing this module costs only the engine modules it already depends on.

```toit
load-model map/Map -> FuzzyModel
```

Construction order:
1. Build all `FuzzyInput` + their `FuzzySet` objects, indexed by `(var-name, term-name)`.
2. Build all `FuzzyOutput` + their `FuzzySet` objects, same index.
3. For each rule, walk `if` recursively into `Antecedent.fl-and` / `fl-or` / `fl-not` / `fl-set`, walk `then` into `Consequent.outputs`, attach `weight`.

A separate convenience `load-model-from-string text/string -> FuzzyModel` lives behind a separate import so consumers who only have a `Map` literal don't pay for `encoding.json`.

### Engine API additions

- `Antecedent.fl-not term/RuleTerm` and `class AntecedentNot` — `term-eval = 1.0 - inner.term-eval`.
- `FuzzyRule.weight/float := 1.0`; `evaluate` does `consequent.evaluate (antecedent-power * weight)`.
- `FuzzyModel.serialize-state -> Map` — returns `{inputs: [{name, crisp, terms: [{name, pertinence}]}], outputs: [...with crisp_out and pertinent terms], rules: [{name, fired}]}` for the RPC `/state` push.
- `FuzzyModel.update-term var-name/string term-name/string a/float b/float c/float d/float` — in-place edit so the visualizer's drag handles can mutate live state without re-loading the whole model.

### New module: `src/rpc_service.toit` (opt-in import)

`class RpcService model/FuzzyModel net/net.Interface --port=8080`. Endpoints:

| Path | Method | Purpose |
|---|---|---|
| `/model` | GET  | Returns the model topology as JSON, reflecting any `update-term` mutations applied since load (i.e., current term parameters, not the originally-loaded ones). |
| `/model` | POST | Replaces the in-memory model with the posted JSON. |
| `/term`  | POST | Body `{var, term, a, b, c, d}`. Updates one term, re-evaluates, pushes state. |
| `/input` | POST | Body `{var, value}`. Sets one crisp input, re-evaluates, pushes state. |
| `/state` | GET  | Returns `serialize-state` — runtime data only (current pertinences, crisp inputs/outputs, fired rules). Distinct from `/model`. |
| `/ws`    | WS   | Bidirectional. Client sends `{"input": {...}}` or `{"term": {...}}`; server pushes `{"state": {...}}` after every change. |

Device and host run the same service; only the `net.Interface` differs.

### Layering rule

```
src/fuzzy_logic.toit         imports: engine modules only
src/json_loader.toit         imports: engine modules only
src/rpc_service.toit         imports: json_loader + http + websocket + encoding.json
```

A consumer who only wants the smallest solver writes:

```toit
import fuzzy-logic show *
import fuzzy-logic.json-loader show load-model

MODEL ::= { ... }

main:
  model := load-model MODEL
  model.crisp-input 0 5.0
  model.fuzzify
  print "$(model.defuzzify 0)"
```

Their compiled image pulls in only the engine + loader. No `http`, no `websocket`, no `net`.

## Python tooling

```
python/
├── pyproject.toml             (one project, two console scripts: fcl2json, fuzzy-lab)
├── fuzzy_lab/
│   ├── __init__.py
│   ├── schema.py               (dataclasses, json load/save; single source of truth)
│   ├── fcl2json/
│   │   ├── __main__.py         CLI entry
│   │   ├── grammar.lark
│   │   └── parser.py
│   └── viz/
│       ├── __main__.py         CLI entry
│       ├── app.py              (Dash layout)
│       ├── plots.py            (membership + composition figures)
│       └── rpc.py              (HTTP+WS client to RpcService)
└── tests/
```

### `fcl2json` — FCL → JSON converter

Lark grammar covering the subset the repo's `.fcl` files actually use:
- `FUNCTION_BLOCK` / `END_FUNCTION_BLOCK`
- `VAR_INPUT` / `VAR_OUTPUT` (types ignored; everything is `REAL`)
- `FUZZIFY` / `END_FUZZIFY` with TERM forms: `trape a b c d`, `trian a b c`, point-list `(x,y) (x,y)…`, bare singleton `0`/`1`
- `DEFUZZIFY` / `END_DEFUZZIFY` with `METHOD : COG;` (other methods → warning, fall back to COG, recorded in `defuzz_method` for forward compat)
- `RULEBLOCK` / `END_RULEBLOCK` with `RULE n : IF <expr> THEN <var> IS <term>[, <var> IS <term>]* [WITH <weight>];`
- Operators: `IS`, `IS NOT`, `AND`, `OR`, `NOT`, parens

Output: a JSON file matching the schema above. Point-list TERMs are normalized to `(a, b, c, d)` by sorting and recognizing standard shapes.

CLI: `fcl2json fcl/tipper.fcl > fcl/generated/tipper.json` and `--all <dir>` for batch.

Failure mode: invalid grammar → non-zero exit + line/col + offending text. Unknown `METHOD` outside the supported set → warning to stderr, file still written.

### `fuzzy-lab` — Plotly Dash visualizer

`python -m fuzzy_lab.viz --connect ws://192.168.0.130:8080` (device) or `--connect ws://localhost:8080` (host).

Startup: HTTP GET `/model`, render layout. WS connect, listen for state pushes.

Layout (single page, top to bottom):
- **Header**: model name, defuzz method, connection status.
- **Inputs row**: one panel per input variable. Each:
  - Plotly figure with one polygon per membership function; current pertinence drawn as a dashed horizontal line.
  - Slider beneath, range `[a-min, d-max]`. Sends `{"input": {var: value}}` over WS on change.
  - Plotly `editable: true` shapes on the membership polygons, so dragging the (a, b, c, d) corners sends `{"term": {var, term, a, b, c, d}}`.
- **Rules row**: list of rules, fired ones rendered bold/colored.
- **Outputs row**: one panel per output. Truncated polygons stacked on the membership curves, centroid as a vertical dashed line, crisp output value displayed numerically.

State updates flow through the WebSocket; no full page reloads. Reconnect with backoff on WS drop; UI greys out and shows a banner during disconnection.

Dependencies: `dash`, `plotly`, `dash_extensions[websocket]`, `lark`, `httpx`. Nothing else.

### Round-trip guarantee

`fcl2json` → JSON → Toit `load-model` → Toit `/model` GET → diff against the converter's output should be byte-equivalent (modulo key order and floats normalized to a fixed precision). One Python test enforces this against every `.fcl` in `fcl/`. (`/state` is not part of the round-trip; it is runtime data.)

## Migration sequence

Eight phases. Each ends green and is independently revertible.

**Phase 1 — Lossless cleanup**
- Delete the dead view files, stale tests, aider artifacts, shelley.db, llms/, todo.md.
- Rename `examples_fcl/` → `fcl/`.
- Keep `examples/simple_01.toit` and `examples/models.toit` running for now; they are the smoke-test path through Phases 2–5. Both are replaced/deleted in Phases 7–8 once the JSON-based examples (`simple.toit`, `embedded.toit`, `device.toit`) work.
- Currently-passing tests still pass after this phase.

**Phase 2 — Engine: NOT + rule weights**
- Add `AntecedentNot` + `Antecedent.fl-not`.
- Add `FuzzyRule.weight/float := 1.0` and use it in `evaluate`.
- New tests for both features.

**Phase 3 — JSON loader (pinned to current centroid math)**
- New `src/json_loader.toit`.
- Tests build JSON literals matching the six hand-coded models in `examples/models.toit`, load via the new loader, run identical crisp inputs, expect identical defuzzified outputs. Pins behavior before the centroid rewrite.

**Phase 4 — Closed-form centroid math (riskiest phase)**
- Replace polygon-based `truncated-area`/`centroid-x_` with closed-form per subclass.
- Delete `src/geometry.toit`, polygon helpers in `fuzzy_set.toit`, SVG helpers in `composition.toit`.
- Re-run Phase 3 tests. Expected divergence ≤ 1e-6. If a test expectation must change, document the new value in CHANGELOG.

**Phase 5 — Test cull and rebuild**
- Audit and delete remaining stale tests.
- New focused suite: closed-form area/centroid per set type, JSON loader (every `op`, NOT, weights, multi-output consequents), `update-term`, `serialize-state`.

**Phase 6 — Python `fcl2json`**
- `python/pyproject.toml`, `schema.py`, `fcl2json/` with Lark grammar.
- Convert every `.fcl` in `fcl/` to `fcl/generated/*.json`.
- Round-trip Python test: every generated JSON loads cleanly in Toit (subprocess) and runs.

**Phase 7 — RPC service**
- Add `serialize-state`, `update-term`.
- New `src/rpc_service.toit`.
- New `examples/simple.toit`, `examples/embedded.toit`, `examples/device.toit`.
- Manual smoke: `curl /model`, POST `/input`, observe `/state`.

**Phase 8 — Plotly Dash viz + docs**
- `python/fuzzy_lab/viz/`: Dash app, WS client, sliders, drag handles, reconnect.
- Dev-test against host-mode engine.
- Rewrite `README.md` around the FCL → JSON → engine → viz pipeline.
- Update `CHANGELOG.md`. Bump to `0.7.0` (breaking: removed `geometry.toit` and SVG helpers from public API).
- Delete `examples/models.toit` after confirming all six models exist as `.fcl` and `.json`.

**Parallelism**: Phase 6 (Python FCL) is independent of Phases 2–5 once the schema is frozen and can run in parallel. Phases 7 and 8 are sequential.

## Risk register

1. **Phase 4 numerical divergence.** Tests pinned in Phase 3 may shift slightly when polygon math becomes closed-form. Mitigation: verify shifts are within 1e-6; for any larger shift, cross-check against jFuzzyLogic / fuzzylite reference values before accepting. The README's "<1% error vs jFuzzyLogic" claim gets a fresh measurement.
2. **Uncatalogued FCL syntax.** A `.fcl` file in `fcl/` may use a form not in the grammar. Mitigation: parser fails fast with file:line; add the form to the grammar. Initial coverage targets every `.fcl` file present today.
3. **JSON schema lock-in.** Section 2's schema is the contract. Changing it later means migrating both Python and Toit sides plus regenerating `.json` artifacts. Mitigation: versioned schema field if it changes (`"schema_version": 1` reserved space).
4. **WebSocket reconnect edge cases.** Plotly Dash + WebSocket can be finicky around component lifecycle. Mitigation: `dash_extensions.WebSocket` handles reconnect; if it's flaky, fall back to polling `/state` at a fixed interval.

## Out of scope (deliberately, for v1)

- Multiple `RULEBLOCK`s per FCL file
- Per-rule `ACT` and per-block `AND`/`OR` operator overrides
- Defuzzification methods other than COG
- `DEFAULT` value when no rule fires
- Saving viz edits back to FCL
- Mobile-friendly viz layout
- Authentication on the RPC service
