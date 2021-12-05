// Copyright (c) 2021 Ekorau LLC

import math show *

// Method to rebuild some point, the new point is calculated finding the intersection between two lines

intersection a1/Point2f a2/Point2f b3/Point2f b4/Point2f -> Point2f:

    // print "find intersection $x1,$y1 - $x2,$y2 and $x3,$y3 - $x4,$y4"
    // calculate the denominator and numerator
    denom  := (b4.y - b3.y) * (a2.x - a1.x) - (b4.x - b3.x) * (a2.y - a1.y)
    numera := (b4.x - b3.x) * (a1.y - b3.y) - (b4.y - b3.y) * (a1.x - b3.x)
    numerb := (a2.x - a1.x) * (a1.y - b3.y) - (a2.y - a1.y) * (a1.x - b3.x)
    
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
        return Point2f (a1.x + mua * (a2.x - a1.x)) (a1.y + mua * (a2.y - a1.y))

concave_hull points/List k/int -> List:
    return []
/*
    kk := max k 3
    dataset := remove_duplicates points
    if dataset.size<3: return []
    if dataset.size==3: return dataset
    kk = min kk (dataset.size-1)             // make sure that k neighbours can be found
    firstPoint := leftmost_lowest dataset
9: hull ← {firstPoint} ► initialize the hull with the first point
10: currentPoint ← firstPoint
11: dataset ← RemovePoint[dataset,firstPoint] ► remove the first point
12: previousAngle ← 0
13: step ← 2
14: While ((currentPoint≠firstPoint)or(step=2))and(Length[dataset]>0)
15: If step=5
16:
dataset ← AddPoint[dataset,firstPoint] ► add the firstPoint again
17: kNearestPoints ← NearestPoints[dataset,currentPoint,kk] ► find the nearest neighbours
18: cPoints ← SortByAngle[kNearestPoints,currentPoint,prevAngle] ► sort the candidates
(neighbours) in descending order of right-hand turn
19: its ← True
20: i ← 0
21: While (its=True)and(i<Length[cPoints]) ► select the first candidate that does not intersects any
of the polygon edges
22:
i++
23:
If cPoints i =firstPoint
24:
lastPoint ← 1
25:
else
26:
lastPoint ← 0
27:
j ← 2
28:
its ← False
29:
While (its=False)and(j<Length[hull]-lastPoint)
30:
its ← IntersectsQ[{hull step-1 ,cPoints i },{hull step-1-j ,hull step-j }]
31:
j++
32: If its=True ► since all candidates intersect at least one edge, try again with a higher number of neighbours
33:
Return[ConcaveHull[pointsList,kk+1]]
34: currentPoint ← cPoints i
35: hull ← AddPoint[hull,currentPoint] ► a valid candidate was found
36: prevAngle ← Angle[hull step ,hull step-1 ]
37: dataset ← RemovePoint[dataset,currentPoint]
38: step++
39: allInside ← True
40: i ← Length[dataset]
41: While (allInside=True)and(i>0) ► check if all the given points are inside the computed polygon
42: allInside ← PointInPolygonQ[dataset i ,hull]
43: i--
44: If allInside=False
45: Return[ConcaveHull[pointsList,kk+1]] ► since at
*/



convex_hull points/List -> List:
    /// https://en.wikipedia.org/wiki/Graham_scan
    /// 
    stack := Stack
    p0 := leftmost_lowest points
    temp := polar_sort points p0
    temp.do:
        // pop the last point from the stack if we turn clockwise to reach this point
        while stack.size > 1 and (ccw stack.next_to_top stack.top it) <= 0:
            stack.pop
        stack.push it
    return stack.to_list

upper_convex_hull points/List -> List:
    /// https://en.wikibooks.org/wiki/Algorithm_Implementation/Geometry/Convex_hull/Monotone_chain

    if points.size < 3:
        throw "unknown geometry"

    val := null
    temp := xy_sort points
    // print "after sort: $temp"
    stack := Stack
    temp.do --reversed=true:
        while stack.size > 1 and (ccw stack.next_to_top stack.top it) <= 0:
            val = stack.pop
            // print "for $it, pop $val"
        stack.push it
        // print "push $it"
    return stack.to_list

ccw a/Point2f b/Point2f c/Point2f -> any:
// ccw > 0 if three points make a counter-clockwise turn, clockwise if ccw < 0, and collinear if ccw = 0

    val := ((b.x-a.x)*(c.y-a.y))-((b.y-a.y)*(c.x-a.x))
    return (val.abs < 0.001)? 0.0 : val

xy_sort points/List -> List:
    return points.sort: | a b |
        i := a.x.compare_to b.x
        (i != 0)? i : a.y.compare_to b.y
        
polar_sort points/List p0/Point2f -> List:
    return points.sort: | a b | (p0.polar_angle a).compare_to (p0.polar_angle b)

/// The following functions are for shapes formed with the x-axis, the "top" formed by the line segment

forms_rectangle a/Point2f b/Point2f -> bool: 
    return (a.y == b.y)

forms_singleton a/Point2f b/Point2f -> bool: 
    return (a.y!=b.y) and (a.x==b.x)

forms_triangle a/Point2f b/Point2f -> bool: 
    return (a.y != b.y) and ((a.y==0.0) or (b.y==0.0))

leftmost_lowest points/List -> Point2f:
    p0 := points.first // assumes a non-empty list
    points.do:
        if (it.x<=p0.x) and (it.y<=p0.y): p0 = it
    return p0


rect_area a/Point2f b/Point2f -> float:
    return (a.y * (b.x-a.x))

rect_centroid a/Point2f b/Point2f -> float:
    return (a.x+b.x)/2

rtrap_area a/Point2f b/Point2f -> float: // right trapezoid
    return ((a.y+b.y)/2)*(b.x-a.x)

rtrap_centroid a/Point2f b/Point2f -> float:
    return (b.x-a.x)/2 + a.x

tri_area a/Point2f b/Point2f -> float:
    return a.y==0.0?
        (b.y*(b.x-a.x))/2:
        (a.y*(b.x-a.x))/2

tri_centroid a/Point2f b/Point2f -> float:
    return a.y==0.0?
        (b.x-a.x)*2/3 + a.x:
        (b.x-a.x)/3   + a.x

class Point2f:

    x/float 
    y/float

    constructor .x .y:

    polar_angle b/Point2f -> float:
        return atan ((b.y - y)/(b.x - x))

    stringify: return "($(%.2f x),$(%.2f y))"


    

class NoPoint extends Point2f:

    constructor:
        super float.NAN float.NAN


class Stack extends Deque:

  push element -> none:
    add element

  pop -> any:
    return remove_last

  reversed -> List:
    list := []
    this.do --reversed=true:
        list.add it
    return list

  to_list -> List:
    list := []
    this.do: list.add it
    return list

  top -> any:
    return last

  next_to_top -> any:
    return backing_[size-2]

/*


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