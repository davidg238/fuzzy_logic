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

  test "JsonLoader" "loads simple IS rule":
    json := {
      "name": "tiny",
      "inputs": [{"name": "x", "terms": [
        {"name": "low",  "a": 0, "b": 0, "c": 0, "d": 5},
        {"name": "high", "a": 5, "b": 10, "c": 10, "d": 10},
      ]}],
      "outputs": [{"name": "y", "terms": [
        {"name": "off", "a": 0, "b": 0, "c": 0, "d": 0},
        {"name": "on",  "a": 1, "b": 1, "c": 1, "d": 1},
      ]}],
      "rules": [
        {"if":   {"op": "is", "var": "x", "term": "high"},
         "then": [{"var": "y", "term": "on"}]},
      ],
    }
    model := load-model json
    expect-equals 1 model.rules.size
    model.crisp-input 0 8.0
    model.fuzzify
    out := model.defuzzify 0
    expect-near 1.0 out

  test "JsonLoader" "loads AND, OR, NOT, weight":
    json := {
      "name": "ops",
      "inputs": [
        {"name": "x", "terms": [
          {"name": "lo", "a": 0, "b": 0, "c": 0, "d": 10},
          {"name": "hi", "a": 0, "b": 10, "c": 10, "d": 10},
        ]},
        {"name": "y", "terms": [
          {"name": "lo", "a": 0, "b": 0, "c": 0, "d": 10},
          {"name": "hi", "a": 0, "b": 10, "c": 10, "d": 10},
        ]},
      ],
      "outputs": [{"name": "z", "terms": [
        {"name": "off", "a": 0, "b": 0, "c": 0, "d": 0},
        {"name": "on",  "a": 1, "b": 1, "c": 1, "d": 1},
      ]}],
      "rules": [
        {
          "weight": 0.5,
          "if": {
            "op": "and",
            "args": [
              {"op": "or", "args": [
                {"op": "is", "var": "x", "term": "hi"},
                {"op": "is", "var": "y", "term": "hi"},
              ]},
              {"op": "not", "arg": {"op": "is", "var": "x", "term": "lo"}},
            ],
          },
          "then": [{"var": "z", "term": "on"}],
        },
      ],
    }
    model := load-model json
    expect-equals 1 model.rules.size
    expect-near 0.5 model.rules[0].weight

  test "JsonLoader" "loads multi-output consequent":
    json := {
      "name": "multi",
      "inputs": [{"name": "x", "terms": [
        {"name": "any", "a": 0, "b": 5, "c": 5, "d": 10},
      ]}],
      "outputs": [
        {"name": "a", "terms": [{"name": "on", "a": 0, "b": 5, "c": 5, "d": 10}]},
        {"name": "b", "terms": [{"name": "on", "a": 0, "b": 5, "c": 5, "d": 10}]},
      ],
      "rules": [
        {"if":   {"op": "is", "var": "x", "term": "any"},
         "then": [
           {"var": "a", "term": "on"},
           {"var": "b", "term": "on"},
         ]},
      ],
    }
    model := load-model json
    model.crisp-input 0 5.0
    model.fuzzify
    expect-near 5.0 (model.defuzzify 0)
    expect-near 5.0 (model.defuzzify 1)

  test-end
