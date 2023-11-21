// Copyright (c) 2021 Ekorau LLC
import .fuzzy-rule show RuleTerm
import .geometry show *

y-rising p q r -> float:
  return (p - q)/(r - q)

y-falling p q r -> float:
  return 1.0 - (p - q)/(r - q)

abstract class FuzzySet implements RuleTerm:

  a_/float
  b_/float
  c_/float
  d_/float
  
  pertinence_/float := 0.0
  name := ""
  area_ /float? := 0.0
  pts_ /List? := []

  constructor.with-points a b c d .name="":            //new
    a_ = a.to-float
    b_ = b.to-float
    c_ = c.to-float
    d_ = d.to-float

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
    clear-geometry-cache

  clear-geometry-cache -> none:
    area_ = null
    pts_ = null

  compare-to other/FuzzySet -> any:
    if a_ < other.a_: return -1
    if a_ > other.a_: return 1
    if a_==other.a_ and b_==other.b_ and c_==other.c_ and d_==other.d_: return 0
    if pertinence_ < other.pertinence_: return -1
    if pertinence_ > other.pertinence_: return 1
    return 0

  is-pertinent -> bool:
    return pertinence_ > 0.0

  pertinence -> float:
    return pertinence_

  term-eval -> float:
    return pertinence_

  fuzzify crisp-val/num -> none:
    pertinence_ = lookup_ crisp-val.to-float
    clear-geometry-cache

  abstract lookup_ val/float -> float

  max val/float -> none:
    if pertinence_<val: 
      pertinence_ = val
      clear-geometry-cache
    // print "set $name max: $pertinence_ $val"

/*
Answer the point geometry, as a polyline (not closed)
*/
  abstract polyline -> List

  truncate -> none:
    clear-geometry-cache
    pts_ = truncated-polygon
/*
Answer the point geometry, truncated to the current pertinence, as a closed polygon.
The geometry must be closed for the Composition centroid algorithm to work.
*/
  abstract truncated-polygon -> List

  truncator-l -> Point2f:  /// Since geometries are defined left to right
    return Point2f a_ pertinence_
    
  truncator-r -> Point2f:
    return Point2f d_ pertinence_

  stype: return ""

  stringify: return "$name/$(stype):[$a_, $b_, $c_, $d_]/$(%.3f pertinence_)"

/// ----- Geometry methods ----------------------------------------------------

  centroid-x_ -> float:
  // https://en.wikipedia.org/wiki/Centroid#Of_a_polygon
    cx := 0.0
    for i:=0;i<pts_.size - 1;i++:
      cx += (pts_[i].x + pts_[i+1].x)*(pts_[i].x * pts_[i+1].y - pts_[i+1].x * pts_[i].y)
    cx = cx/(6*truncated-area)
    return cx

  truncated-weighted-centroid -> float:
    return truncated-area * centroid-x_

  truncated-area -> float:
    if area_ != null: return area_
    area_ = 0.0
    for i:=0;i<pts_.size - 1;i++:
      area_ += (pts_[i].x * pts_[i+1].y) - (pts_[i+1].x * pts_[i].y)
    area_ = area_/2.0  
    return area_

// Test methods
  test-a -> float: return a_
  test-b -> float: return b_
  test-c -> float: return c_
  test-d -> float: return d_


class SingletonSet extends FuzzySet:

  constructor a aname="":
    super.with-points a a a a aname

  constructor a b c d name:
      super.with-points a b c d name

  stype: return "sing"

  lookup_ cVal/float -> float:
    return (a_ - cVal).abs < F-error3 ? 1.0 : 0.0

  graph-points -> string:
    return "$(a_*4),0, $(a_*4),400"

  polyline -> List: 
      return [(Point2f a_ 0.0), (Point2f a_ 1)]

  truncated-polygon -> List: 
      return [(Point2f a_ 0.0), (Point2f a_ pertinence_), (Point2f a_ 0.0)]


  truncated-weighted-centroid -> float:
    return a_

  truncated-area -> float:
    return 0.0
  
class LTrapezoidalSet extends FuzzySet:

  constructor a c d name:
      super.with-points a a c d name

  constructor a b c d name:
      super.with-points a b c d name

  stype: return "trap.l"

  lookup_ cVal/float -> float:
    if cVal <= c_:
      return 1.0
    else if cVal >= d_:
      return 0.0
    else:
      return y-falling cVal c_ d_

  graph-points -> string:
    return "0,0 0,400 $(c_*4),400, $(d_*4),0"

  polyline -> List: 
    return
      [ Point2f 0 0,
        Point2f 0.0 1.0, 
        Point2f c_ 1.0,
        Point2f d_ 0.0
      ]

  truncated-polygon -> List: 
    return (1.0 - pertinence).abs < F-error3?
      [ Point2f 0 0,
        Point2f 0.0 1.0, 
        Point2f c_ 1.0,
        Point2f d_ 0.0,
        Point2f 0 0
      ] :
      [ Point2f 0 0
        Point2f 0.0 pertinence, 
        intersection truncator-l truncator-r (Point2f c_ 1.0) (Point2f d_ 0.0),
        Point2f d_ 0.0,
        Point2f 0 0
      ]      

