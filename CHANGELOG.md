## 0.8.0 — 2026-05-10

**Breaking — `fcl2json` is now strict**
- Declarations the engine cannot honor raise `NotImplementedError` instead of being silently discarded. The previous behavior masked genuine semantic mismatches (e.g. `triage.fcl`'s `METHOD : RM` was treated as `COG`, producing wrong defuzzify outputs).
- Rejected: non-default `AND` / `OR` / `ACT` / `ACCU` operators, non-`COG`/`COGS` `METHOD`, multiple `RULEBLOCK`s in one `FUNCTION_BLOCK`.
- Accepted as no-ops (match engine defaults): `AND : MIN`, `OR : MAX`, `ACT : MIN`, `ACCU : MAX`, `METHOD : COG`, `METHOD : COGS`.
- Still accepted-and-discarded (cosmetic only): `RANGE`, `DEFAULT`.

**Tooling + content**
- 6 new first-party `.fcl` files in `fcl/` — `driver`, `driver_advanced`, `casco`, `fan-speed`, `air-conditioning`, `lecture_1` — paired with the hand-coded models in `examples/models.toit`. Visualizer's file picker now lists 13 supported FCLs (up from 7).
- `examples/check_fcl_parity.toit` confirms each FCL produces bit-identical defuzzify outputs to its hand-coded counterpart across fixed input vectors.
- Five third-party reference samples whose unsupported declarations now raise (`tipping2.fcl`, `triage.fcl`, `qualify.fcl`, `qualify_optimized.fcl`, `membershipFunctionsDemo.fcl`) moved to `fcl/unsupported/`. Viz picker globs `fcl/*.fcl` non-recursively, so they're skipped automatically.

**Engine**
- `LraTriangularSet` and `RraTriangularSet` gain closed-form centroid test coverage (Plan A reviewer follow-up).

**Docs**
- New topic-organized docs under `docs/`: `getting-started`, `esp32-deployment`, `engine`, `models`, `fcl`, `rpc-service`, `visualizer`.
- Root `README.md` trimmed to elevator pitch + links.
- New `fcl/index.md` catalogues every `.fcl` file by domain.
- Removed `docs/superpowers/` (4,800 lines of restructure plans + spec) — the timeless content was cherry-picked into the new docs.

## 0.7.0 — 2026-05-10

**Engine**
- Closed-form centroid math per `FuzzySet` subclass (replaces the polygon-based approach in 0.6.x).
- `Antecedent.fl-not` (logical NOT in rule antecedents) and `FuzzyRule.weight` (default 1.0).
- `FuzzyModel.serialize-state` for live introspection.
- `SingletonSet` truncated-area / truncated-weighted-centroid contract so multi-singleton outputs return the correct weighted-average COG (Σ aᵢ·pᵢ / Σ pᵢ) through the general formula.
- New module `fuzzy-logic.json-loader` (`load-model map -> FuzzyModel`); zero http/websocket/encoding.json deps.
- New module `fuzzy-logic.rpc-service` (`RpcService`); opt-in import — pulls in `pkg-http`.

**Tooling (Python)**
- `fcl2json` console script: converts `.fcl` files to the engine's JSON schema. Lark-based grammar; `--all` batch mode.
- `fuzzy-lab` console script: Plotly Dash visualizer over the `RpcService`. HTTP polling (`--poll-ms`, default 500), file-picker hot-swap via `POST /model`, slider-driven inputs via `POST /input`, color-coded MF figures, synthesized rule names.
- `python/` is a self-contained `uv` project; `pytest` covers schema, fcl2json grammar + round-trip, viz plots, and the RPC client.

**Removed (breaking)**
- `src/geometry.toit` (`Point2f`, intersection, `Stack`, `polar-sort`, etc.).
- SVG helpers in `src/composition.toit`.
- `polyline`, `truncated-polygon`, `truncator-l/r`, `graph-points`, polygon-based `truncated-area` / `centroid-x_` in `src/fuzzy_set.toit`.
- `examples/fuzzy_view*.toit`, `examples/server.toit`, `examples/test.toit`, `examples/advanced_01.toit`, `examples/simple_01.toit`.
- Stale tests using pre-rename API surfaces.

**Other**
- `examples_fcl/` renamed to `fcl/`; generated JSON committed under `fcl/generated/` (9 of 12 `.fcl` files round-trip; the 3 unsupported render an inline error in the viz).
- New examples: `examples/simple.toit` (inline-JSON), `examples/embedded.toit` (string-literal model for ESP32), `examples/device.toit` (loads JSON from disk and starts `RpcService` on `:8090`).
- Cleaned out `.aider.*`, `shelley.db*`, `outputs.png`, `docs/todo.md`, `llms/`.

**Known limitations (v1)**
- Visualizer is view-with-sliders + file-picker hot-swap; per-term MF editing (drag handles / textarea) is not implemented.
- Only `COG` defuzzification is honored. Non-COG `METHOD:` values in `.fcl` are recorded in the JSON's `defuzz_method` field for forward compat but ignored at run time.
- One `RULEBLOCK` per `FUNCTION_BLOCK`. Per-rule `ACT` and per-block `AND`/`OR` operator overrides are accepted-and-discarded by `fcl2json`.

## 0.6.4 - 2022-12-09
Initial Ohm .fcl grammar; revise html generation

## 0.6.2 - 2022-12-06
Improve navigation on web pages

## 0.6.1 - 2022-12-05
Fix README

## 0.6.0 - 2022-12-05
Significant refactor, slight change to API.
Revised calculation of the composition centroid.
Added a webserver in examples, to enable models to be visualized.

## 0.5.1 - 2022-01-27
Revised the test suite utility and related tests.  
Improve code formatting.

## 0.5.0 - 2021-12-07
Initial public release
