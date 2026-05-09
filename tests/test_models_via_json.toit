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
    {
      "name": "distance",
      "terms": [
        {"name": "small", "a": 0.0,  "b": 20.0, "c": 20.0,  "d": 40.0},
        {"name": "safe",  "a": 30.0, "b": 50.0, "c": 50.0,  "d": 70.0},
        {"name": "big",   "a": 60.0, "b": 80.0, "c": 100.0, "d": 100.0},
      ],
    },
  ],
  "outputs": [
    {
      "name": "speed",
      "terms": [
        {"name": "slow",    "a": 0.0,  "b": 10.0, "c": 10.0, "d": 20.0},
        {"name": "average", "a": 10.0, "b": 20.0, "c": 30.0, "d": 40.0},
        {"name": "fast",    "a": 30.0, "b": 40.0, "c": 40.0, "d": 50.0},
      ],
    },
  ],
  "rules": [
    {"if": {"op": "is", "var": "distance", "term": "small"}, "then": [{"var": "speed", "term": "slow"}]},
    {"if": {"op": "is", "var": "distance", "term": "safe"},  "then": [{"var": "speed", "term": "average"}]},
    {"if": {"op": "is", "var": "distance", "term": "big"},   "then": [{"var": "speed", "term": "fast"}]},
  ],
}
