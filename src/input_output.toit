// Copyright (c) 2021 Ekorau LLC

class InputOutput:

    crisp_in := 0.0
    index_/int := 0
    fuzzy_sets_/List := []

    constructor an_index:
        index_ = an_index

    add_set a_set -> none:
        fuzzy_sets_.add a_set

    index -> int:
        return index_

    reset_sets -> none:
        fuzzy_sets_.do: it.reset
