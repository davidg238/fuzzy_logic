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
    expect-true "tipper" == model.name
    expect-equals 1 model.inputs.size
    expect-true "service" == model.inputs[0].name
    expect-equals 3 model.inputs[0].fsets.size
    expect-true "poor" == model.inputs[0].fsets[0].name
    expect-equals 1 model.outputs.size
    expect-true "tip" == model.outputs[0].name
    expect-equals 2 model.outputs[0].fsets.size

  test-end
