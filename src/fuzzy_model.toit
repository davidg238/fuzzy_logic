// Copyright (c) 2021 Ekorau LLC

import .fuzzy_in_out show *
import .fuzzy_rule

class FuzzyModel:

  name := ""
  crisp_inputs := []  // The physical inputs to the model.
  inputs  := []       // The fuzzy inputs.
  rules   := []       // The fuzzy rules.
  outputs := []       // The fuzzy outputs, NOT physical outputs  See defuzzify /int.

  constructor .name="":                   //The model name is optional.

  add_input input/FuzzyInput -> none:
    inputs.add input
    crisp_inputs.add 0.0

  add_output output/FuzzyOutput -> none:
    outputs.add output

  add_rule rule/FuzzyRule -> none:
    rules.add rule

  changed -> none:                    // TODO For now call explicitly.
    inputs.do: it.clear
    outputs.do: it.clear

  crisp_inputs list/List -> none:
    for i:=0; i<list.size; i+= 1:
      crisp_input i list[i]

  crisp_inputs_named name/string value/num -> none:
    input_names := inputs.map: it.name
    crisp_input (input_names.index_of name) value

  crisp_input index/int value/num -> none:
    crisp_inputs[index] = value

  defuzzify -> none:
    outputs.do:
      it.defuzzify

  defuzzify index/int -> float:
    return outputs[index].defuzzify

  fuzzify -> none:
    for i:=0; i<crisp_inputs.size; i+= 1:
      inputs[i].fuzzify crisp_inputs[i]
    rules.do: it.evaluate

  is_fired index/int -> bool:  // TODO just fired?
    return rules[index].fired

  stringify -> string:
    in_str := ""
    inputs.do:
      in_str = in_str + it.stringify + "\n"
    out_str := ""
    outputs.do:
      out_str = out_str + it.stringify + "\n"            

    rule_str := ""
    rules.do:
      rule_str = rule_str + it.stringify + "\n"     
    return "Model: $name \n  Inputs:\n  $in_str  Outputs:\n  $out_str  Rules:\n$rule_str"