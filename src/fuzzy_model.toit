// Copyright (c) 2021 Ekorau LLC

import .fuzzy_input show FuzzyInput
import .fuzzy_output show FuzzyOutput
import .fuzzy_rule

class FuzzyModel:

    inputs_  := []
    outputs_ := []
    rules_   := []

    add_input input/FuzzyInput -> none:
        inputs_.add input

    add_output output/FuzzyOutput -> none:
        outputs_.add output

    add_rule rule/FuzzyRule -> none:
        rules_.add rule

    defuzzify index/int -> float:
        return outputs_[index].crisp_out

    fuzzify -> none:
        inputs_.do: it.reset_sets
        outputs_.do: it.reset_sets

        inputs_.do: it.calculate_set_pertinences
        rules_.do: it.evaluate
        outputs_.do: it.truncate

    is_fired index/int -> bool:
        return rules_[index].fired

    set_input index/int crisp_value/float -> none:
        inputs_[index].crisp_in = crisp_value



