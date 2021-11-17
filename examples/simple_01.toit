// Copyright 2021 Ekorau LLC

import fuzzy_model show FuzzyModel
import fuzzy_input show FuzzyInput
import fuzzy_output show FuzzyOutput
import fuzzy_set show FuzzySet
import fuzzy_rule show FuzzyRule
import antecedent show Antecedent
import consequent show Consequent

main:

    small := FuzzySet 0.0 20.0 20.0 40.0
    safe  := FuzzySet 30.0 50.0 50.0 70.0
    big   := FuzzySet 60.0 80.0 80.0 80.0
    distance := FuzzyInput 0
    distance.add_set small
    distance.add_set safe
    distance.add_set big

    slow    := FuzzySet 0.0 10.0 10.0 20.0
    average := FuzzySet 10.0 20.0 30.0 40.0
    fast    := FuzzySet 30.0 40.0 40.0 50.0
    speed := FuzzyOutput 0
    speed.add_set slow
    speed.add_set average
    speed.add_set fast

    rule_01 := FuzzyRule 0 (Antecedent.join_set small) (Consequent.output slow)   // "IF distance = small THEN speed = slow"
    rule_02 := FuzzyRule 1 (Antecedent.join_set safe) (Consequent.output average) // "IF distance = safe THEN speed = average"
    rule_03 := FuzzyRule 2 (Antecedent.join_set big) (Consequent.output fast)     // "IF distance = big THEN speed = high"

    model := FuzzyModel
    model.add_input distance
    model.add_output speed
    model.add_rule rule_01
    model.add_rule rule_02
    model.add_rule rule_03

    print "about to loop ..."
    10.repeat:
        m_input := random 0 100
        model.set_input 0 m_input.to_float
        //print "about to fuzzify"
        model.fuzzify
        m_output := model.defuzzify 0
        print "Distance: $m_input ---> Speed: $m_output"
        sleep --ms=1000