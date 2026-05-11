# Getting started

The smallest possible path to a defuzzified output, on the host. Five minutes total.

## Prerequisites

- A working Toit toolchain (`jag toit ...`). Install: <https://toitlang.org/get-started>.
- For the visualizer (optional): Python 3.12+ and [uv](https://docs.astral.sh/uv/).

## A minimum-effort inference run

The tightest dependency surface — engine module only, no JSON loader, no `encoding.json`. The tipper has one input (service quality), one output (tip percentage), and three rules:

```toit
import fuzzy-logic show *

main:
  poor      := FuzzySet 0.0 0.0 0.0 4.0 "poor"
  good      := FuzzySet 1.0 4.0 6.0 9.0 "good"
  excellent := FuzzySet 6.0 9.0 9.0 9.0 "excellent"
  service := FuzzyInput.sets [poor, good, excellent] --name="service"

  cheap    := FuzzySet  0.0  5.0  5.0 10.0 "cheap"
  average  := FuzzySet 10.0 15.0 15.0 20.0 "average"
  generous := FuzzySet 20.0 25.0 25.0 30.0 "generous"
  tip := FuzzyOutput.sets [cheap, average, generous] --name="tip"

  model := FuzzyModel "tipper"
  model.add-input service
  model.add-output tip
  model.add-rule (FuzzyRule.fl-if (Antecedent.fl-set poor)      --fl-then=(Consequent.output cheap))
  model.add-rule (FuzzyRule.fl-if (Antecedent.fl-set good)      --fl-then=(Consequent.output average))
  model.add-rule (FuzzyRule.fl-if (Antecedent.fl-set excellent) --fl-then=(Consequent.output generous))

  model.crisp-input 0 7.5
  model.fuzzify
  print "service=7.5 -> tip=$(%.2f model.defuzzify 0)"
# service=7.5 -> tip=20.00
```

That's the engine API in full: `FuzzySet` / `FuzzyInput` / `FuzzyOutput` / `FuzzyRule` / `Antecedent` / `Consequent` / `FuzzyModel`, then the inference cycle (`crisp-input` → `fuzzify` → `defuzzify`). At `service=7.5` both `good` (pertinence 0.5) and `excellent` (also 0.5) fire, so the defuzzified output is a weighted blend of `average` and `generous` — `20.0`.

## Same model as a Map literal

For larger models the declarative form gets verbose. Authoring the model as a Toit `Map` literal and parsing it with `fuzzy-logic.json-loader` is more compact — at the cost of one extra import. `examples/simple.toit` is exactly this, for the same tipper:

```bash
jag toit run examples/simple.toit
# service=7.5 -> tip=20.00
```

```toit
import fuzzy-logic show *
import fuzzy-logic.json-loader show load-model

MODEL ::= {
  "name": "tipper",
  "inputs":  [{"name":"service","terms":[
    {"name":"poor","a":0,"b":0,"c":0,"d":4},
    {"name":"good","a":1,"b":4,"c":6,"d":9},
    {"name":"excellent","a":6,"b":9,"c":9,"d":9},
  ]}],
  "outputs": [{"name":"tip","terms":[
    {"name":"cheap",   "a":0, "b":5,  "c":5,  "d":10},
    {"name":"average", "a":10,"b":15, "c":15, "d":20},
    {"name":"generous","a":20,"b":25, "c":25, "d":30},
  ]}],
  "rules": [
    {"if":{"op":"is","var":"service","term":"poor"},      "then":[{"var":"tip","term":"cheap"}]},
    {"if":{"op":"is","var":"service","term":"good"},      "then":[{"var":"tip","term":"average"}]},
    {"if":{"op":"is","var":"service","term":"excellent"}, "then":[{"var":"tip","term":"generous"}]},
  ],
}

main:
  model := load-model MODEL
  model.crisp-input 0 7.5
  model.fuzzify
  print "service=7.5 -> tip=$(%.2f model.defuzzify 0)"
```

The two forms produce identical inference output — same terms, same rules, same dispatch. Pick whichever fits your style. See [models.md](models.md) for the FCL-file path too.

## See the same model in the visualizer

In one shell, start the engine with an HTTP service:

```bash
jag toit run examples/device.toit
# fuzzy_logic RpcService listening on :8090 (model=tipper)
```

In another shell:

```bash
cd python && uv sync --all-extras
uv run fuzzy-lab --connect http://127.0.0.1:8090
# Open http://127.0.0.1:8050/
```

The dropdown at the top of the page lists every `.fcl` in `fcl/`. Pick one to hot-swap the engine model in place. Sliders drive crisp inputs and the page polls `/state` every 500 ms.

More detail: [visualizer.md](visualizer.md), [rpc-service.md](rpc-service.md).

## Next steps

- **Deploy to an ESP32:** [esp32-deployment.md](esp32-deployment.md).
- **Author your own model:** [models.md](models.md) walks through the three formats (inline `Map`, JSON string, FCL → JSON).
- **Understand the engine internals:** [engine.md](engine.md).
