    // Copyright (c) 2021 Ekorau LLC

import .test_util show *

import fuzzy_model show FuzzyModel
import composition show Composition
import fuzzy_input show FuzzyInput
import fuzzy_output show FuzzyOutput
import fuzzy_set show FuzzySet
import fuzzy_rule show FuzzyRule
import antecedent show Antecedent
import consequent show Consequent

import expect show *

main:

    TEST_START

    
    TEST "FuzzyModel" "setInputAndFuzzifyAndIsFiredRuleAndDefuzzify":
        fuzzy := FuzzyModel "setInputAndFuzzifyAndIsFiredRuleAndDefuzzify"

        // FuzzyInput
        temperature := FuzzyInput 0

        low := FuzzySet 0.0 10.0 10.0 20.0 "low"
        temperature.add_set low
        mean := FuzzySet 10.0 20.0 30.0 40.0 "mean"
        temperature.add_set mean
        high := FuzzySet 30.0 40.0 40.0 50.0 "high"
        temperature.add_set high

        fuzzy.add_input temperature

        // FuzzyOutput
        climate := FuzzyOutput 0
        cold := FuzzySet 0.0 10.0 10.0 20.0 "cold"
        climate.add_set cold

        good := FuzzySet 10.0 20.0 30.0 40.0 "good"
        climate.add_set good

        hot := FuzzySet 30.0 40.0 40.0 50.0 "hot"
        climate.add_set hot

        fuzzy.add_output climate

        // Building FuzzyRule
        if_TemperatureLow := Antecedent.join_set low
        then_ClimateCold := Consequent.output cold

        fuzzyRule0 := FuzzyRule 0 if_TemperatureLow then_ClimateCold
        fuzzy.add_rule fuzzyRule0

        // Building FuzzyRule
        if_TemperatureMean := Antecedent.join_set mean
        then_ClimateGood := Consequent.output good

        fuzzyRule1 := FuzzyRule 1 if_TemperatureMean then_ClimateGood
        fuzzy.add_rule fuzzyRule1

        // Building FuzzyRule
        if_TemperatureHigh := Antecedent.join_set high
        then_ClimateHot := Consequent.output cold

        fuzzyRule2 := FuzzyRule 2 if_TemperatureHigh then_ClimateHot
        fuzzy.add_rule fuzzyRule2

        ASSERT_RUNS: fuzzy.set_input 0 15.0

        print "$fuzzy"

        print " ------------ fuzzify ----------------------"
        fuzzy.fuzzify

        ASSERT_TRUE  (fuzzy.is_fired 0)
        ASSERT_TRUE  (fuzzy.is_fired 1)
        ASSERT_FALSE (fuzzy.is_fired 2)

        ASSERT_FLOAT_EQ 19.375 (fuzzy.defuzzify 0)

    TEST_END