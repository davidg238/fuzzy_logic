// Copyright 2021 Ekorau LLC
/*
import fuzzy_model show FuzzyModel
import fuzzy_input show FuzzyInput
import fuzzy_output show FuzzyOutput
import fuzzy_set show FuzzySet
import fuzzy_rule show FuzzyRule
import antecedent show Antecedent
import consequent show Consequent
*/
import fuzzy_logic show *
import .models show *

main:

  amodel := get_speed_model
  print amodel
  //  print "$model"
/*
    start := Time.monotonic_us
    m_input := 35 //todo, test with 100
    // print "real input : $m_input"
    model.set_input 0 m_input.to_float
    //print "about to fuzzify"
    model.fuzzify
    m_output := model.defuzzify 0
    end := Time.monotonic_us

    print "Time: $(%.1f (end-start)/1000.0)ms Distance: $m_input ---> Speed: $(%.1f m_output)"
*/
  fuzzyInput := FuzzyInput
  fuzzySet := FuzzySet 0.0 10.0 10.0 20.0
  print "... should be triangular $fuzzySet"
  print (fuzzySet is TriangularSet)
/*
    u := Point2f 5.0 10.0
    l := Point2f 5.0 3
    o := Point2f 5.0 5.0
    t := Point2f 3 5
    a := Point2f 4 5
    b := Point2f 8 5
    h := Point2f 12 5

    print b
    print "$(u.counter_clockwise a b)"
    print "$(o.counter_clockwise a b)"
    print "$(l.counter_clockwise a b)"
    print "$(t.counter_clockwise a b)"
    print "$(h.counter_clockwise a b)"
*/