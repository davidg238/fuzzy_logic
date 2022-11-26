// Copyright (c) 2021 Ekorau LLC

import .fuzzy_set show FuzzySet
import .geometry show *

/*
A composition is a piecewise linear function.
It is defined as a set of points, but many of the operations involve synthesized line segments.
The function is built adding the points of contributing fuzzy sets, taking the maximum of existing or added line segments.
The original eFLL used duplicate points to indicate the type of set.
*/

class Composition:

  p_/List := []
  truncs := []
  trunc_names := []

  centroid_x -> float:
    p_.add p_.first  // the polygon must be closed for this algorithm to work
    cx := 0.0
    for i:=0;i<size-1;i++:
      cx += (p_[i].x + p_[i+1].x)*(p_[i].x * p_[i+1].y - p_[i+1].x * p_[i].y)
    cx = cx/(6*area_)
    p_.remove_last
    return cx

  area_ -> float:
    area := 0.0
    for i:=0;i<size-1;i++:
      area += (p_[i].x * p_[i+1].y) - (p_[i+1].x * p_[i].y)
    return area/2.0

  clear -> none:      //eFLL, "empty"
    p_.clear
    truncs.clear
    trunc_names.clear

  size -> int:          //eFLL, was countPoints
    return p_.size

  stringify -> string:
    txt := "$(this.size): "
    p_.do:
        txt = txt + "(%.1f $it) "
    return txt

  svg_polyline -> string:
    return svg_polyline_ p_

  svg_polyline_ points/List -> string:
    txt := ""
    points.do:
        txt = txt + "$(%.1f 4*it.x),$(%.1f 400*it.y) "
    print txt
    return txt

  trunc_svg_polylines -> List:
    list := []
    truncs.do:
      list.add (svg_polyline_ it)
    return list


  union new/List name/string -> none:
    print "To composition, add $name: $new"
    truncs.add new
    trunc_names.add name
/*   
    // print new
    if p_.is_empty:
      // print "set empty"
      p_.add_all new
    else:
      union_ := p_.copy
      intersects := []
      i := 0
      while i<new.size:
        if not new[i].inside p_:
          insert_ new[i] union_
          i++
        if i<new.size-1:
          add_intersections new[i] new[i+1] union_
      remove_insiders union_
      p_ = union_
*/    
  remove_insiders points/List -> none:
    temp := []
    temp.add points.first
    i := 1
    while i<points.size-1:
      if points[i].y > 0:
        temp.add points[i]
    temp.add points.last
    points = temp

  insert_ point/Point2f list/List -> none:
    idx := 0
    list.do:
      if (point.compare_to it) > 0:
        idx++
    temp := list.copy 0 idx
    temp.add point
    temp.add_all (list.copy idx list.size)
    list = temp

  add_intersections a/Point2f b/Point2f new/List -> none:
    i:= 0
    newp := null
    while i<p_.size-1:
      newp = intersection a b p_[i] p_[i+1]
      if not (newp is NoPoint2f):
        insert_ newp new


/// Test methods, NOT for production use ----------------------------------------------

  test_points -> List:
    return p_

  test_add_point x/num pertinence/num -> none:  /// eFLL, only used by test harness
    p_.add (Point2f x pertinence)

  test_any_point point/num pertinence/num -> bool:  /// eFLL, was checkPoint
    return p_.any: 
        (it.x == point) and (it.y == pertinence)

