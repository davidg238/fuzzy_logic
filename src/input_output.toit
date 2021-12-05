// Copyright (c) 2021 Ekorau LLC

class InputOutput:

    crisp_in := 0.0
    index_/int := 0
    fuzzy_sets_/List := []
    name/string

    constructor .index_ .name="":

    add_set a_set -> none:
        fuzzy_sets_.add a_set

    add_all_sets sets/List-> none:
        fuzzy_sets_.add_all sets

    index -> int:
        return index_

    reset_sets -> none:
        fuzzy_sets_.do: it.reset
