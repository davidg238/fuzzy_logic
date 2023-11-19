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