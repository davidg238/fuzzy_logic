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

  test "ModelsViaJson" "driver_advanced model matches hand-coded":
    json-model := load-model DRIVER-ADVANCED-JSON
    hand-model := get-driver-advanced
    vectors := [
      [15.0, 5.0, 5.0],
      [50.0, 25.0, 30.0],
      [80.0, 60.0, 75.0],
    ]
    vectors.do: | v/List |
      json-model.crisp-input 0 v[0]
      json-model.crisp-input 1 v[1]
      json-model.crisp-input 2 v[2]
      json-model.fuzzify
      hand-model.crisp-input 0 v[0]
      hand-model.crisp-input 1 v[1]
      hand-model.crisp-input 2 v[2]
      hand-model.fuzzify
      expect-near (hand-model.defuzzify 0) (json-model.defuzzify 0)
      expect-near (hand-model.defuzzify 1) (json-model.defuzzify 1)

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

DRIVER-ADVANCED-JSON ::= {
  "name": "driver_advanced",
  "inputs": [
    {
      "name": "distance",
      "terms": [
        {"name": "near",    "a": 0.0,  "b": 20.0, "c": 20.0,  "d": 40.0},
        {"name": "safe",    "a": 30.0, "b": 50.0, "c": 50.0,  "d": 70.0},
        {"name": "distant", "a": 60.0, "b": 80.0, "c": 100.0, "d": 100.0},
      ],
    },
    {
      "name": "speed",
      "terms": [
        {"name": "stpd",  "a": 0.0,  "b": 0.0,  "c": 0.0,  "d": 0.0},
        {"name": "slow",  "a": 1.0,  "b": 10.0, "c": 10.0, "d": 20.0},
        {"name": "norm",  "a": 15.0, "b": 30.0, "c": 30.0, "d": 50.0},
        {"name": "quick", "a": 45.0, "b": 60.0, "c": 70.0, "d": 70.0},
      ],
    },
    {
      "name": "temperature",
      "terms": [
        {"name": "cold", "a": 0,  "b": 0,  "c": 1,  "d": 14},
        {"name": "good", "a": 5,  "b": 32, "c": 32, "d": 59},
        {"name": "hot",  "a": 50, "b": 68, "c": 86, "d": 86},
      ],
    },
  ],
  "outputs": [
    {
      "name": "risk",
      "terms": [
        {"name": "min", "a": 0.0,  "b": 20.0, "c": 20.0, "d": 40.0},
        {"name": "avg", "a": 30.0, "b": 50.0, "c": 50.0, "d": 70.0},
        {"name": "max", "a": 60.0, "b": 80.0, "c": 80.0, "d": 100.0},
      ],
    },
    {
      "name": "throttle",
      "terms": [
        {"name": "sptd_o",  "a": 0.0,  "b": 0.0,  "c": 0.0,  "d": 0.0},
        {"name": "slow_o",  "a": 1.0,  "b": 10.0, "c": 10.0, "d": 20.0},
        {"name": "norm_o",  "a": 15.0, "b": 30.0, "c": 30.0, "d": 50.0},
        {"name": "quick_o", "a": 45.0, "b": 60.0, "c": 70.0, "d": 70.0},
      ],
    },
  ],
  "rules": [
    // Rule 0: (near OR quick) OR cold -> risk = max
    {
      "if": {
        "op": "or",
        "args": [
          {"op": "or", "args": [
            {"op": "is", "var": "distance", "term": "near"},
            {"op": "is", "var": "speed",    "term": "quick"},
          ]},
          {"op": "is", "var": "temperature", "term": "cold"},
        ],
      },
      "then": [{"var": "risk", "term": "max"}],
    },
    // Rule 1: (safe AND norm) OR good -> [risk = avg, throttle = norm_o]
    {
      "if": {
        "op": "or",
        "args": [
          {"op": "and", "args": [
            {"op": "is", "var": "distance", "term": "safe"},
            {"op": "is", "var": "speed",    "term": "norm"},
          ]},
          {"op": "is", "var": "temperature", "term": "good"},
        ],
      },
      "then": [
        {"var": "risk",     "term": "avg"},
        {"var": "throttle", "term": "norm_o"},
      ],
    },
    // Rule 2: (distant AND slow) OR hot -> [risk = min, throttle = quick_o]
    {
      "if": {
        "op": "or",
        "args": [
          {"op": "and", "args": [
            {"op": "is", "var": "distance", "term": "distant"},
            {"op": "is", "var": "speed",    "term": "slow"},
          ]},
          {"op": "is", "var": "temperature", "term": "hot"},
        ],
      },
      "then": [
        {"var": "risk",     "term": "min"},
        {"var": "throttle", "term": "quick_o"},
      ],
    },
  ],
}
