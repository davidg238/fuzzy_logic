// Copyright (c) 2021 Ekorau LLC

import .input_output show InputOutput

class FuzzyInput extends InputOutput:

    constructor an_index:
        super an_index

    calculate_set_pertinences -> none:
        fuzzy_sets_.do: it.calculate_pertinence crisp_in
