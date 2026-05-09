// Copyright (c) 2026 Ekorau LLC

import .antecedent show Antecedent
import .consequent show Consequent
import .fuzzy_in_out show FuzzyInput FuzzyOutput
import .fuzzy_model show FuzzyModel
import .fuzzy_rule show FuzzyRule RuleTerm
import .fuzzy_set show FuzzySet

/**
Builds a $FuzzyModel from a $Map shaped per the schema in
docs/superpowers/specs/2026-05-08-fuzzy-logic-restructure-design.md.

Imports nothing beyond engine modules: callers do not pull in
http, websocket, or encoding.json.
*/
load-model json/Map -> FuzzyModel:
  model := FuzzyModel json["name"]

  json["inputs"].do: | spec/Map |
    input := FuzzyInput.sets (build-sets_ spec["terms"]) --name=spec["name"]
    model.add-input input

  json["outputs"].do: | spec/Map |
    output := FuzzyOutput.sets (build-sets_ spec["terms"]) --name=spec["name"]
    model.add-output output

  // Rules wired up in a later task.
  return model

build-sets_ specs/List -> List:
  result := []
  specs.do: | t/Map |
    result.add (FuzzySet
        t["a"].to-float
        t["b"].to-float
        t["c"].to-float
        t["d"].to-float
        t["name"])
  return result
