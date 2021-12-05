// Copyright (c) 2021 Ekorau LLC

import .set_singleton show SingletonSet

import .set_triangular show TriangularSet
import .set_triangular_lra show LraTriangularSet
import .set_triangular_rra show RraTriangularSet

import .set_trapezoidal show TrapezoidalSet
import .set_trapezoidal_l show LTrapezoidalSet
import .set_trapezoidal_r show RTrapezoidalSet

import .geometry show Point2f NoPoint intersection

/*
    // Method to rebuild some point, the new point is calculated finding the intersection between two lines
intersection x1/float y1/float x2/float y2/float x3/float y3/float x4/float y4/float -> Point2f:

    print "find intersection $x1,$y1 - $x2,$y2 and $x3,$y3 - $x4,$y4"
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
        return Point2f (x1 + mua * (x2 - x1)) (y1 + mua * (y2 - y1))
*/

abstract class FuzzySet:

    a_/float 
    b_/float
    c_/float
    d_/float
    pertinence_/float := 0.0
    name := ""

    constructor.with_points .a_ .b_ .c_ .d_ .name="":                        //new

    constructor a b c d aname="" :                                            //new
        if (a==b and b==c and c==d): return SingletonSet a b c d aname
        if (a==b) and (b==c): return LraTriangularSet a b c d aname
        if (b==c) and (c==d): return RraTriangularSet a b c d aname
        if (b==c): return TriangularSet a b c d aname
        if (a==b): return LTrapezoidalSet a b c d aname
        if (c==d): return RTrapezoidalSet a b c d aname 
        return TrapezoidalSet a b c d aname

    calculate_pertinence crispVal/float -> none:  //new, eFLL returned true (only)

        // check if this FuzzySet represents "everything small is true"
        if (crispVal < a_):
            pertinence_ = (a_==b_) and (b_!=c_) and (c_!=d_)? 1.0 : 0.0
        // check if the crispValue is between A and B
        else if (crispVal >= a_) and (crispVal < b_):
            slope := 1.0 / (b_-a_)
            pertinence_ = slope * (crispVal - b_) + 1.0
        // check if the pertinence is between B and C
        else if (crispVal >= b_) and (crispVal <= c_):
            pertinence_ = 1.0;
        // check if the pertinence is between C and D
        else if (crispVal > c_) and (crispVal <= d_):
            slope := 1.0 / (c_ - d_)
            pertinence_ = slope * (crispVal - c_) + 1.0
        // check the crispValue is bigger then D
        else if (crispVal > d_):
            // check if this FuzzySet represents "everithing bigger is true"
            pertinence_ = (c_ == d_) and (c_ != b_) and (b_ != a_)? 1.0 : 0.0

    a -> float: return a_
    b -> float: return b_
    c -> float: return c_
    d -> float: return d_

    compare_to other/FuzzySet -> any:
        if (a_ < other.a_): return -1
        if (a_ > other.a_): return 1
        if ((a_== other.a) and (b_==other.b_) and (c_==other.c_) and (d_==other.d)): return 0
        return (pertinence_ < other.pertinence_)? -1: 1

    is_pertinent -> bool:
        return pertinence_ > 0.0

    pertinence -> float:
        return pertinence_
    
    pertinence val/float -> none:
        if (pertinence_ < val): pertinence_ = val

    abstract truncated

    truncator_a -> Point2f:  ///For now, set geometries x-values are defined between 0.0 - 100.0
        return Point2f 0.0 pertinence_
        
    truncator_b -> Point2f:
        return Point2f 100.0 pertinence_

    reset -> none:
        pertinence_ = 0.0

    stype: return ""

    stringify: return "$name/$(stype):[$a_, $b_, $c_, $d_]/$(%.3f pertinence_)"
