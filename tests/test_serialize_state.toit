// Copyright (c) 2026 Ekorau LLC

import btest show *
import fuzzy-logic show *
import fuzzy-logic.json-loader show load-model

main:
  test-start

  test "SerializeState" "before fuzzify, all pertinences are 0":
    model := load-model SAMPLE
    state := model.serialize-state
    expect-true state["inputs"] is List
    expect-equals 1 state["inputs"].size
    expect-true state["inputs"][0]["name"] == "x"
    expect-near 0.0 state["inputs"][0]["crisp"]
    state["inputs"][0]["terms"].do: | t |
      expect-near 0.0 t["pertinence"]
    state["outputs"].do: | o |
      o["terms"].do: | t |
        expect-near 0.0 t["pertinence"]

  test "SerializeState" "after fuzzify, fired rule is reflected":
    model := load-model SAMPLE
    model.crisp-input 0 8.0
    model.fuzzify
    state := model.serialize-state
    expect-near 8.0 state["inputs"][0]["crisp"]
    fired := state["rules"][0]["fired"]
    expect-true fired

  test "SerializeState" "rule names round-trip":
    model := load-model SAMPLE
    state := model.serialize-state
    expect-true state["rules"][0]["name"] == "r1"

  test-end

SAMPLE ::= {
  "name": "tiny",
  "inputs": [
    {
      "name": "x",
      "terms": [
        {"name": "lo", "a": 0, "b": 0,  "c": 0,  "d": 10},
        {"name": "hi", "a": 0, "b": 10, "c": 10, "d": 10},
      ],
    },
  ],
  "outputs": [
    {
      "name": "y",
      "terms": [
        {"name": "off", "a": 0, "b": 0, "c": 0, "d": 0},
        {"name": "on",  "a": 0, "b": 5, "c": 5, "d": 10},
      ],
    },
  ],
  "rules": [
    {
      "name": "r1",
      "if":   {"op": "is", "var": "x", "term": "hi"},
      "then": [{"var": "y", "term": "on"}],
    },
  ],
}
