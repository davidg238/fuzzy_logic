// Copyright (c) 2021 Ekorau LLC

import .fuzzy_set show FuzzySet
import .geometry show 
    Stack Point2f NoPoint
    intersection leftmost_lowest  
    forms_singleton forms_rectangle forms_triangle  
    tri_area tri_centroid rect_area rect_centroid rtrap_area rtrap_centroid
    convex_hull xy_sort


/*
A composition looks more like a traditional function plot of values than the sets.
Note, a point x and y values are stored as Point2f in the points List.
The original eFLL used duplicate points to indicate the type of set.
*/

class Composition:

    points/List := []

    add_point x/float pertinence/float -> none:  // only used by test harness, so no return
        points.add (Point2f x pertinence)

    any_point point/float pertinence/float -> bool:     /// was checkPoint, to resemble set operator
        return points.any: 
            (it.x == point) and (it.y == pertinence)

    calculate_centroid -> float:

        // print "$this"
        a := null
        b := null
        tot_area := 0.0
        tot_wcent := 0.0
        accumulate := : | area cent str |
                            tot_area += area
                            tot_wcent += cent*area
                            // print " ... $str: a$(%.2f area) c$(%.2f cent), ta$(%.2f tot_area) twc$(%.2f tot_wcent)"

        if (points.size==2) and (forms_singleton points[0] points[1]): return points[0].x
        for i:=0;i<points.size-1;i+=1:
            a = points[i] 
            b = points[i+1]
            if (forms_singleton a b):
                tot_wcent += a.x
            else if (forms_triangle a b):
                accumulate.call (tri_area a b) (tri_centroid a b) "tri"
            else if (forms_rectangle a b):
                accumulate.call (rect_area a b) (rect_centroid a b) "rect"
            else: // it is a right trapezoid
                accumulate.call (rtrap_area a b) (rtrap_centroid a b) "rtrap"
        return (tot_area==0)? 0.0 : (tot_wcent/tot_area)

    clear -> none:      //was "empty"
        points.clear

    size -> int:                                //was countPoints
        return points.size

    stringify -> string:
        txt := "$(this.size): "
        points.do:
            txt = txt + "$it , "
        return txt

    union set/List -> none:     /// the order in which points are added is not so important, re-sorted later
        if points.is_empty:
            // print "set empty"
            points.add_all set
        else:
            temp := points.copy
            for i:=0; i<set.size-1; i+=1:
                temp.add set[i]
                // print "adding $set[i]"
                for j:=0;j<points.size-1;j+=1:
                    intersect := intersection set[i] set[i+1] points[j] points[j+1]
                    if (not intersect is NoPoint):
                        temp.add intersect
                //        print "add interesect: $intersect"
            temp.add set.last
            // print "adding set last $set.last"
            points = temp

    simplify -> none:
        /// https://en.wikibooks.org/wiki/Algorithm_Implementation/Geometry/Convex_hull/Monotone_chain
        // print "$this"
        if points.size < 3:
            if points.size == 2:
                if forms_singleton points[0] points[1]: return  // no need to simplify further
            else:
                throw "attempt to simplify unknown geometry, with $(points.size) points"

        temp := xy_sort points
        // this simplification will only work for a limited subset of intersecting triangular and trapezoidal fuzzy sets, 
        //  otherwise you will get bad results.  Until concave_hull algorithm working.
        if temp.first.y != 0.0: throw "heuristic failed"
        temp2 := []
        temp2.add temp.first
        for i:=1; i<temp.size-1; i+=1:  // remove any points, between the first and last, with y=0.0
            if (temp[i].y != 0.0): 
                temp2.add temp[i]
        temp2.add temp.last    
        points = temp2