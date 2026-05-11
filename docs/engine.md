# Engine reference

The Toit engine lives under `src/`. This page covers the public API surface and the key concepts. For deployment, see [esp32-deployment.md](esp32-deployment.md); for authoring models, see [models.md](models.md).

## Concepts

A `FuzzyModel` owns ordered lists of `FuzzyInput`s, `FuzzyOutput`s, and `FuzzyRule`s. Each `FuzzyInput` / `FuzzyOutput` carries a list of `FuzzySet` terms; each term is four floats `(a, b, c, d)` describing a trapezoid (with `a ≤ b ≤ c ≤ d`).

An inference cycle has three steps:

1. **`model.crisp-input i value`** — assigns a crisp value to input `i` and clears any prior pertinence state.
2. **`model.fuzzify`** — runs the antecedent of every rule; each consequent term is truncated to the rule's activation power (`antecedent_power × rule.weight`).
3. **`model.defuzzify i`** — returns the crisp value for output `i` via center-of-gravity over the *union* of truncated output sets (max-accumulation, COG defuzz).

```toit
model := load-model MODEL
model.crisp-input 0 5.0     // assign first input
model.crisp-input 1 7.0     // additional inputs by index
model.fuzzify
out := model.defuzzify 0    // first output
```

## Shape dispatch

The `FuzzySet` constructor picks a subclass from vertex equality:

| (a, b, c, d) pattern | Subclass | `stype` |
|---|---|---|
| `a = b = c = d` | `SingletonSet` | `"sing"` |
| `a = b = c < d` | `LraTriangularSet` (left right-angle triangle) | `"tri.lra"` |
| `a < b = c = d` | `RraTriangularSet` (right right-angle triangle) | `"tri.rra"` |
| `a = b < c < d` | `LTrapezoidalSet` | `"trap.l"` |
| `a < b < c = d` | `RTrapezoidalSet` | `"trap.r"` |
| `a < b = c < d` | `TriangularSet` | `"tri"` |
| `a < b < c < d` | `TrapezoidalSet` | `"trap"` |

This means the JSON schema doesn't carry a `type` field — the shape is derived from the four numbers.

## Closed-form centroid math

Each `FuzzySet` subclass implements `truncated-area` and `truncated-weighted-centroid` as closed-form expressions of `(a, b, c, d)` and the current truncation height `h`. No polygon vertices, no shoelace formula, no `Point2f`. `SingletonSet`'s contract: `truncated-area = h`, `truncated-weighted-centroid = a × h`, so the general weighted-COG formula `Σ aᵢ·hᵢ / Σ hᵢ` works for singleton-only outputs.

The per-shape derivations live in `src/fuzzy_set.toit`. Test coverage in `tests/test_closed_form_centroid.toit` pins one or two heights per subclass.

## API surface

### `FuzzyModel`

```toit
class FuzzyModel:
  constructor name/string := ""
  add-input  input/FuzzyInput
  add-output output/FuzzyOutput
  add-rule   rule/FuzzyRule
  crisp-input i/int value/float
  fuzzify
  defuzzify i/int -> float
  serialize-state -> Map      // for RpcService /state — see rpc-service.md
```

### `FuzzyInput`, `FuzzyOutput`

```toit
class FuzzyInput:
  constructor.sets sets/List --name/string

class FuzzyOutput:
  constructor.sets sets/List --name/string
```

### `FuzzySet` (and subclasses)

```toit
FuzzySet a/float b/float c/float d/float name/string -> FuzzySet
// Dispatches to the right subclass via vertex equality.

set.max  h/float        // assign a truncation height (in-place)
set.clear               // reset truncation to 0
set.truncated-area                    -> float
set.truncated-weighted-centroid       -> float
set.stype                             -> string
```

### `FuzzyRule`, `Antecedent`, `Consequent`

```toit
class FuzzyRule:
  constructor.fl-if ant/Antecedent --fl-then/Consequent --name/string := "" --weight/float := 1.0

Antecedent.fl-set    term/FuzzySet                              // "var IS term"
Antecedent.fl-and    a/Antecedent b/Antecedent                  // (also accepts FuzzySet args)
Antecedent.fl-or     a/Antecedent b/Antecedent
Antecedent.fl-not    inner/Antecedent                           // logical NOT
// Convenience: fl-and / fl-or accept FuzzySet or Antecedent operands.

Consequent.output    term/FuzzySet                              // single THEN
Consequent.outputs   terms/List                                 // multi-output THEN
```

A rule's contribution to its consequent terms equals `antecedent_power × rule.weight`. Default weight is `1.0`; FCL `WITH 0.5` lands as `weight = 0.5`.

## Layering

Three import surfaces, each opt-in:

```
src/fuzzy_logic.toit         imports: engine modules only
src/json_loader.toit         imports: engine modules only
src/rpc_service.toit         imports: json_loader + http + encoding.json
```

| You wrote… | Pulls in `pkg-http`? | Pulls in `pkg-host`? |
|---|---|---|
| `import fuzzy-logic show *` | no | no |
| `import fuzzy-logic.json-loader show load-model` | no | no |
| `import fuzzy-logic.rpc-service show RpcService` | yes | no |

If you also read the model JSON from disk (Pattern 3 in [esp32-deployment.md](esp32-deployment.md)), you bring `pkg-host` in yourself via `import host.file as file`.

## Where each thing lives

| Concern | File |
|---|---|
| Top-level re-exports | `src/fuzzy_logic.toit` |
| Model + cycle | `src/fuzzy_model.toit` |
| Input / output shells | `src/fuzzy_in_out.toit` |
| Set shapes + math | `src/fuzzy_set.toit` |
| Rule + weight | `src/fuzzy_rule.toit` |
| Antecedent tree | `src/antecedent.toit` |
| Consequent | `src/consequent.toit` |
| Defuzz accumulation | `src/composition.toit` |
| JSON loader | `src/json_loader.toit` |
| RPC service | `src/rpc_service.toit` |
