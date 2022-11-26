// Copyright (c) 2021 Ekorau LLC

import .fuzzy_in_out show *
import .fuzzy_rule
import encoding.json

class FuzzyModel:

  inputs  := []
  input_names := []
  outputs := []
  rules   := []
  name := ""

  constructor .name="":                   //a name is optional

  add_input input/FuzzyInput -> none:
    inputs.add input
    input_names.add input.name

  add_output output/FuzzyOutput -> none:
    outputs.add output

  add_rule rule/FuzzyRule -> none:
    rules.add rule

  defuzzify index/int -> float:
    return outputs[index].crisp_out

  handle_msg msg/string -> none:
    cmd := json.parse msg
    idx := input_names.index_of cmd.keys.first
    set_input idx (cmd.values.first.to_float)

  init -> none:
    inputs.do: it.init

  fuzzify -> none:
    // print "in model.fuzzify ..."
    inputs.do: it.reset_sets
    outputs.do: it.reset_sets

    inputs.do: it.calculate_set_pertinences
    /*
    in_str := ""
    inputs.do:
        in_str = in_str + it.stringify + "\n"
    print in_str
    */
    // print "... evaluate rules"
    rules.do: it.evaluate
    // print "... truncate outputs"
    outputs.do: it.truncate
    print "... defuzzify done!"

  is_fired index/int -> bool:
    return rules[index].fired

  set_input index/int crisp_value/float -> none:
    inputs[index].crisp_in = crisp_value

  set_inputs list/List -> none:
    for i:=0; i<list.size; i+= 1:
      set_input i list[i]

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