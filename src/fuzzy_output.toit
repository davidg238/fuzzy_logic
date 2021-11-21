// Copyright (c) 2021 Ekorau LLC

import .composition show Composition
import .input_output show InputOutput
import .fuzzy_point show FuzzyPoint NoPoint

seg idx/int list/List -> List:
    return [list[idx] list[idx + 1]]

class FuzzyOutput extends InputOutput:

    composition_ := Composition

    constructor index name="":
        super index name

    crisp_out -> float:
        return composition_.calculate

    composition -> Composition:
        return composition_

    order -> none:
        fuzzy_sets_.sort --in_place=true: | a b | a.a_.compare_to b.a_

    stringify -> string:
        out_str := "out: $name\n"
        fuzzy_sets_.do:
            out_str = out_str + "    " + it.stringify + "\n"
        return "$out_str"        

    truncate -> none:
        composition_.empty
        populate_composition
//        composition.build

    truncate_2 -> none:
        sublist := List
        fuzzy_sets_.do:
            if (it.is_pertinent): sublist.add it
        sublist.sort --in_place=true: | a b | (a.a_.compare_to b.a_)
        
        composition_.empty
        composition_.seed sublist[0]
        sublist[1..].do: |set|
            union_ composition_.segments set.segments

    union_ c_segs/List s_segs/List -> none:



    populate_composition -> none:  // split out temporarily for understanding
        print "populate the composition"
        fuzzy_sets_.do:
            print ".. using set $it"
            if it.pertinence > 0.0:
                if it.a != it.b:                        // test not a "trapeze" without its left triangle or singleton, before inc A
                    print ".... a != b"
                    composition_.add_point it.a 0.0
                if (it.b == it.c) and (it.a != it.d):   // test it is a triangle (B == C) and (A <> D)
                    print ".... (it.b == it.c) and (it.a != it.d)"
                    if it.pertinence == 1.0:  // test if the pertinence is the max
                        print "...... pertinence==1.0"
                        composition_.add_point it.b it.pertinence    // include it (it will replace previous point if left triangle)
                        composition_.add_point it.d 0.0             // include it (it will replace previous point if right triangle)
                    else: // if the pertinence is below the max, and it is a triangle, calculate the new point B and C
                        // rebuild the new point finding the intersection of two lines
                        //   the first is the segment from A to B (pertinence here is the y) 
                        //   and the segment of truncate, from A to D
                        // initiate a new point with current values of B (here it does matters, it always will be changed)
                        // only if a regular triangle
                        print "...... pertinence!=0.0)"
                        newB := intersection it.a 0.0 it.b 1.0 it.a it.pertinence it.d it.pertinence
                        if not (newB is NoPoint): 
                            print "...... intersects"
                            composition_.add_point newB
                        print "...... then 2nd intersection"
                        // rebuild the new point finding the intersection of two lines
                        //   the second is the segment from C to D (pertinence here is the y) 
                        //   and the segment of truncate, from A to D
                        // initiate a new point with current values of C (here it does matters, it always will be changed)
                        // only if a regular triangle
                        newC := intersection it.c 1.0 it.d 0.0 it.a it.pertinence it.d it.pertinence
                        print "...... yields $newC"
                        if not (newC is NoPoint):
                            print "...... intersects"
                            composition_.add_point newC
                // if until now, it was not a triangle
                // check if (B <> C), if true, it is a trapeze (this code is the same of the triangle, except when the pertinence is 1.0, here we include the two points [B and C], because they are not equal)
                else if (it.b != it.c):
                    print ".... (it.b != it.c)"
                    // check if the pertinence is the max
                    if (it.pertinence == 1.0):
                        print "...... it.pertinence==1.0"
                        composition_.add_point it.b it.pertinence
                        composition_.add_point it.c it.pertinence
                    // if the pertinence is below the max, and it is a triangle, calculate the new point B and C
                    else:
                        // initiate a new point with current values of B
                        // rebuild the new point finding the intersection of two lines, the first is the segment from A to B (pertinence here is the y) and the segment of truncate, from A to D
                        print "...... it.pertinence!=1.0"
                        newB := intersection it.a 0.0 it.b 1.0 it.a it.pertinence it.d it.pertinence
                        if not (newB is NoPoint):
                            print "...... intersects"
                            composition_.add_point newB
                        newC := intersection it.c 1.0 it.d 0.0 it.a it.pertinence it.d it.pertinence
                        if not (newC is NoPoint):
                            print "...... intersects" 
                            composition_.add_point newC
                // if it is not a triangle non a trapeze, it is a singleton
                else:
                    print ".... if it is not a triangle non a trapeze, it is a singleton"
                    composition_.add_point it.b 0.0
                    composition_.add_point it.b it.pertinence
                    composition_.add_point it.b 0.0
                // Check if it is not a "trapeze" without its right triangle or singleton, before include the point D
                if (it.c != it.d):
                    print ".... if it is not a trapeze without its right triangle or singleton, before include the point D"
                    composition.add_point it.d 0.0    


