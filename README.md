# fuzzy_logic

A Toit fuzzy inference engine for ESP32 and host environments. Loads models from JSON literals or files, evaluates fuzzy rules with closed-form centroid math, and (optionally) exposes a live HTTP API for a Plotly Dash visualizer.

Originally an adaptation of [eFLL — Embedded Fuzzy Logic Library](https://github.com/zerokol/eFLL).

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

This pulls in only the engine + JSON loader. No HTTP dependency.

See `examples/simple.toit` for a more complete inline-JSON walkthrough and `examples/embedded.toit` for the ESP32-shaped variant (model as a `"""..."""` string constant, parsed via `encoding.json`).

## Authoring models in FCL

Hand-write `.fcl` files using the standard subset (`FUNCTION_BLOCK`, `VAR_INPUT`/`VAR_OUTPUT`, `FUZZIFY`/`DEFUZZIFY` with `trape` / `trian` / point-list / singleton `TERM`s, `RULEBLOCK` with `IF/THEN/WITH`). Convert with the Python tool:

```
cd python && uv sync --all-extras
uv run fcl2json ../fcl/tipper.fcl > ../fcl/generated/tipper.json
uv run fcl2json --all ../fcl --out-dir ../fcl/generated
```

The Toit engine consumes the generated JSON via `load-model`.

## Live visualization

Start the RPC service alongside your model. `examples/device.toit` is a ready-to-run host driver — it reads `fcl/generated/tipper.json` from disk and listens on `:8090`:

```bash
jag toit run examples/device.toit
# fuzzy_logic RpcService listening on :8090 (model=tipper)
```

Then run the Dash visualizer:

```bash
cd python && uv run fuzzy-lab --connect http://127.0.0.1:8090
# Browser: http://127.0.0.1:8050/
```

The visualizer:

- Lists every `.fcl` under `fcl/` in a dropdown; picking one re-parses with `fcl2json`, POSTs the JSON to `/model`, and hot-swaps the engine state in place.
- Renders each input and output as a membership-function figure with color-coded term labels.
- Crisp inputs are driven by sliders that POST to `/input`; the page polls `/state` (default 500 ms) and refreshes per-term pertinence + the current crisp/defuzzified value.
- Synthesizes human-readable rule names ("R1: service is poor OR food is rancid → tip is cheap").

The RPC surface is HTTP-only, four routes: `GET /model`, `POST /model`, `GET /state`, `POST /input`. Importing `fuzzy-logic.rpc-service` is opt-in — engine-only consumers don't pull in `pkg-http`.

## Repository layout

```
src/                 Toit engine modules (closed-form centroid math, JSON loader, RPC service)
fcl/                 Hand-written FCL source files (see fcl/index.md)
fcl/generated/       Generated JSON artifacts (committed)
fcl/unsupported/     FCL samples that exceed the v1 engine — fcl2json errors on these
examples/            simple.toit, embedded.toit, device.toit (models.toit is a shared test fixture)
tests/               Toit test suite (btest)
python/              fuzzy_lab — fcl2json + Plotly Dash viz
docs/superpowers/    Specs and implementation plans
```

## Known limitations (v1)

`fcl2json` errors with `NotImplementedError` on FCL features that would silently produce wrong results, rather than discarding them. The reference samples that hit each limit are kept under `fcl/unsupported/` (see `fcl/index.md`).

- **Membership functions:** only `trape` / `trian` / point-list / singleton are supported. `gbell`, `gauss`, and `sigm` raise.
- **Point-list shapes:** must be one of the canonical 2/3/4-point shoulder/triangle/trapezoid forms. Arbitrary polygons raise.
- **Defuzzification:** only `METHOD : COG` (and the math-equivalent `COGS` alias for singleton-only outputs) is accepted. Anything else (`RM`, `BISECT`, `MOM`, etc.) raises.
- **RULEBLOCK operators:** the engine hardcodes `MIN` for `AND` / activation and `MAX` for `OR` / accumulation. Declarations matching those defaults are accepted as no-ops; any other value (`PROD`, `ASUM`, `SUM`, etc.) raises.
- **One `RULEBLOCK` per `FUNCTION_BLOCK`.** Multiple blocks raise, because their per-block operator overrides would be silently lost.
- **Cosmetic metadata (`RANGE`, `DEFAULT`)** is accepted and discarded — neither affects the math the engine runs.

## Versioning

Semantic-ish. 0.6.x removed geometry helpers from the public API; 0.7.0 adds the JSON loader, `Antecedent.fl-not` + `FuzzyRule.weight`, the RPC service, and the Python tooling (`fcl2json`, `fuzzy-lab`).

## License

See `LICENSE`. Engine math derives from work originally licensed under `LICENSE_ALVES` (eFLL) and `LICENSE_Toitware`; both upstream licenses are preserved at the repository root.
