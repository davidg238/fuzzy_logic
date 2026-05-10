// Copyright (c) 2026 Ekorau LLC
// Inline-JSON demo: smallest path to a defuzzified output. No RPC.

import fuzzy-logic show *
import fuzzy-logic.json-loader show load-model

MODEL ::= {
  "name": "tipper",
  "defuzz_method": "COG",
  "inputs": [
    {"name": "service", "terms": [
      {"name": "poor",      "a": 0, "b": 0, "c": 0, "d": 4},
      {"name": "good",      "a": 1, "b": 4, "c": 6, "d": 9},
      {"name": "excellent", "a": 6, "b": 9, "c": 9, "d": 9},
    ]},
  ],
  "outputs": [
    {"name": "tip", "terms": [
      {"name": "cheap",   "a": 0,  "b": 5,  "c": 5,  "d": 10},
      {"name": "average", "a": 10, "b": 15, "c": 15, "d": 20},
      {"name": "generous","a": 20, "b": 25, "c": 25, "d": 30},
    ]},
  ],
  "rules": [
    {"if": {"op": "is", "var": "service", "term": "poor"},      "then": [{"var": "tip", "term": "cheap"}]},
    {"if": {"op": "is", "var": "service", "term": "good"},      "then": [{"var": "tip", "term": "average"}]},
    {"if": {"op": "is", "var": "service", "term": "excellent"}, "then": [{"var": "tip", "term": "generous"}]},
  ],
}

main:
  model := load-model MODEL
  model.crisp-input 0 7.5
  model.fuzzify
  print "service=7.5 -> tip=$(%.2f model.defuzzify 0)"
