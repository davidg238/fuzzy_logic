// Copyright (c) 2026 Ekorau LLC

import .antecedent show Antecedent
import .consequent show Consequent
import .fuzzy_in_out show FuzzyInput FuzzyOutput
import .fuzzy_model show FuzzyModel
import .fuzzy_rule show FuzzyRule
import .fuzzy_set show FuzzySet

/**
Builds a $FuzzyModel from a $Map shaped per the schema in
docs/superpowers/specs/2026-05-08-fuzzy-logic-restructure-design.md.

Imports nothing beyond engine modules: callers do not pull in
http, websocket, or encoding.json.
*/
load-model json/Map -> FuzzyModel:
  model := FuzzyModel json["name"]

  // Index every set by (var-name, term-name) so rule expressions can resolve
  // their leaves by string lookup.
  set-index := {:}

  json["inputs"].do: | spec/Map |
    sets := build-sets_ spec["terms"]
    input := FuzzyInput.sets sets --name=spec["name"]
    model.add-input input
    sets.do: | s/FuzzySet | set-index["$(spec["name"])::$(s.name)"] = s

  json["outputs"].do: | spec/Map |
    sets := build-sets_ spec["terms"]
    output := FuzzyOutput.sets sets --name=spec["name"]
    model.add-output output
    sets.do: | s/FuzzySet | set-index["$(spec["name"])::$(s.name)"] = s

  json["rules"].do: | spec/Map |
    antecedent := build-antecedent_ spec["if"] set-index
    consequent := build-consequent_ spec["then"] set-index
    weight := spec.get "weight" --if-absent=: 1.0
    name   := spec.get "name"   --if-absent=: ""
    rule := FuzzyRule.fl-if antecedent
        --fl-then=consequent
        --name=name
        --weight=weight.to-float
    model.add-rule rule

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

build-antecedent_ node/Map set-index/Map -> Antecedent:
  op := node["op"]
  if op == "is":
    key := "$(node["var"])::$(node["term"])"
    set := set-index.get key --if-absent=: throw "json_loader: unknown set '$key'"
    return Antecedent.fl-set set
  if op == "and":
    args := node["args"]
    return Antecedent.fl-and
        (build-antecedent_ args[0] set-index)
        (build-antecedent_ args[1] set-index)
  if op == "or":
    args := node["args"]
    return Antecedent.fl-or
        (build-antecedent_ args[0] set-index)
        (build-antecedent_ args[1] set-index)
  if op == "not":
    return Antecedent.fl-not (build-antecedent_ node["arg"] set-index)
  throw "json_loader: unknown op '$op'"

build-consequent_ specs/List set-index/Map -> Consequent:
  sets := []
  specs.do: | t/Map |
    key := "$(t["var"])::$(t["term"])"
    set := set-index.get key --if-absent=: throw "json_loader: unknown set '$key'"
    sets.add set
  return Consequent.outputs sets
