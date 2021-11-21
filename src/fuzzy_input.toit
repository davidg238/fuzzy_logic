// Copyright (c) 2021 Ekorau LLC

import .input_output show InputOutput

class FuzzyInput extends InputOutput:

    constructor index name="" :
        super index name

    calculate_set_pertinences -> none:
        fuzzy_sets_.do: it.calculate_pertinence crisp_in

    stringify -> string:
        in_str := "in: $name\n"
        fuzzy_sets_.do:
            in_str = in_str + "    " + it.stringify + "\n"
        return "$in_str"
