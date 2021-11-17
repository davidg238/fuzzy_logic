// Copyright (c) 2021 Ekorau LLC

import .composition show Composition
import .input_output show InputOutput
import .fuzzy_point show FuzzyPoint NoPoint

class FuzzyOutput extends InputOutput:

    composition_ := Composition

    constructor an_index:
        super an_index

    crisp_out -> float:
        return composition_.calculate

    composition -> Composition:
        return composition_

    order -> none:
        fuzzy_sets_.sort --in_place=true: | a b | a.a_.compare_to b.a_

    truncate -> none:
        composition_.empty
        fuzzy_sets_.do:
            if it.pertinence > 0.0:
                if it.a != it.b:                        // test not a "trapeze" without its left triangle or singleton, before inc A
                    composition_.add_point it.a 0.0
                if (it.b == it.c) and (it.a != it.d):   // test it is a triangle (B == C) and (A <> D)
                    if it.pertinence == 1.0:  // test if the pertinence is the max
                        composition_.add_point it.b it.pertinence    // include it (it will replace previous point if left triangle)
                        composition_.add_point it.d 0.0             // include it (it will replace previous point if right triangle)
                    else: // if the pertinence is below the max, and it is a triangle, calculate the new point B and C
                        // rebuild the new point finding the intersection of two lines
                        //   the first is the segment from A to B (pertinence here is the y) 
                        //   and the segment of truncate, from A to D
                        // initiate a new point with current values of B (here it does matters, it always will be changed)
                        // only if a regular triangle
                        newB := intersection it.a 0.0 it.b 1.0 it.a it.pertinence it.d it.pertinence
                        if not (newB is NoPoint): composition_.add_point newB
                        // rebuild the new point finding the intersection of two lines
                        //   the second is the segment from C to D (pertinence here is the y) 
                        //   and the segment of truncate, from A to D
                        // initiate a new point with current values of C (here it does matters, it always will be changed)
                        // only if a regular triangle
                        newC := intersection it.c 1.0 it.d 0.0 it.a it.pertinence it.d it.pertinence
                        if not (newC is NoPoint): composition_.add_point newC
                // if until now, it was not a triangle
                // check if (B <> C), if true, it is a trapeze (this code is the same of the triangle, except when the pertinence is 1.0, here we include the two points [B and C], because they are not equal)
                else if (it.b != it.c):
                    // check if the pertinence is the max
                    if (it.pertinence == 1.0):
                        composition_.add_point it.b it.pertinence
                        composition_.add_point it.c it.pertinence
                    // if the pertinence is below the max, and it is a triangle, calculate the new point B and C
                    else:
                        // initiate a new point with current values of B
                        // rebuild the new point finding the intersection of two lines, the first is the segment from A to B (pertinence here is the y) and the segment of truncate, from A to D
                        newB := intersection it.a 0.0 it.b 1.0 it.a it.pertinence it.d it.pertinence
                        if not (newB is NoPoint): composition_.add_point newB
                        newC := intersection it.c 1.0 it.d 0.0 it.a it.pertinence it.d it.pertinence
                        if not (newC is NoPoint): composition_.add_point newC
                // if it is not a triangle non a trapeze, it is a singleton
                else:
                    composition_.add_point it.b 0.0
                    composition_.add_point it.b it.pertinence
                    composition_.add_point it.b 0.0
                // Check if it is not a "trapeze" without its right triangle or singleton, before include the point D
                if (it.c != it.d):
                    composition.add_point it.d 0.0
        composition.build


    // Method to rebuild some point, the new point is calculated finding the intersection between two lines
    intersection x1/float y1/float x2/float y2/float x3/float y3/float x4/float y4/float -> FuzzyPoint:

        // calculate the denominator and numerator
        denom  := (y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1)
        numera := (x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3)
        numerb := (x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3)
        
        if denom < 0.0:             // if negative, convert to positive
            denom = denom * -1.0
        // If the denominator is zero or close to it, it means that the lines are parallels, so return false for intersection
        //EPSILON_VALUE = 0.001
        if denom < 0.001: return NoPoint
        if (numera < 0.0):          // if negative, convert to positive
            numera = numera * -1.0
        if (numerb < 0.0):          // if negative, convert to positive
            numerb = numerb * -1.0
        // verify if has intersection between the segments
        mua := numera / denom
        mub := numerb / denom
        if (mua < 0.0) or (mua > 1.0) or (mub < 0.0) or (mub > 1.0):
            return NoPoint
        else:
            return FuzzyPoint (x1 + mua * (x2 - x1)) (y1 + mua * (y2 - y1))
