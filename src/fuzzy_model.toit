// Copyright (c) 2021 Ekorau LLC

import .fuzzy-in-out show *
import .fuzzy-rule

class FuzzyModel:

  name := ""
  crisp-inputs := []  // The physical inputs to the model.
  inputs  := []       // The fuzzy inputs.
  rules   := []       // The fuzzy rules.
  outputs := []       // The fuzzy outputs, NOT physical outputs  See defuzzify /int.

  constructor .name="":                   //The model name is optional.

  add-input input/FuzzyInput -> none:
    inputs.add input
    crisp-inputs.add 0.0

  add-output output/FuzzyOutput -> none:
    outputs.add output

  add-rule rule/FuzzyRule -> none:
    rules.add rule

  changed -> none:                    // TODO For now call explicitly.
    inputs.do: it.clear
    outputs.do: it.clear

  crisp-inputs list/List -> none:
    for i:=0; i<list.size; i+= 1:
      crisp-input i list[i]

  crisp-inputs-named name/string value/num -> none:
    input-names := inputs.map: it.name
    crisp-input (input-names.index-of name) value

  crisp-input index/int value/num -> none:
    crisp-inputs[index] = value
    changed

  defuzzify -> none:
    outputs.do:
      it.defuzzify

  defuzzify index/int -> float:
    return outputs[index].defuzzify

  fuzzify -> none:
    for i:=0; i<crisp-inputs.size; i+= 1:
      inputs[i].fuzzify crisp-inputs[i]
    rules.do: it.evaluate

  is-fired index/int -> bool:  // TODO just fired?
    return rules[index].fired

  /**
  Returns runtime state as a $Map shaped for the RPC `/state` push.

  Distinct from the topology serialization: this is just the dynamic
  data — per-input crisp value and term pertinences, per-output crisp
  value and term pertinences, per-rule name and fired flag.
  */
  serialize-state -> Map:
    in-states := []
    inputs.size.repeat: | i |
      input := inputs[i]
      in-states.add {
        "name":  input.name,
        "crisp": crisp-inputs[i],
        "terms": input.fsets.map: | s | {"name": s.name, "pertinence": s.pertinence},
      }

    out-states := []
    outputs.do: | output |
      // Defuzzify caches its result; calling it before any pertinence is
      // set isn't meaningful, so guard with `is-pertinent`.
      any-pertinent := output.fsets.any: | s | s.is-pertinent
      crisp := any-pertinent ? output.defuzzify : 0.0
      out-states.add {
        "name":  output.name,
        "crisp": crisp,
        "terms": output.fsets.map: | s | {"name": s.name, "pertinence": s.pertinence},
      }

    return {
      "inputs":  in-states,
      "outputs": out-states,
      "rules":   rules.map: | rule | {"name": rule.name, "fired": rule.fired},
    }

  stringify -> string:
    in-str := ""
    inputs.do:
      in-str = in-str + it.stringify + "\n"
    out-str := ""
    outputs.do:
      out-str = out-str + it.stringify + "\n"            

    rule-str := ""
    rules.do:
      rule-str = rule-str + it.stringify + "\n"     
    return "Model: $name \n  Inputs:\n  $in-str  Outputs:\n  $out-str  Rules:\n$rule-str"