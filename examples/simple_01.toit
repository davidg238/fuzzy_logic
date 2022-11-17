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

main:

    small := FuzzySet 0.0 20.0 20.0 40.0 "small"
    safe  := FuzzySet 30.0 50.0 50.0 70.0 "safe"
    big   := FuzzySet 60.0 80.0 80.0 80.0 "big"
    distance := FuzzyInput 0 "distance"
    distance.add_set small
    distance.add_set safe
    distance.add_set big

    slow    := FuzzySet 0.0 10.0 10.0 20.0 "slow"
    average := FuzzySet 10.0 20.0 30.0 40.0 "average"
    fast    := FuzzySet 30.0 40.0 40.0 50.0 "fast"
    speed := FuzzyOutput 0 "speed"
    speed.add_set slow
    speed.add_set average
    speed.add_set fast

    rule_01 := FuzzyRule 0 (Antecedent.set small) (Consequent.output slow)     // "IF distance = small THEN speed = slow"
    rule_02 := FuzzyRule 1 (Antecedent.set safe) (Consequent.output average)   // "IF distance = safe THEN speed = average"
    rule_03 := FuzzyRule 2 (Antecedent.set big) (Consequent.output fast)       // "IF distance = big THEN speed = high"

    model := FuzzyModel "driver"
    model.add_input distance
    model.add_output speed
    model.add_rule rule_01
    model.add_rule rule_02
    model.add_rule rule_03

  //  print "$model"

    start := Time.monotonic_us
    m_input := 35 //todo, test with 100
    // print "real input : $m_input"
    model.set_input 0 m_input.to_float
    //print "about to fuzzify"
    model.fuzzify
    m_output := model.defuzzify 0
    end := Time.monotonic_us

    print "Time: $(%.1f (end-start)/1000.0)ms Distance: $m_input ---> Speed: $(%.1f m_output)"
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