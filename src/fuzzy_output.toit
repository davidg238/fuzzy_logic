// Copyright (c) 2021 Ekorau LLC

import .composition show Composition
import .input_output show InputOutput
import .geometry show Point2f NoPoint

seg idx/int list/List -> List:
    return [list[idx] list[idx + 1]]

class FuzzyOutput extends InputOutput:

    composition_ := Composition

    constructor index name="":
        super index name

    crisp_out -> float:
        return composition_.calculate_centroid

    composition -> Composition:
        return composition_

    order -> none:
        fuzzy_sets_.sort --in_place=true: | a b | a.compare_to b

    stringify -> string:
        out_str := "out: $name\n"
        fuzzy_sets_.do:
            out_str = out_str + "    " + it.stringify + "\n"
        return "$out_str"        

    truncate -> none:
        // print "truncate output $index_, which looks like: "
        // print "$this"
        sublist := List
        fuzzy_sets_.do:
            if it.is_pertinent: 
                // print "output $index_, add set: " + it.stringify + "\n"
                sublist.add it
        sublist.sort --in_place: | a b | (a.a_.compare_to b.a_)
        composition_.clear
        sublist.do: |set|
            composition_.union (set.truncated) /// truncate the set shape to the pertinence
        composition.simplify

