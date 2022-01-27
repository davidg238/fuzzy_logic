// Copyright (c) 2021 Ekorau LLC

import .set_singleton show SingletonSet

import .set_triangular show TriangularSet
import .set_triangular_lra show LraTriangularSet
import .set_triangular_rra show RraTriangularSet

import .set_trapezoidal show TrapezoidalSet
import .set_trapezoidal_l show LTrapezoidalSet
import .set_trapezoidal_r show RTrapezoidalSet

import .geometry show Point2f NoPoint intersection

abstract class FuzzySet:

  a_/float 
  b_/float
  c_/float
  d_/float
  pertinence_/float := 0.0
  name := ""

  constructor.with_points .a_ .b_ .c_ .d_ .name="":            //new

  constructor a b c d aname="" :                      //new
    if a==b and b==c and c==d: return SingletonSet a b c d aname
    if a==b and b==c: return LraTriangularSet a b c d aname
    if b==c and c==d: return RraTriangularSet a b c d aname
    if b==c: return TriangularSet a b c d aname
    if a==b: return LTrapezoidalSet a b c d aname
    if c==d: return RTrapezoidalSet a b c d aname 
    return TrapezoidalSet a b c d aname

  calculate_pertinence crispVal/float -> none:  //new, eFLL returned true (only)

    // check if this FuzzySet represents "everything small is true"
    if crispVal < a_:
      pertinence_ = (a_==b_) and (b_!=c_) and (c_!=d_)? 1.0 : 0.0
    // check if the crispValue is between A and B
    else if crispVal >= a_ and crispVal < b:
      slope := 1.0 / (b_-a_)
      pertinence_ = slope * (crispVal - b_) + 1.0
    // check if the pertinence is between B and C
    else if crispVal >= b_ and crispVal <= c_:
      pertinence_ = 1.0;
    // check if the pertinence is between C and D
    else if crispVal > c_ and crispVal <= d_:
      slope := 1.0 / (c_ - d_)
      pertinence_ = slope * (crispVal - c_) + 1.0
    // check the crispValue is bigger then D
    else if crispVal > d_:
      // check if this FuzzySet represents "everithing bigger is true"
      pertinence_ = c_==d_ and c_!=b_ and b_!=a_? 1.0 : 0.0

  a -> float: return a_
  b -> float: return b_
  c -> float: return c_
  d -> float: return d_

  compare_to other/FuzzySet -> any:
    if a_ < other.a_: return -1
    if a_ > other.a_: return 1
    if a_==other.a and b_==other.b_ and c_==other.c_ and d_==other.d: return 0
    return pertinence_<other.pertinence_? -1: 1

  is_pertinent -> bool:
    return pertinence_ > 0.0

  pertinence -> float:
    return pertinence_
  
  pertinence val/float -> none:
    if pertinence_<val: pertinence_ = val

  abstract truncated

  truncator_a -> Point2f:  ///For now, set geometries x-values are defined between 0.0 - 100.0
    return Point2f 0.0 pertinence_
    
  truncator_b -> Point2f:
    return Point2f 100.0 pertinence_

  reset -> none:
    pertinence_ = 0.0

  stype: return ""

  stringify: return "$name/$(stype):[$a_, $b_, $c_, $d_]/$(%.3f pertinence_)"
