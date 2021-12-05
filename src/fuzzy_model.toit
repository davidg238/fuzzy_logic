// Copyright (c) 2021 Ekorau LLC

import .fuzzy_input show FuzzyInput
import .fuzzy_output show FuzzyOutput
import .fuzzy_rule

class FuzzyModel:

    inputs_  := []
    outputs_ := []
    rules_   := []
    name := ""

    constructor .name="":                   //a name is optional

    add_input input/FuzzyInput -> none:
        inputs_.add input

    add_output output/FuzzyOutput -> none:
        outputs_.add output

    add_rule rule/FuzzyRule -> none:
        rules_.add rule

    defuzzify index/int -> float:
        return outputs_[index].crisp_out

    fuzzify -> none:
        print "in fuzzify ..."
        inputs_.do: it.reset_sets
        outputs_.do: it.reset_sets

        inputs_.do: it.calculate_set_pertinences
        in_str := ""
        inputs_.do:
            in_str = in_str + it.stringify + "\n"
        print in_str
        rules_.do: it.evaluate
        outputs_.do: it.truncate

    is_fired index/int -> bool:
        return rules_[index].fired

    set_input index/int crisp_value/float -> none:
        inputs_[index].crisp_in = crisp_value

    stringify -> string:

        in_str := ""
        inputs_.do:
            in_str = in_str + it.stringify + "\n"
        out_str := ""
        outputs_.do:
            out_str = out_str + it.stringify + "\n"            

        rule_str := ""
        rules_.do:
            rule_str = rule_str + it.stringify + "\n"     
        return "Model: $name \n  Inputs:\n  $in_str  Outputs:\n  $out_str  Rules:\n$rule_str"