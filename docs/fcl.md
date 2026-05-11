# FCL reference

`fuzzy_logic` accepts the standard subset of [Fuzzy Control Language](https://en.wikipedia.org/wiki/Fuzzy_Control_Language) (IEC 61131-7 informally; also used by jFuzzyLogic and fuzzylite). The host-side converter `fcl2json` reads `.fcl` and emits the JSON schema described in [models.md](models.md). The catalogue of `.fcl` files in `fcl/` is documented in [`fcl/index.md`](../fcl/index.md).

## Quickstart

```bash
cd python && uv sync --all-extras

# Convert one file:
uv run fcl2json ../fcl/tipper.fcl > ../fcl/generated/tipper.json
uv run fcl2json ../fcl/tipper.fcl --output ../fcl/generated/tipper.json

# Convert every .fcl in a directory:
uv run fcl2json --all ../fcl --out-dir ../fcl/generated
```

`--all` reports per-file success/failure and continues on errors, so a single unsupported file doesn't abort the batch.

## Supported subset

```
FUNCTION_BLOCK <name>
  VAR_INPUT  <name> : REAL; ... END_VAR
  VAR_OUTPUT <name> : REAL; ... END_VAR

  FUZZIFY <var>
    TERM <name> := <shape> ;
    ...
  END_FUZZIFY

  DEFUZZIFY <var>
    TERM <name> := <shape> ;
    METHOD : COG ;        // or COGS for singleton-only outputs
    DEFAULT := 0 ;        // accepted-and-discarded
    ...
  END_DEFUZZIFY

  RULEBLOCK <name>
    AND  : MIN ;          // optional no-op; only MIN accepted
    OR   : MAX ;          // optional no-op; only MAX accepted
    ACT  : MIN ;          // optional no-op; only MIN accepted
    ACCU : MAX ;          // optional no-op; only MAX accepted
    RULE <id> : IF <expr> THEN <consequent> [WITH <weight>] ;
    ...
  END_RULEBLOCK
END_FUNCTION_BLOCK
```

### Term shapes

| Form | Maps to `(a, b, c, d)` |
|---|---|
| `trape a b c d` (or `Trapezoid a b c d`) | `(a, b, c, d)` directly |
| `trian a b c` (or `Triangle a b c`) | `(a, b, b, c)` |
| `<num>` (singleton) | `(num, num, num, num)` |
| `(a,1) (b,0)` (left rising / left shoulder) | `(a, a, a, b)` (LRA) |
| `(a,0) (b,1)` (right shoulder) | `(a, b, b, b)` (RRA) |
| `(a,1) (b,1) (c,0)` (left plateau falling) | `(a, a, b, c)` (LTrap) |
| `(a,0) (b,1) (c,1)` (right plateau rising) | `(a, b, c, c)` (RTrap) |
| `(a,0) (b,1) (c,0)` (triangle) | `(a, b, b, c)` |
| `(a,0) (b,1) (c,1) (d,0)` (full trapezoid) | `(a, b, c, d)` |

The `(x, y)`-point form is normalised to `(a, b, c, d)` by sorting on `x` and recognising the canonical shape. Arbitrary polygons that don't match one of the patterns above raise.

### Rule expressions

```
IF distance IS far                      THEN power IS pos_medium ;
IF distance IS NOT close                THEN power IS pos_medium ;
IF a IS x AND b IS y                    THEN out IS z ;
IF a IS x OR  b IS y                    THEN out IS z ;
IF NOT (a IS x AND b IS y)              THEN out IS z ;
IF a IS x AND b IS y THEN out1 IS p, out2 IS q ;       // multi-output
IF a IS x THEN out IS z WITH 0.5 ;                     // weighted
```

`AND` is left-associative; `IF a AND b AND c` becomes `((a AND b) AND c)`. Use parentheses where you mean something else. `NOT` binds tighter than `AND`, which binds tighter than `OR`.

## What raises

`fcl2json` raises `NotImplementedError` (with file/line context) on any declaration whose semantics the engine doesn't honor, rather than silently discarding it.

| Declaration | Result |
|---|---|
| `gbell`, `gauss`, `sigm` term forms | raises |
| Irregular point-list shapes (not in the 2/3/4-point table above) | raises |
| `METHOD : <non-COG/COGS>` (`RM`, `BISECT`, `MOM`, …) | raises |
| `AND : <non-MIN>` (`PROD`, …) | raises |
| `OR : <non-MAX>` (`ASUM`, …) | raises |
| `ACT : <non-MIN>` | raises |
| `ACCU : <non-MAX>` (`SUM`, …) | raises |
| Multiple `RULEBLOCK`s in one `FUNCTION_BLOCK` | raises |

The accepted no-op declarations exist so that FCL files matching the engine's defaults (the majority of jFuzzyLogic / fuzzylite samples) still parse cleanly.

### Cosmetic metadata (accepted-and-discarded)

| Declaration | Why it's silently OK |
|---|---|
| `RANGE := (lo .. hi) ;` | display metadata; engine has no notion of variable bounds |
| `DEFAULT := <num> ;` | applies only if no rule fires; engine returns 0/NaN regardless |
| Rule-id values | the engine treats rule names as cosmetic labels |

## Reference samples that exceed v1

The repo keeps five third-party samples that fail conversion under `fcl/unsupported/`. They're useful as documentation of v1's hard limits and as regression fixtures for the strict-error paths. The visualizer's file picker globs `fcl/*.fcl` non-recursively, so they don't clutter the dropdown.

See [`fcl/index.md`](../fcl/index.md) for the catalogue (which one demonstrates which limit).

## Authoring tips

- **Filenames may contain `-`** but `FUNCTION_BLOCK NAME` must match `[A-Za-z_][A-Za-z0-9_]*` — use underscores in the block name (`fan_speed`) while the file is `fan-speed.fcl`. The engine's `model.name` field is what matters at runtime; `fcl2json` reads it from the block name.
- **Term names must follow the same NAME pattern.** No hyphens; use snake_case or camelCase.
- **Round-trip every new FCL** via `uv run pytest python/tests/test_fcl2json_round_trip.py -k <name>` — that test exercises the full `fcl2json → load-model → fuzzify → defuzzify` path.

## Related

- [models.md](models.md) — the JSON schema FCL converts to.
- [visualizer.md](visualizer.md) — picking an FCL in the file picker for live inspection.
- [`fcl/index.md`](../fcl/index.md) — every file in `fcl/` summarised.
