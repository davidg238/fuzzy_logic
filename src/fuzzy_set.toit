// Copyright (c) 2021 Ekorau LLC

import .geometry show *

y_rising p q r -> float:
  return (p-q)/(r-q)

y_falling p q r -> float:
  return 1.0 - (p-q)/(r-q)

abstract class FuzzySet:

  a_/float
  b_/float
  c_/float
  d_/float
  pertinence_/float := 0.0
  name := ""

  constructor.with_points a b c d .name="":            //new
    a_ = a.to_float
    b_ = b.to_float
    c_ = c.to_float
    d_ = d.to_float

  constructor a/num b/num c/num d/num aname="" :                      //new
    if a==b and b==c and c==d: return SingletonSet a b c d aname
    if a==b and b==c: return LraTriangularSet a b c d aname
    if b==c and c==d: return RraTriangularSet a b c d aname
    if b==c: return TriangularSet a b c d aname
    if a==b: return LTrapezoidalSet a b c d aname
    if c==d: return RTrapezoidalSet a b c d aname 
    return TrapezoidalSet a b c d aname

  clear -> none:
    pertinence_ = 0.0

  compare_to other/FuzzySet -> any:
    if a_ < other.a_: return -1
    if a_ > other.a_: return 1
    if a_==other.a_ and b_==other.b_ and c_==other.c_ and d_==other.d_: return 0
    if pertinence_ < other.pertinence_: return -1
    if pertinence_ > other.pertinence_: return 1
    return 0

  is_pertinent -> bool:
    return pertinence_ > 0.0

  pertinence -> float:
    return pertinence_

  fuzzify crisp_val/num -> none:
    pertinence_ = lookup_ crisp_val.to_float

  abstract lookup_ val/float -> float

  max val/float -> none:
    if pertinence_<val: 
      pertinence_ = val
    // print "set $name max: $pertinence_ $val"

  abstract truncated -> List

  truncator_l -> Point2f:  ///For now, set geometries x-values are defined between 0.0 - 100.0
    return Point2f 0.0 pertinence_
    
  truncator_r -> Point2f:
    return Point2f 100.0 pertinence_

  stype: return ""

  stringify: return "$name/$(stype):[$a_, $b_, $c_, $d_]/$(%.3f pertinence_)"


// Methods used by trial composition
  start -> int:
    return a_.to_int

  size -> int:
    return (d_-a_).to_int

// Test methods
  test_a -> float: return a_
  test_b -> float: return b_
  test_c -> float: return c_
  test_d -> float: return d_


class SingletonSet extends FuzzySet:

  constructor a aname="":
    super.with_points a a a a aname

  constructor a b c d name:
      super.with_points a b c d name

  stype: return "sing"

  lookup_ cVal/float -> float:
    return (a_-cVal).abs < F_error3 ? 1.0 : 0.0

  graph_points -> string:
    return "$(a_*4),0, $(a_*4),400"

  truncated -> List: //Answer the point geometry, truncated to the current pertinence
      return [(Point2f a_ 0.0), (Point2f a_ pertinence_)]

  truncated_polygon -> List: //Answer the point geometry, truncated to the current pertinence
      return [(Point2f a_ 0.0), (Point2f a_ pertinence_), (Point2f a_ 0.0)]

  size -> int:
    return 1
  
class LTrapezoidalSet extends FuzzySet:

  constructor a c d name:
      super.with_points a a c d name

  constructor a b c d name:
      super.with_points a b c d name

  stype: return "trap.l"

  lookup_ cVal/float -> float:
    if cVal <= c_:
      return 1.0
    else if cVal >= d_:
      return 0.0
    else:
      return y_falling cVal c_ d_

  graph_points -> string:
    return "0,0 0,400 $(c_*4),400, $(d_*4),0"

  truncated -> List: 
  /*
  Answer the point geometry, truncated to the current pertinence,
  adding a synthetic point at 0,0 to form a closed polygon, for calc purposes
  */
    return (1.0-pertinence).abs < F_error3?
      [ Point2f 0 0,
        Point2f 0.0 1.0, 
        Point2f c_ 1.0,
        Point2f d_ 0.0
      ] :
      [ Point2f 0 0
        Point2f 0.0 pertinence, 
        intersection truncator_l truncator_r (Point2f c_ 1.0) (Point2f d_ 0.0),
        Point2f d_ 0.0
      ]

  truncated_polygon -> List: 
  /*
  Answer the point geometry, truncated to the current pertinence,
  adding a synthetic point at 0,0 to form a closed polygon, for calc purposes
  */
    return (1.0-pertinence).abs < F_error3?
      [ Point2f 0 0,
        Point2f 0.0 1.0, 
        Point2f c_ 1.0,
        Point2f d_ 0.0,
        Point2f 0 0
      ] :
      [ Point2f 0 0
        Point2f 0.0 pertinence, 
        intersection truncator_l truncator_r (Point2f c_ 1.0) (Point2f d_ 0.0),
        Point2f d_ 0.0,
        Point2f 0 0
      ]      

