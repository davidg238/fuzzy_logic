import fuzzy_logic show *

main:

    small := FuzzySet 0.0 20.0 20.0 40.0 "small"
    safe  := FuzzySet 30.0 50.0 50.0 70.0 "safe"

    lrat := LraTriangularSet 20 50 "lrat"
    rrat := RraTriangularSet 50 80 "rrat"

    small.pertinence 1.0
    safe.pertinence  1.0
/*
    comp := Composition
    comp.union small.truncated
    print comp
    comp.union safe.truncated
    print comp
    comp.simplify
    print comp.as_svg_polyline
*/

    comp := Composition
    comp.test_add_point 0 0
    comp.test_add_point 0 6
    comp.test_add_point 1 4
    comp.test_add_point 1 0


    comp = Composition
    comp.union small.truncated
    print "cx $comp.centroid_x"

    comp = Composition
    comp.union lrat.truncated
    print "lrat cx $comp.centroid_x"
    
    comp = Composition
    comp.union rrat.truncated
    print "rrat cx $comp.centroid_x"
    