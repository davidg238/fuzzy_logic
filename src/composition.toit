// Copyright (c) 2021 Ekorau LLC

import .fuzzy-logic show *

/*
A composition is a piecewise linear function.
It is defined as a set of points, but many of the operations involve synthesized line segments.
The function is built adding the points of contributing fuzzy sets, taking the maximum of existing or added line segments.
The original eFLL used duplicate points to indicate the type of set.
*/

class Composition:

  foutput_ /FuzzyOutput := null
  crisp-out_ /float?:= null

  constructor .foutput_/FuzzyOutput:

  clear -> none:      //eFLL, "empty"
    crisp-out_ = null

  defuzzify -> float:
    if crisp-out_ == null:
      crisp-out_ = centroid-x  collect-truncated
    print "crisp-out_ = $(%.6f crisp-out_)"
    return crisp-out_

  collect-truncated -> List:
    subset := []
    foutput_.fsets.do:
      if it.is-pertinent:
        it.truncate
        subset.add it
    subset.sort --in-place: | a b | (a.a_.compare-to b.a_)
    return subset

  centroid-x subset/List -> float:
    weighted := 0.0
    tot-area := 0.0
    a-area := 0.0
    // print "Calculate centroid-x .... "
    if ((subset.size == 1) and (subset[0] is SingletonSet)): return subset[0].truncated-weighted-centroid
    subset.do:
      tot-area += it.truncated-area
      weighted += it.truncated-weighted-centroid
      // print "$it.name / $(%.2f it.pertinence) / $(%.2f it.truncated-area) / $(%.2f it.truncated-weighted-centroid) / $(%.2f weighted) / $(%.2f tot_area)"
    return weighted / tot-area

  centroid-x_ pts/List a-area/float -> float:
  // https://en.wikipedia.org/wiki/Centroid#Of_a_polygon
    cx := 0.0
    for i:=0;i<pts.size - 1;i++:
      cx += (pts[i].x + pts[i+1].x)*(pts[i].x * pts[i+1].y - pts[i+1].x * pts[i].y)
    cx = cx/(6*a-area)
    return cx

  area pts/List -> float:
    area := 0.0
    for i:=0;i<pts.size - 1;i++:
      area += (pts[i].x * pts[i+1].y) - (pts[i+1].x * pts[i].y)
    return area/2.0  

// SVG drawing support ---------------------------------------------------------
// TODO: move to html view class
  set-names -> List:
    names := []
    foutput_.fsets.do:
      if it.is-pertinent: 
        names.add it.name
    return names

  centroid-line -> string:
    return scale-svg-polyline_ [Point2f crisp-out_ 0, Point2f crisp-out_ 1]

  set-polylines -> List:
    list := []
    subset := collect-truncated
    subset.do:
      list.add (svg-polyline_ it)
    return list

  svg-polyline_ set/FuzzySet -> string:
    txt := ""
    points := set.truncated-polygon
    points.do:
        txt += "$(%.1f 4*it.x),$(%.1f 400*it.y) "
    return txt

  scale-svg-polyline_ points/List -> string:
    txt := ""
    points.do:
        txt += "$(%.1f 4*it.x),$(%.1f 400*it.y) "
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
