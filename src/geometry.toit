// Copyright (c) 2021 Ekorau LLC

import math show *

RIGHT ::=  1
ON    ::=  0
LEFT  ::= -1
F-error3 ::= 0.0009  // TODO floating point error
F-error6 ::= 0.0000009  // TODO floating point error

intersection p0/Point2f p1/Point2f p2/Point2f p3/Point2f -> Point2f:
// https://stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect

  // print "intersection $p0,$p1 + $p2,$p3"

  s1 := Point2f (p1.x - p0.x) (p1.y - p0.y)
  s2 := Point2f (p3.x - p2.x) (p3.y - p2.y)
  denom := (-s2.x * s1.y + s1.x * s2.y)

  if denom.abs < F-error3: return NoPoint2f  // not general, but good enough for geometries here?

  s := (-s1.y * (p0.x - p2.x) + s1.x * (p0.y - p2.y)) / denom;
  t := ( s2.x * (p0.y - p2.y) - s2.y * (p0.x - p2.x)) / denom;

  return (s >= 0 and s <= 1 and t >= 0 and t <= 1)? 
    Point2f (p0.x + (t * s1.x)) (p0.y + (t * s1.y)): 
    NoPoint2f

convex-hull points/List -> List:
    /// https://en.wikipedia.org/wiki/Graham_scan
    /// 
    stack := Stack
    p0 := leftmost-lowest points
    temp := polar-sort points p0
    temp.do:
        // pop the last point from the stack if we turn clockwise to reach this point
        while stack.size > 1 and (it.counter-clockwise stack.next-to-top stack.top ) <= 0:
            stack.pop
        stack.push it
    return stack.to-list

upper-convex-hull points/List -> List:
    /// https://en.wikibooks.org/wiki/Algorithm_Implementation/Geometry/Convex_hull/Monotone_chain

    if points.size < 3:
        throw "unknown geometry"
    val := null // only used debug prints
    temp := xy-sort points
    stack := Stack
    temp.do --reversed:
        while stack.size > 1 and (it.counter-clockwise stack.next-to-top stack.top) <= 0:
            val = stack.pop
        stack.push it
    return stack.to-list

/* 
Answers true if the point is before, after or above the polyline.
Points in the polyline are assumed to be ordered.
*/
is-point point/Point2f --above polyline/List -> bool:
  // print "is_point $point $polyline"
  if point.x < polyline.first.x or point.x > polyline.last.x:
    return true
  for i:=0; i < polyline.size - 1; i++:
    if point.x >= polyline[i].x and point.x <= polyline[i+1].x:
      return point.is-above --p1=polyline[i] --p2=polyline[i+1]
  throw "unknown geometry"

    

xy-sort points/List -> List:
    return points.sort: | a b |
        i := a.x.compare-to b.x
        (i != 0)? i : a.y.compare-to b.y
      
polar-sort points/List p0/Point2f -> List:
    return points.sort: | a b | (p0.polar-angle a).compare-to (p0.polar-angle b)

leftmost-lowest points/List -> Point2f:
    p0 := points.first // assumes a non-empty list
    points.do:
        if it.x<=p0.x and it.y<=p0.y: p0 = it
    return p0


class Point2f extends Point3f:

  constructor x/num y/num z=0.0:
    super x y z

  compare-to other/Point2f -> num:
    if this.x < other.x:
      return -1
    else if this.x > other.x:
      return 1
    else if this.y < other.y:
      return -1
    else if this.y > other.y:
      return 1
    else:
      return 0
    
  counter-clockwise a/Point2f b/Point2f -> int:
    // Subtract co-ordinates of point A from B and P, to make A as origin
    b_ := b - a
    p_ := this - a
    
    cross-product := b_.x * p_.y - b_.y * p_.x;
    if cross-product > 0:
        return RIGHT
    if cross-product < 0:
        return LEFT
    return ON    

  inside polygon/List -> bool:
    angle := 0.0
    polygon.do: [angle += polar-angle it]
    return angle.abs > PI // angle is 2PI if inside, 0 if outside: test with fp error tolerance

  is-above --p1/Point2f --p2/Point2f -> bool:
    // https://stackoverflow.com/questions/1560492/how-to-tell-whether-a-point-is-to-the-right-or-left-side-of-a-line
    return ((p2.x - p1.x) * (this.y - p1.y)) - ((p2.y - p1.y) * (this.x - p1.x)) > 0

  polar-angle b/Point2f -> float:
    return atan ((b.y - y)/(b.x - x))

  stringify: return "$(%.2f x),$(%.2f y)"
    

class NoPoint2f extends Point2f:
  constructor:
      super float.NAN float.NAN float.NAN

class Stack extends Deque:

  push element -> none:
    add element

  pop -> any:
    return remove-last

  reversed -> List:
    list := []
    this.do --reversed=true:
        list.add it
    return list

  to-list -> List:
    list := []
    this.do: list.add it
    return list

  top -> any:
    return last

  next-to-top -> any:
    return backing_[size - 2]

  is-empty -> bool:
    return this.is-empty

/*
intersection a1/Point2f a2/Point2f b3/Point2f b4/Point2f -> Point2f?:

    // print "find intersection $x1,$y1 - $x2,$y2 and $x3,$y3 - $x4,$y4"
    // calculate the denominator and numerator
    denom  := (b4.y - b3.y) * (a2.x - a1.x) - (b4.x - b3.x) * (a2.y - a1.y)
    numera := (b4.x - b3.x) * (a1.y - b3.y) - (b4.y - b3.y) * (a1.x - b3.x)
    numerb := (a2.x - a1.x) * (a1.y - b3.y) - (a2.y - a1.y) * (a1.x - b3.x)
    
    if denom < 0.0: denom *= -1.0             // if negative, convert to positive
        
    // If the denominator is zero or close to it, it means that the lines are parallels, so return false for intersection
    //EPSILON_VALUE = 0.001  // todo
    if denom < 0.001: return NoPoint2f
    if numera < 0.0: numera *= -1.0  // if negative, convert to positive
    if numerb < 0.0: numerb *= -1.0         // if negative, convert to positive
    // verify if has intersection between the segments
    mua := numera / denom
    mub := numerb / denom
    return mua<0.0 or mua>1.0 or mub<0.0 or mub>1.0?
      NoPoint2f:
      Point2f (a1.x + mua * (a2.x - a1.x)) (a1.y + mua * (a2.y - a1.y))

*/