class RTrapezoidalSet extends FuzzySet:

  constructor a b c name:
      super.with-points a b c c name

  constructor a b c d name:
    super.with-points a b c d name

  stype: return "trap.r"

  graph-points -> string:
    return "$(a_*4),0 $(b_*4),400 400,400, 400,0"

  lookup_ cVal/float -> float:
    if cVal <= a_:
      return 0.0
    else if cVal >= b_:
      return 1.0
    else:
      return y-rising cVal a_ b_

  polyline -> List:
    return
      [ Point2f a_ 0.0, 
        Point2f b_ 1.0,
        Point2f 100.0 1.0,  // geometries considered x range of 0-100 ? //todo
        Point2f 100.0 0.0
      ]     

  truncated-polygon -> List:
    return (1.0 - pertinence).abs < F-error3?
      [ Point2f a_ 0.0, 
        Point2f b_ 1.0,
        Point2f 100.0 1.0,  // geometries considered x range of 0-100 ? //todo
        Point2f 100.0 0.0,
        Point2f a_ 0.0
      ] :
      [ Point2f a_ 0.0, 
        intersection truncator-l truncator-r (Point2f a_ 0.0) (Point2f b_ 1.0),
        Point2f 100.0 pertinence,
        Point2f 100.0 0.0,
        Point2f a_ 0.0
      ]      


class TrapezoidalSet extends FuzzySet:

  constructor a b c d name:
      super.with-points a b c d name

  stype: return "trap"

  graph-points -> string:
    return "$(a_*4),0 $(b_*4),400 $(c_*4),400, $(d_*4),0"

  lookup_ cVal/float -> float:
    if (cVal<=a_) or (cVal>=d_):
      return 0.0
    else if (cVal>=b_) and (cVal<=c_):
      return 1.0
    else if cVal<b_:
      return y-rising cVal a_ b_
    else:
      return y-falling cVal c_ d_


  polyline -> List: 
    return 
      [ Point2f a_ 0.0, 
        Point2f b_ 1.0,
        Point2f c_ 1.0,    
        Point2f d_ 0.0
      ] 

  truncated-polygon -> List: 
    return (1.0 - pertinence).abs < F-error3?
      [ Point2f a_ 0.0, 
        Point2f b_ 1.0,
        Point2f c_ 1.0,    
        Point2f d_ 0.0,
        Point2f a_ 0.0
      ] :
      [ Point2f a_ 0.0, 
        intersection truncator-l truncator-r (Point2f a_ 0.0) (Point2f b_ 1.0),
        intersection truncator-l truncator-r (Point2f c_ 1.0) (Point2f d_ 0.0),    
        Point2f d_ 0.0,
        Point2f a_ 0.0
      ]      

class LraTriangularSet extends FuzzySet:

  constructor a d name:
      super.with-points a a a d name

  constructor a b c d name:
    super.with-points a b c d name

  stype: return "tri.lra"

  graph-points -> string:
    return "$(a_*4),0 $(a_*4),400 $(d_*4),0"

  lookup_ cVal/float -> float:
    if cVal<=a_ or cVal>=d_: 
      return 0.0
    return y-falling cVal c_ d_

  polyline -> List: 
    return 
      [ Point2f a_ 0.0, 
        Point2f a_ 1.0,
        Point2f d_ 0.0
      ]      

  truncated-polygon -> List: //Answer the point geometry, truncated to the current pertinence
    return (1.0 - pertinence).abs < F-error3?
      [ Point2f a_ 0.0, 
        Point2f a_ 1.0,
        Point2f d_ 0.0,
        Point2f a_ 0.0
      ] :
      [ Point2f a_ 0.0, 
        intersection truncator-l truncator-r (Point2f a_ 0.0) (Point2f a_ 1.0),
        intersection truncator-l truncator-r (Point2f a_ 1.0) (Point2f d_ 0.0),
        Point2f d_ 0.0,
        Point2f a_ 0.0
      ]       

class RraTriangularSet extends FuzzySet:

  constructor a b c d name:
    super.with-points a b c d name

  constructor a d name:
      super.with-points a d d d name

  stype: return "tri.rra"

  graph-points -> string:
    return "$(a_*4),0 $(d_*4),400 $(d_*4),0"

  lookup_ cVal/float -> float:
    if cVal<=a_ or cVal>=d_: 
      return 0.0
    return y-rising cVal a_ b_

  polyline -> List: 
    return 
      [ Point2f a_ 0.0, 
        Point2f d_ 1.0,
        Point2f d_ 0.0
      ] 

  truncated-polygon -> List: 
    return (1.0 - pertinence).abs < F-error3?
      [ Point2f a_ 0.0, 
        Point2f d_ 1.0,
        Point2f d_ 0.0,
        Point2f a_ 0.0
      ] :
      [ Point2f a_ 0.0, 
        intersection truncator-l truncator-r (Point2f a_ 0.0) (Point2f d_ 1.0),
        intersection truncator-l truncator-r (Point2f d_ 1.0) (Point2f d_ 0.0),
        Point2f d_ 0.0,
        Point2f a_ 0.0
      ]

class TriangularSet extends FuzzySet:

  constructor a b d name:
    super.with-points a b b d name

  constructor a b c d name:
    super.with-points a b c d name

  stype: return "tri"

  graph-points -> string:
    return "$(a_*4),0 $(b_*4),400 $(d_*4),0"

  lookup_ cVal/float -> float:
    if (cVal<=a_) or (cVal>=d_):
      return 0.0
    else if cVal<b_:
      return y-rising cVal a_ b_
    else if cVal>b_:
      return y-falling cVal c_ d_
    else:
      return 1.0


  polyline -> List: 
    return 
      [ Point2f a_ 0.0, 
        Point2f b_ 1.0,
        Point2f d_ 0.0
      ] 

  truncated-polygon -> List: 
    return (1.0 - pertinence).abs < F-error3?
      [ Point2f a_ 0.0, 
        Point2f b_ 1.0,
        Point2f d_ 0.0,
        Point2f a_ 0.0
      ] :
      [ Point2f a_ 0.0, 
        intersection truncator-l truncator-r (Point2f a_ 0.0) (Point2f b_ 1.0),
        intersection truncator-l truncator-r (Point2f b_ 1.0) (Point2f d_ 0.0),    
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