class RTrapezoidalSet extends FuzzySet:

  constructor a b c name:
      super.with_points a b c c name

  constructor a b c d name:
    super.with_points a b c d name

  stype: return "trap.r"

  graph_points -> string:
    return "$(a_*4),0 $(b_*4),400 400,400, 400,0"

  lookup_ cVal/float -> float:
    if cVal <= a_:
      return 0.0
    else if cVal >= b_:
      return 1.0
    else:
      return y_rising cVal a_ b_

  truncated -> List:
  /*
  Answer the point geometry, truncated to the current pertinence,
  adding a synthetic point at 0,0 to form a closed polygon, for calc purposes
  */
    return (1.0-pertinence).abs < F_error3?
      [ Point2f a_ 0.0, 
        Point2f b_ 1.0,
        Point2f 100.0 1.0,  // geometries considered x range of 0-100 ? //todo
        Point2f 100.0 0.0
      ] :
      [ Point2f a_ 0.0, 
        intersection truncator_l truncator_r (Point2f a_ 0.0) (Point2f b_ 1.0),
        Point2f 100.0 pertinence,
        Point2f 100.0 0.0
      ]      

  truncated_polygon -> List:
  /*
  Answer the point geometry, truncated to the current pertinence,
  adding a synthetic point at 0,0 to form a closed polygon, for calc purposes
  */
    return (1.0-pertinence).abs < F_error3?
      [ Point2f a_ 0.0, 
        Point2f b_ 1.0,
        Point2f 100.0 1.0,  // geometries considered x range of 0-100 ? //todo
        Point2f 100.0 0.0,
        Point2f a_ 0.0
      ] :
      [ Point2f a_ 0.0, 
        intersection truncator_l truncator_r (Point2f a_ 0.0) (Point2f b_ 1.0),
        Point2f 100.0 pertinence,
        Point2f 100.0 0.0,
        Point2f a_ 0.0
      ]      


class TrapezoidalSet extends FuzzySet:

  constructor a b c d name:
      super.with_points a b c d name

  stype: return "trap"

  graph_points -> string:
    return "$(a_*4),0 $(b_*4),400 $(c_*4),400, $(d_*4),0"

  lookup_ cVal/float -> float:
    if (cVal<=a_) or (cVal>=d_):
      return 0.0
    else if (cVal>=b_) and (cVal<=c_):
      return 1.0
    else if cVal<b_:
      return y_rising cVal a_ b_
    else:
      return y_falling cVal c_ d_


  truncated -> List: //Answer the point geometry, truncated to the current pertinence
    return (1.0-pertinence).abs < F_error3?
      [ Point2f a_ 0.0, 
        Point2f b_ 1.0,
        Point2f c_ 1.0,    
        Point2f d_ 0.0
      ] :
      [ Point2f a_ 0.0, 
        intersection truncator_l truncator_r (Point2f a_ 0.0) (Point2f b_ 1.0),
        intersection truncator_l truncator_r (Point2f c_ 1.0) (Point2f d_ 0.0),    
        Point2f d_ 0.0
      ]

  truncated_polygon -> List: //Answer the point geometry, truncated to the current pertinence
    return (1.0-pertinence).abs < F_error3?
      [ Point2f a_ 0.0, 
        Point2f b_ 1.0,
        Point2f c_ 1.0,    
        Point2f d_ 0.0,
        Point2f a_ 0.0
      ] :
      [ Point2f a_ 0.0, 
        intersection truncator_l truncator_r (Point2f a_ 0.0) (Point2f b_ 1.0),
        intersection truncator_l truncator_r (Point2f c_ 1.0) (Point2f d_ 0.0),    
        Point2f d_ 0.0,
        Point2f a_ 0.0
      ]      

class LraTriangularSet extends FuzzySet:

  constructor a d name:
      super.with_points a a a d name

  constructor a b c d name:
    super.with_points a b c d name

  stype: return "tri.lra"

  graph_points -> string:
    return "$(a_*4),0 $(a_*4),400 $(d_*4),0"

  lookup_ cVal/float -> float:
    if cVal<=a_ or cVal>=d_: 
      return 0.0
    return y_falling cVal c_ d_

  truncated -> List: //Answer the point geometry, truncated to the current pertinence
    return (1.0-pertinence).abs < F_error3?
      [ Point2f a_ 0.0, 
        Point2f a_ 1.0,
        Point2f d_ 0.0
      ] :
      [ Point2f a_ 0.0, 
        intersection truncator_l truncator_r (Point2f a_ 0.0) (Point2f a_ 1.0),
        intersection truncator_l truncator_r (Point2f a_ 1.0) (Point2f d_ 0.0),
        Point2f d_ 0.0
      ]      

  truncated_polygon -> List: //Answer the point geometry, truncated to the current pertinence
    return (1.0-pertinence).abs < F_error3?
      [ Point2f a_ 0.0, 
        Point2f a_ 1.0,
        Point2f d_ 0.0,
        Point2f a_ 0.0
      ] :
      [ Point2f a_ 0.0, 
        intersection truncator_l truncator_r (Point2f a_ 0.0) (Point2f a_ 1.0),
        intersection truncator_l truncator_r (Point2f a_ 1.0) (Point2f d_ 0.0),
        Point2f d_ 0.0,
        Point2f a_ 0.0
      ]       

