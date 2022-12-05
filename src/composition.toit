// Copyright (c) 2021 Ekorau LLC

import .fuzzy_logic show *

/*
A composition is a piecewise linear function.
It is defined as a set of points, but many of the operations involve synthesized line segments.
The function is built adding the points of contributing fuzzy sets, taking the maximum of existing or added line segments.
The original eFLL used duplicate points to indicate the type of set.
*/

class Composition:

  foutput_ /FuzzyOutput := null
  polygons_/List := []
  crisp_out_ /float?:= null

  constructor .foutput_/FuzzyOutput:

  clear -> none:      //eFLL, "empty"
    crisp_out_ = null

  defuzzify -> float:
    if crisp_out_ == null:
      collect_truncated_
      crisp_out_ = centroid_x_  
    return crisp_out_

  collect_truncated_ -> none:
    polygons_.clear
    subsets_ := []
    foutput_.fsets.do:
      if it.is_pertinent:
        subsets_.add it
    subsets_.sort --in_place: | a b | (a.a_.compare_to b.a_)
    subsets_.do:
        polygons_.add it.truncated_polygon

  centroid_x_ -> float:
    weighted := 0.0
    tot_area := 0.0
    a_area := 0.0
    polygons_.do:
      a_area = area it
      tot_area += a_area
      weighted += (a_area * (centroid_x_ it a_area))
    return weighted / tot_area

  centroid_x_ pts/List a_area/float -> float:
  // https://en.wikipedia.org/wiki/Centroid#Of_a_polygon
    cx := 0.0
    for i:=0;i<pts.size-1;i++:
      cx += (pts[i].x + pts[i+1].x)*(pts[i].x * pts[i+1].y - pts[i+1].x * pts[i].y)
    cx = cx/(6*a_area)
    return cx

  area pts/List -> float:
    area := 0.0
    for i:=0;i<pts.size-1;i++:
      area += (pts[i].x * pts[i+1].y) - (pts[i+1].x * pts[i].y)
    return area/2.0  

// SVG drawing support ---------------------------------------------------------
  set_names -> List:
    names := []
    foutput_.fsets.do:
      if it.is_pertinent: 
        names.add it.name
    return names

  centroid_line -> string:
    return svg_polyline_ [Point2f crisp_out_ 0, Point2f crisp_out_ 1]

  set_polylines -> List:
    list := []
    polygons_.do:
      list.add (svg_polyline_ it)
    return list

  svg_polyline_ points/List -> string:
    txt := ""
    points.do:
        txt = txt + "$(%.1f 4*it.x),$(%.1f 400*it.y) "
    // print txt
    return txt

/// Test methods, NOT for production use ---------------------------------------
/*
  test_points -> List:
    return p_

  test_add_point x/num pertinence/num -> none:  /// eFLL, only used by test harness
    p_.add (Point2f x pertinence)

  test_any_point point/num pertinence/num -> bool:  /// eFLL, was checkPoint
    return p_.any: 
        (it.x == point) and (it.y == pertinence)
*/
