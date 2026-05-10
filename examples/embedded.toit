// Copyright (c) 2026 Ekorau LLC
// Model as a text constant, parsed with encoding.json. ESP32-friendly:
// no http, no websocket. Suitable for shipping a model in a .toit binary.

import encoding.json
import fuzzy-logic show *
import fuzzy-logic.json-loader show load-model

MODEL ::= """
{
  "name": "container_crane",
  "inputs": [
    {"name": "distance", "terms": [
      {"name": "too_far", "a": -5, "b": -5, "c": -5, "d": 0},
      {"name": "zero",    "a": -5, "b":  0, "c":  0, "d": 5},
      {"name": "close",   "a":  0, "b":  5, "c":  5, "d": 10},
      {"name": "medium",  "a":  5, "b": 10, "c": 10, "d": 22},
      {"name": "far",     "a": 10, "b": 22, "c": 22, "d": 22}
    ]},
    {"name": "angle", "terms": [
      {"name": "neg_big",  "a": -50, "b": -50, "c": -50, "d": -5},
      {"name": "zero",     "a":  -5, "b":   0, "c":   0, "d":  5},
      {"name": "pos_big",  "a":   5, "b":  50, "c":  50, "d": 50}
    ]}
  ],
  "outputs": [
    {"name": "power", "terms": [
      {"name": "neg_high",  "a": -27, "b": -27, "c": -27, "d": -27},
      {"name": "zero",      "a":   0, "b":   0, "c":   0, "d":   0},
      {"name": "pos_high",  "a":  27, "b":  27, "c":  27, "d":  27}
    ]}
  ],
  "rules": [
    {"if": {"op": "and", "args": [
       {"op": "is", "var": "distance", "term": "far"},
       {"op": "is", "var": "angle",    "term": "zero"}
     ]}, "then": [{"var": "power", "term": "pos_high"}]}
  ]
}
"""

main:
  spec := json.parse MODEL
  model := load-model spec
  model.crisp-input 0 15.0   // distance
  model.crisp-input 1 0.0    // angle
  model.fuzzify
  print "(d=15, a=0) -> power=$(%.2f model.defuzzify 0)"
