# `fcl/` — FCL source files

Hand-written `.fcl` files (Fuzzy Control Language). Convert any of them with:

```
cd python && uv run fcl2json ../fcl/<name>.fcl > ../fcl/generated/<name>.json
uv run fcl2json --all ../fcl --out-dir ../fcl/generated   # batch
```

`fcl/generated/*.json` is then loadable by `fuzzy-logic.json-loader` and visible in the Plotly Dash visualizer's file picker (the picker globs `fcl/*.fcl` non-recursively, so files under `fcl/unsupported/` are intentionally excluded).

## First-party models (paired with `examples/models.toit`)

These were ported from the original Toit hand-coded models. `examples/check_fcl_parity.toit` confirms each FCL produces bit-identical defuzzify outputs to its `get-<name>` counterpart at fixed input vectors.

| File | Domain | Inputs → Outputs | Source |
|---|---|---|---|
| `air-conditioning.fcl` | AC fan speed control | temperature, humidity → speed | [Cingolani / citeseerx](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.486.1238) |
| `casco.fcl` | weather-based watering schedule (Spanish *casco*) | humidity, temperature, season → weather | jFuzzyLogic example |
| `container-crane.fcl` | crane motor power control | distance, angle → power | [IEC 1131-7 spec](https://jfuzzylogic.sourceforge.net/html/pdf/iec_1131_7_cd1.pdf) Fig C.15 |
| `driver.fcl` | basic vehicle speed control | distance → speed | original eFLL example |
| `driver_advanced.fcl` | risk + throttle from multiple inputs | distance, speed, temperature → risk, throttle | original eFLL example; uses nested `OR/AND` and multi-output rules |
| `fan-speed.fcl` | fan speed (alternate of air-conditioning) | temperature, humidity → speed | original eFLL example; same rule structure as `air-conditioning.fcl`, different MFs |
| `lecture_1.fcl` | quality assessment from object size+weight | size, weight → quality | [Massey 159.741 lecture slides](https://www.massey.ac.nz/~nhreyes/MASSEY/159741/Lectures/Lec2012-3-159741-FuzzyLogic-v.2.pdf); pinned by `tests/test_lecture_1.toit` |

## Third-party reference samples (FCL ecosystem)

Imported to test parser coverage and as sample FCL bodies users may have seen elsewhere.

| File | Domain | Notes |
|---|---|---|
| `tipper.fcl` | restaurant tip from service+food quality | jFuzzyLogic's canonical sample (the "hello world" of FCL); from Matlab's fuzzy logic toolbox tutorial |
| `tipping.fcl` | restaurant tip | minor-syntax variant of `tipper.fcl` |
| `z.fcl` | restaurant tip | another tipper variant with slightly different shoulders |
| `block.fcl` | inverted pendulum, simplified | 3-input cart-pole controller (force from x, dxdt, dx) — small-pendulum variant of `ip.fcl` |
| `ip.fcl` | inverted pendulum, full | 4-input cart-pole controller (force from x, dxdt, phi, dphidt) |
| `ip2.fcl` | inverted pendulum, angle sub-controller | 2-input variant focusing on phi, dphidt — `FUNCTION_BLOCK ipPhi0` |

## `fcl/unsupported/` — files that exceed the v1 engine

`fcl2json` errors with `NotImplementedError` on each of these. They're kept in the repo as documentation of v1's hard limits and as regression fixtures for the strict-error paths (see `python/tests/test_fcl2json_grammar.py::test_unsupported_fcl_files_raise`). The viz picker does **not** list them.

| File | What's unsupported | Notes |
|---|---|---|
| `membershipFunctionsDemo.fcl` | `gbell` / `gauss` / `sigm` MFs + irregular point list | jFuzzyLogic sample of every MF type |
| `qualify.fcl` | `sigm` MFs (plus a benign `ACCU : SUM`) | credit-qualification model |
| `qualify_optimized.fcl` | `sigm` MFs + degenerate point list | optimized version of `qualify.fcl` |
| `tipping2.fcl` | `AND : PROD`, `OR : ASUM`, multiple `RULEBLOCK`s | `fuzzylite 6.0`-generated tipper |
| `triage.fcl` | `METHOD : RM` (right-modal defuzz) | back-pain triage from [a Stack Overflow question](https://stackoverflow.com/questions/43327446/how-to-run-fuzzy-control-language) |

If you author new FCL that needs any of these features, see the README's [Known limitations](../README.md#known-limitations-v1) section first.
