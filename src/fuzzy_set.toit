// Copyright (c) 2021 Ekorau LLC

import .geometry show Point2f NoPoint intersection

abstract class FuzzySet:

  a_/num 
  b_/num
  c_/num
  d_/num
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

  pertinence_for crispVal/float -> none:  //new, eFLL returned true (only)

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

  a -> float: return a_.to_float
  b -> float: return b_.to_float
  c -> float: return c_.to_float
  d -> float: return d_.to_float

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

  truncator_l -> Point2f:  ///For now, set geometries x-values are defined between 0.0 - 100.0
    return Point2f 0.0 pertinence_
    
  truncator_r -> Point2f:
    return Point2f 100.0 pertinence_

  reset -> none:
    pertinence_ = 0.0

  stype: return ""

  stringify: return "$name/$(stype):[$a_, $b_, $c_, $d_]/$(%.3f pertinence_)"

class SingletonSet extends FuzzySet:

  constructor a aname="":
    super.with_points a a a a aname

  constructor a b c d name:
      super.with_points a b c d name

  stype: return "sing"

  graph_points -> string:
    return "$(a_*4),0, $(a_*4),400"

  truncated -> List: //Answer the point geometry, truncated to the current pertinence
      return [(Point2f a_ 0.0), (Point2f a_ pertinence_)]

class LTrapezoidalSet extends FuzzySet:

  constructor a c d name:
      super.with_points a a c d name

  constructor a b c d name:
      super.with_points a b c d name

  stype: return "trap.l"

  graph_points -> string:
    return "0,0 0,400 $(c_*4),400, $(d_*4),0"

  truncated -> List: //Answer the point geometry, truncated to the current pertinence
    return pertinence_== 1.0?
      [ Point2f 0.0 1.0, 
        Point2f c_ 1.0,
        Point2f d_ 0.0
      ] :
      [ Point2f 0.0 pertinence, 
        intersection (Point2f c_ 1.0) (Point2f d_ 0.0) truncator_l truncator_r,
        Point2f d_ 0.0
      ]

class RTrapezoidalSet extends FuzzySet:

  constructor a b c name:
      super.with_points a b c c name

  constructor a b c d name:
    super.with_points a b c d name

  stype: return "trap.r"

  graph_points -> string:
    return "$(a_*4),0 $(b_*4),400 400,400, 400,0"

  truncated -> List: //Answer the point geometry, truncated to the current pertinence
    return pertinence_== 1.0?
      [ Point2f a_ 0.0, 
        Point2f b_ 1.0,
        Point2f 100.0 1.0,  // geometries considered x range of 0-100 ? //todo
      ] :
      [ Point2f a_ 0.0, 
        intersection (Point2f a_ 0.0) (Point2f b_ 1.0) truncator_l truncator_r,
        Point2f 100.0 pertinence,
      ]      

class TrapezoidalSet extends FuzzySet:

  constructor a b c d name:
      super.with_points a b c d name

  stype: return "trap"

  graph_points -> string:
    return "$(a_*4),0 $(b_*4),400 $(c_*4),400, $(d_*4),0"

  truncated -> List: //Answer the point geometry, truncated to the current pertinence
    return pertinence_== 1.0?
      [ Point2f a_ 0.0, 
        Point2f b_ 1.0,
        Point2f c_ 1.0,    
        Point2f d_ 0.0
      ] :
      [ Point2f a_ 0.0, 
        intersection (Point2f a_ 0.0) (Point2f b_ 1.0) truncator_l truncator_r,
        intersection truncator_l truncator_r (Point2f c_ 1.0) (Point2f d_ 0.0),    
        Point2f d_ 0.0
      ]

class LraTriangularSet extends FuzzySet:

  constructor a d name:
      super.with_points a a a d name

  constructor a b c d name:
    super.with_points a b c d name

  stype: return "tri.lra"

  graph_points -> string:
    return "$(a_*4),0 $(a_*4),400 $(d_*4),0"

  truncated -> List: //Answer the point geometry, truncated to the current pertinence
    return pertinence_== 1.0?
      [ Point2f a_ 0.0, 
        Point2f a_ 1.0,
        Point2f d_ 0.0
      ] :
      [ Point2f a_ 0.0, 
        intersection (Point2f a_ 0.0) (Point2f a_ 1.0) truncator_l truncator_r,
        intersection (Point2f a_ 1.0) (Point2f d_ 0.0) truncator_l truncator_r,
        Point2f d_ 0.0
      ]      

class RraTriangularSet extends FuzzySet:

  constructor a b c d name:
    super.with_points a b c d name

  constructor a d name:
      super.with_points a d d d name

  stype: return "tri.rra"

  graph_points -> string:
    return "$(a_*4),0 $(d_*4),400 $(d_*4),0"

  truncated -> List: //Answer the point geometry, truncated to the current pertinence
    return pertinence_== 1.0?
      [ Point2f a_ 0.0, 
        Point2f d_ 1.0,
        Point2f d_ 0.0
      ] :
      [ Point2f a_ 0.0, 
        intersection (Point2f a_ 0.0) (Point2f d_ 1.0) truncator_l truncator_r,
        intersection (Point2f d_ 1.0) (Point2f d_ 0.0) truncator_l truncator_r,
        Point2f d_ 0.0
      ]

class TriangularSet extends FuzzySet:

  constructor a b d name:
    super.with_points a b b d name

  constructor a b c d name:
    super.with_points a b c d name

  stype: return "tri"

  graph_points -> string:
    return "$(a_*4),0 $(b_*4),400 $(d_*4),0"

  truncated -> List: //Answer the point geometry, truncated to the current pertinence
    return pertinence_== 1.0?
      [ Point2f a_ 0.0, 
        Point2f b_ 1.0,
        Point2f d_ 0.0
      ] :
      [ Point2f a_ 0.0, 
        intersection (Point2f a_ 0.0) (Point2f b_ 1.0) truncator_l truncator_r,
        intersection truncator_l truncator_r (Point2f b_ 1.0) (Point2f d_ 0.0),    
        Point2f d_ 0.0
      ]