class RraTriangularSet extends FuzzySet:

  constructor a b c d name:
    super.with_points a b c d name

  constructor a d name:
      super.with_points a d d d name

  stype: return "tri.rra"

  graph_points -> string:
    return "$(a_*4),0 $(d_*4),400 $(d_*4),0"

  lookup_ cVal/float -> float:
    if cVal<=a_ or cVal>=d_: 
      return 0.0
    return y_rising cVal a_ b_


  truncated -> List: //Answer the point geometry, truncated to the current pertinence
    return (1.0-pertinence).abs < F_error3?
      [ Point2f a_ 0.0, 
        Point2f d_ 1.0,
        Point2f d_ 0.0
      ] :
      [ Point2f a_ 0.0, 
        intersection truncator_l truncator_r (Point2f a_ 0.0) (Point2f d_ 1.0),
        intersection truncator_l truncator_r (Point2f d_ 1.0) (Point2f d_ 0.0),
        Point2f d_ 0.0
      ]

  truncated_polygon -> List: //Answer the point geometry, truncated to the current pertinence
    return (1.0-pertinence).abs < F_error3?
      [ Point2f a_ 0.0, 
        Point2f d_ 1.0,
        Point2f d_ 0.0,
        Point2f a_ 0.0
      ] :
      [ Point2f a_ 0.0, 
        intersection truncator_l truncator_r (Point2f a_ 0.0) (Point2f d_ 1.0),
        intersection truncator_l truncator_r (Point2f d_ 1.0) (Point2f d_ 0.0),
        Point2f d_ 0.0,
        Point2f a_ 0.0
      ]

class TriangularSet extends FuzzySet:

  constructor a b d name:
    super.with_points a b b d name

  constructor a b c d name:
    super.with_points a b c d name

  stype: return "tri"

  graph_points -> string:
    return "$(a_*4),0 $(b_*4),400 $(d_*4),0"

  lookup_ cVal/float -> float:
    if (cVal<=a_) or (cVal>=d_):
      return 0.0
    else if cVal<b_:
      return y_rising cVal a_ b_
    else if cVal>b_:
      return y_falling cVal c_ d_
    else:
      return 1.0


  truncated -> List: //Answer the point geometry, truncated to the current pertinence
    return (1.0-pertinence).abs < F_error3?
      [ Point2f a_ 0.0, 
        Point2f b_ 1.0,
        Point2f d_ 0.0
      ] :
      [ Point2f a_ 0.0, 
        intersection truncator_l truncator_r (Point2f a_ 0.0) (Point2f b_ 1.0),
        intersection truncator_l truncator_r (Point2f b_ 1.0) (Point2f d_ 0.0),    
        Point2f d_ 0.0
      ]

  truncated_polygon -> List: //Answer the point geometry, truncated to the current pertinence
    return (1.0-pertinence).abs < F_error3?
      [ Point2f a_ 0.0, 
        Point2f b_ 1.0,
        Point2f d_ 0.0,
        Point2f a_ 0.0
      ] :
      [ Point2f a_ 0.0, 
        intersection truncator_l truncator_r (Point2f a_ 0.0) (Point2f b_ 1.0),
        intersection truncator_l truncator_r (Point2f b_ 1.0) (Point2f d_ 0.0),    
        Point2f d_ 0.0,
        Point2f a_ 0.0
      ]      

  /*
  set_pertinence crispVal/float -> none:  //new, eFLL returned true (only)

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
    else iif val < a_: return 0.0
    if val > d_: return 0.0
    if val < b_: return y_rising val a_ b_
    if val < c_: return 1.0
    if val < d_: return y_falling val c_ d_
    return 0.0f crispVal > c_ and crispVal <= d_:
      slope := 1.0 / (c_ - d_)
      pertinence_ = slope * (crispVal - c_) + 1.0
    // check the crispValue is bigger then D
    else if crispVal > d_:
      // check if this FuzzySet represents "everithing bigger is true"
      pertinence_ = c_==d_ and c_!=b_ and b_!=a_? 1.0 : 0.0
*/