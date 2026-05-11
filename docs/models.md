# Authoring models

A `fuzzy_logic` model is described by a JSON document — a contract shared between the Toit engine, the Python `fcl2json` tool, the HTTP API, and the visualizer. You can author models in three formats; all three land at the same JSON.

## Three formats

### 1. Toit `Map` literal

The smallest path. The model is a Toit `Map` constant, loaded by `fuzzy-logic.json-loader.load-model`. No `encoding.json` round-trip, no file I/O.

```toit
import fuzzy-logic.json-loader show load-model

MODEL ::= {
  "name": "tipper",
  "inputs":  [...],
  "outputs": [...],
  "rules":   [...],
}

model := load-model MODEL
```

Used by `examples/simple.toit`. Best for small fixed models that ship with the firmware.

### 2. JSON string + `encoding.json.parse`

For readability when the model is large, embed a multi-line `"""…"""` JSON string. Same runtime behavior as #1; cheaper to copy-paste from `.fcl`-generated JSON.

```toit
import encoding.json
import fuzzy-logic.json-loader show load-model

MODEL ::= """
{
  "name": "tipper",
  ...
}
"""

model := load-model (json.parse MODEL)
```

Used by `examples/embedded.toit`.

### 3. FCL file → `fcl2json` → JSON file

For models you want to author in standard FCL or share across tools. `python -m fuzzy_lab.fcl2json` (CLI: `fcl2json`) converts a `.fcl` to JSON; the Toit side then reads the JSON from disk or from an asset.

```bash
cd python
uv run fcl2json ../fcl/tipper.fcl > ../fcl/generated/tipper.json
# or batch:
uv run fcl2json --all ../fcl --out-dir ../fcl/generated
```

```toit
import host.file as file
import encoding.json
import fuzzy-logic.json-loader show load-model

main:
  text  := (file.read-contents "fcl/generated/tipper.json").to-string
  model := load-model (json.parse text)
```

Used by `examples/device.toit`. The FCL grammar subset and error contract are in [fcl.md](fcl.md).

## JSON schema

The single source of truth shared by every component. Every model is a JSON object with this shape:

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
      "name": "R1",
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

### Schema rules

- **Term shape**: every TERM is `{name, a, b, c, d}`. Float-ish numbers; the four values must satisfy `a ≤ b ≤ c ≤ d`. The engine's `FuzzySet` constructor picks the shape subclass from vertex equality — see [engine.md#shape-dispatch](engine.md#shape-dispatch). No `type` field.
- **Rule expression tree**: `op ∈ {"is", "and", "or", "not"}`.
  - `"is"` is a leaf: `{op: "is", var: "<input-name>", term: "<term-name>"}`.
  - `"and"` / `"or"` carry `args` (a list, typically length 2; longer is fine and nests pairwise).
  - `"not"` carries `arg` (single child).
- **Consequent**: `then` is always a list (single-output rules use a list of length 1). Each entry is `{var, term}`.
- **`weight`** is optional, default `1.0`. FCL `WITH <num>` lands here.
- **`name`** on rules is optional; `fcl2json` synthesizes readable names from the antecedent if absent (e.g., `"R1: service is poor OR food is rancid → tip is cheap"`).
- **`defuzz_method`** is recorded but only `COG` (and the math-equivalent `COGS` alias for singleton-only outputs) is honored. `fcl2json` rejects anything else — see [fcl.md](fcl.md).

## Worked examples

The repo ships generated JSON for every supported `.fcl`. Browse `fcl/generated/*.json` for working models across a range of complexity:

| Model | Shape |
|---|---|
| `tipper.json` | 2-in 1-out, simple OR rules |
| `driver.json` | 1-in 1-out, simplest possible |
| `lecture_1.json` | 2-in 1-out, 4 AND rules |
| `fan-speed.json`, `air-conditioning.json` | 2-in 1-out, 16 AND rules |
| `casco.json` | 3-in 1-out, 35 chained AND rules |
| `container-crane.json` | 2-in 1-out singleton outputs (COGS-style) |
| `driver_advanced.json` | 3-in 2-out, nested OR/AND, **multi-output consequents** |
| `ip.json`, `ip2.json`, `block.json` | inverted-pendulum control |

The third-party originals are in `fcl/`. The first-party models pair with hand-coded counterparts in `examples/models.toit`; `examples/check_fcl_parity.toit` confirms FCL-derived JSON produces bit-identical defuzzify outputs to the hand model.

## Validation

There's no separate schema validator yet. The Toit `json-loader` errors at construction if a referenced var or term doesn't exist; the Python `fcl2json` errors at parse time for unsupported FCL. Round-trip every new FCL through `fcl2json --all` and run the parity check (or your own test) before deploying.
