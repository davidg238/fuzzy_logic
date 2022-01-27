// Copyright (c) 2021 Ekorau LLC

import .test_util show test_start test_end test expect_true expect_false expect_near expect_not_null expect_runs expect_equals

import fuzzy_model show FuzzyModel
import composition show Composition
import fuzzy_input show FuzzyInput
import fuzzy_output show FuzzyOutput
import fuzzy_set show FuzzySet
import fuzzy_rule show FuzzyRule
import antecedent show Antecedent
import consequent show Consequent

import set_triangular show TriangularSet
import set_trapezoidal show TrapezoidalSet
import set_trapezoidal_l show LTrapezoidalSet
import set_trapezoidal_r show RTrapezoidalSet

import expect show *

main:

    test_start

/// Test FuzzySet

    test "FuzzySet" "getPoints":

        fuzzySet := FuzzySet 0.0 10.0 20.0 30.0 "set"
        expect_near 0.0 fuzzySet.a
        expect_near 10.0 fuzzySet.b
        expect_near 20.0 fuzzySet.c
        expect_near 30.0 fuzzySet.d

    test "FuzzySet" "calculateAndGetPertinence":

        fuzzySet1 := FuzzySet 0.0 10.0 10.0 20.0 "set1"

        expect_true: fuzzySet1 is TriangularSet

        fuzzySet1.calculate_pertinence -5.0
        expect_near 0.0 fuzzySet1.pertinence

        fuzzySet1.calculate_pertinence 5.0
        expect_near 0.5 fuzzySet1.pertinence

        fuzzySet1.calculate_pertinence 10.0
        expect_near 1.0 fuzzySet1.pertinence

        fuzzySet1.calculate_pertinence 15.0
        expect_near 0.5 fuzzySet1.pertinence
        // expect_equals 0.4 fuzzySet1.pertinence  //usage of expect methods?

        fuzzySet1.calculate_pertinence 25.0
        expect_near 0.0 fuzzySet1.pertinence

        fuzzySet2 := FuzzySet  0.0 0.0 20.0 30.0

        expect_true: fuzzySet2 is LTrapezoidalSet

        fuzzySet2.calculate_pertinence -5.0
        expect_near 1.0 fuzzySet2.pertinence

        fuzzySet3 := FuzzySet 0.0 10.0 20.0 20.0

        expect_true: fuzzySet3 is RTrapezoidalSet

        fuzzySet3.calculate_pertinence 25.0
        expect_near 1.0 fuzzySet3.pertinence


    test "FuzzyInput" "addFuzzySet":
        fuzzyInput := FuzzyInput 0
        fuzzySet := FuzzySet 0.0 10.0 10.0 20.0

        expect_true: fuzzySet is TriangularSet

        expect_runs: // deleted bool return of C functions, since in usual code, unchecked?
            fuzzyInput.add_set fuzzySet

    test "FuzzyInput" "setCrispInputAndGetCrispInput":

        fuzzyInput := FuzzyInput 1;
        fuzzyInput.crisp_in = 10.190
        expect_near 10.190 fuzzyInput.crisp_in


    test "FuzzyInput" "calculateFuzzySetPertinences":

        fuzzyInput := FuzzyInput 0
        fuzzySet1 := FuzzySet 0.0 10.0 10.0 20.0 "set1"
        fuzzyInput.add_set fuzzySet1
        fuzzySet2 := FuzzySet 10.0 20.0 20.0 30.0 "set2"

        expect_true: fuzzySet2 is TriangularSet
        fuzzyInput.add_set fuzzySet2
        fuzzyInput.crisp_in = 5.0

        expect_runs: fuzzyInput.calculate_set_pertinences

        expect_near 0.5 fuzzySet1.pertinence
        expect_near 0.0 fuzzySet2.pertinence


    test "Composition" "addPointAndCheckPoint":
        composition := Composition 

        expect_runs: composition.add_point 1.0 0.1
        expect_true:  (composition.any_point 1.0 0.1)

        expect_runs: composition.add_point 5.0 0.5
        expect_true:  (composition.any_point 5.0 0.5)

        expect_runs: composition.add_point 9.0 0.9
        expect_true:  (composition.any_point 9.0 0.9)

        expect_false: (composition.any_point 5.0 0.1)


    test "Composition" "build":
        composition := Composition

        tri1 := FuzzySet 0.0 10.0 10.0 20.0
        tri1.pertinence 1.0
        composition.union tri1.truncated
//        print "composition: $composition"

/*
        composition.add_point 0.0 0.0
        composition.add_point 10.0 1.0
        composition.add_point 20.0 0.0
*/      
        tri2 := FuzzySet 10.0 20.0 20.0 30.0
        tri2.pertinence 1.0
        composition.union tri2.truncated
//        print "composition: $composition"

/*
        composition.add_point 10.0 0.0
        composition.add_point 20.0 1.0
        composition.add_point 30.0 0.0
*/

        expect_runs: composition.simplify

        //print "composition: $composition"

        expect_true: (composition.any_point 0.0 0.0)
        expect_true: (composition.any_point 10.0 1.0)
        expect_false: (composition.any_point 20.0 0.0)
        expect_true: (composition.any_point 15.0 0.5)
        expect_false: (composition.any_point 10.0 0.0)
        expect_true: (composition.any_point 20.0 1.0)
        expect_true: (composition.any_point 30.0 0.0)

    test "Composition" "calculateAndEmptyAndCountPoints":
        composition := Composition

        sing := FuzzySet 25.0 25.0 25.0 25.0
        sing.pertinence 1.0
        composition.union sing.truncated
        // print "sing composition: $composition"
/*
        composition.add_point 25.0 0.0
        composition.add_point 25.0 1.0
        composition.add_point 25.0 0.0
*/
        expect_runs: composition.simplify
        expect_equals 2 composition.size // size should be 2, not 3 ? ... check original
        expect_near 25.0 composition.calculate_centroid
        expect_runs: composition.clear


        tri := FuzzySet 10.0 20.0 20.0 30.0
        tri.pertinence 1.0
        composition.union tri.truncated
        // print "tri composition: $composition"
/*
        composition.add_point 10.0 0.0
        composition.add_point 20.0 1.0
        composition.add_point 30.0 0.0
*/        
        expect_runs: composition.simplify
        expect_equals 3 composition.size
        expect_near 20.0 composition.calculate_centroid
        expect_runs: composition.clear

        trap := FuzzySet 20.0 30.0 50.0 60.0
        trap.pertinence 1.0
        composition.union trap.truncated
        // print "trap composition: $composition"
/*
        composition.add_point 20.0 0.0
        composition.add_point 30.0 1.0
        composition.add_point 50.0 1.0
        composition.add_point 60.0 0.0
*/
        expect_runs: composition.simplify
        expect_equals 4 composition.size
        expect_near 40.0 composition.calculate_centroid
        expect_runs: composition.clear

//todo
/*
        composition.add_point 0.0 0.0
        composition.add_point 10.0 1.0
        composition.add_point 20.0 0.0
        composition.add_point 10.0 0.0
        composition.add_point 20.0 1.0
        composition.add_point 30.0 0.0
        composition.add_point 20.0 0.0
        composition.add_point 30.0 1.0
        composition.add_point 40.0 0.0
        expect_runs: composition.simplify
        expect_equals 7 composition.size
        expect_near 20.0 composition.calculate_centroid
*/
    test "FuzzyOutput" "getIndex":
        fuzzyOutput := FuzzyOutput 0
        expect_equals 0 fuzzyOutput.index  //check original cpp, used 0 index


    test "FuzzyOutput" "setCrispInputAndGetCrispInput":
        fuzzyOutput := FuzzyOutput 0
        fuzzyOutput.crisp_in = 10.190
        expect_near 10.190 fuzzyOutput.crisp_in


    test "FuzzyOutput" "addFuzzySetAndResetFuzzySets":
        fuzzyOutput := FuzzyOutput 0
        fuzzySetTest := FuzzySet 0.0 10.0 10.0 20.0

        expect_runs: fuzzyOutput.add_set fuzzySetTest

        fuzzySetTest.pertinence 0.242
        expect_near 0.242 fuzzySetTest.pertinence

        fuzzyOutput.reset_sets

        expect_near 0.0 fuzzySetTest.pertinence


    test "FuzzyOutput" "truncateAndGetCrispOutputAndGetFuzzyComposition":
        fuzzyOutput := FuzzyOutput 0

        expect_equals 0 fuzzyOutput.index

        fuzzySetTest0 := FuzzySet 0.0 10.0 10.0 20.0 "set0"
        expect_true: fuzzySetTest0 is TriangularSet
        fuzzySetTest0.pertinence 1.0
        fuzzyOutput.add_set fuzzySetTest0

        fuzzySetTest1 := FuzzySet 10.0 20.0 20.0 30.0
        expect_true: fuzzySetTest1 is TriangularSet
        fuzzySetTest1.pertinence 1.0
        fuzzyOutput.add_set fuzzySetTest1

        fuzzySetTest2 := FuzzySet 20.0 30.0 30.0 40.0 "set2"
        expect_true: fuzzySetTest2 is TriangularSet
        fuzzySetTest2.pertinence 1.0
        fuzzyOutput.add_set fuzzySetTest2

        expect_runs : fuzzyOutput.truncate

        fuzzyComposition := fuzzyOutput.composition

        expect_not_null fuzzyComposition

        expect_equals 7 fuzzyComposition.size //todo, original .cpp test shows 8 ... pen&paper looks 7

        expect_true: (fuzzyComposition.any_point 0.0 0.0)
        expect_true: (fuzzyComposition.any_point 10.0 1.0)
        expect_false: (fuzzyComposition.any_point 20.0 0.0)

        expect_true: (fuzzyComposition.any_point 15.0 0.5)

        expect_false: (fuzzyComposition.any_point 10.0 0.0)
        expect_true: (fuzzyComposition.any_point 20.0 1.0)
        expect_false: (fuzzyComposition.any_point 30.0 0.0)

        expect_true: (fuzzyComposition.any_point 25.0 0.5)

        expect_false: (fuzzyComposition.any_point 20.0 0.0)
        expect_true: (fuzzyComposition.any_point 30.0 1.0)
        expect_true: (fuzzyComposition.any_point 40.0 0.0)

        expect_near 20.0 fuzzyOutput.crisp_out


    test "Antecedent" "joinSingleAndEvaluate":
        antecedent := null

        fuzzySet := FuzzySet 0.0 10.0 10.0 20.0
        fuzzySet.pertinence 0.25

        expect_runs: antecedent = Antecedent.set fuzzySet
        expect_near 0.25 antecedent.evaluate     


    test "Antecedent" "joinTwoFuzzySetAndEvaluate":

        fuzzySet1 := FuzzySet 0.0 10.0 10.0 20.0
        fuzzySet1.pertinence 0.25
        fuzzySet2 := FuzzySet 10.0 20.0 20.0 30.0
        fuzzySet2.pertinence 0.75

        antecedent1 := null
        expect_runs:
            antecedent1 = Antecedent.AND_sets fuzzySet1 fuzzySet2
        expect_near 0.25 antecedent1.evaluate   

        antecedent2 := null
        expect_runs: antecedent2 = Antecedent.OR_sets fuzzySet1 fuzzySet2
        expect_near 0.75 antecedent2.evaluate   


    test "Antecedent" "joinOneFuzzySetAndOneFuzzyAntecedentAndEvaluate":
        fuzzySet1 := FuzzySet 0.0 10.0 10.0 20.0
        fuzzySet1.pertinence 0.25

        fuzzySet2 := FuzzySet 10.0 20.0 20.0 30.0
        fuzzySet2.pertinence 0.75
        antecedent1 := Antecedent.set fuzzySet2

        antecedent2 := Antecedent.AND_set_ante fuzzySet1 antecedent1
        expect_near 0.25 antecedent2.evaluate

        antecedent3 := Antecedent.AND_ante_set antecedent1 fuzzySet1
        expect_near 0.25 antecedent3.evaluate    //4

        antecedent4 := Antecedent.OR_set_ante fuzzySet1 antecedent1
        expect_near 0.75 antecedent4.evaluate    

        antecedent5 := Antecedent.OR_ante_set antecedent1 fuzzySet1
        expect_near 0.75 antecedent5.evaluate    //8


    test "Antecedent" "joinTwoFuzzyAntecedentAndEvaluate":
        fuzzySet1 := FuzzySet  0.0 10.0 10.0 20.0 "set1"
        fuzzySet1.pertinence 0.25
        antecedent1 := Antecedent.set fuzzySet1

        fuzzySet2 := FuzzySet  10.0 20.0 20.0 30.0 "set2"
        fuzzySet2.pertinence 0.75
        fuzzySet3 := FuzzySet  30.0 40.0 40.0 50.0 "set3"
        fuzzySet3.pertinence 0.5
        antecedent2 := Antecedent.OR_sets fuzzySet2 fuzzySet3

        antecedent3 := null
        expect_runs: antecedent3 = Antecedent.AND_ante_ante antecedent1 antecedent2

        expect_near 0.25 antecedent3.evaluate    
        antecedent4 := null
        expect_runs: antecedent4 = Antecedent.OR_ante_ante antecedent1 antecedent2

        expect_near 0.75 antecedent4.evaluate    


    test "Consequent" "addOutputAndEvaluate":
        fuzzySet1 := FuzzySet 0.0 10.0 10.0 20.0 "set1"
        fuzzySet2 := FuzzySet 10.0 20.0 20.0 30.0 "set2"

        fuzzyRuleConsequent := null
        expect_runs: fuzzyRuleConsequent = Consequent.output fuzzySet1

        fuzzyRuleConsequent.add_output fuzzySet2

        expect_runs: fuzzyRuleConsequent.evaluate 0.5

        expect_near 0.5 fuzzySet1.pertinence
        expect_near 0.5 fuzzySet2.pertinence


    test "FuzzyRule" "getIndexAndEvaluateExpressionAndIsFired":
        fuzzySet := FuzzySet 0.0 10.0 10.0 20.0
        fuzzySet.pertinence 0.75
        antecedent1 := Antecedent.set fuzzySet

        fuzzySet2 := FuzzySet 0.0 10.0 10.0 20.0
        fuzzySet2.pertinence 0.25
        antecedent2 := Antecedent.set fuzzySet2

        antecedent3 := Antecedent.AND_ante_ante antecedent1 antecedent2

        fuzzySet3 := FuzzySet 0.0 10.0 10.0 20.0
        fuzzyRuleConsequent := Consequent.output fuzzySet3

        fuzzyRule := FuzzyRule 1 antecedent3 fuzzyRuleConsequent

        expect_equals 1 fuzzyRule.index
        expect_false: fuzzyRule.fired

        expect_true: fuzzyRule.evaluate

        expect_true: fuzzyRule.fired

    test "FuzzyModel" "addFuzzyInput":

        fuzzy := FuzzyModel
        fuzzyInput := FuzzyInput 0

        fuzzySet0 := FuzzySet 0.0 10.0 10.0 20.0
        fuzzyInput.add_set fuzzySet0
        fuzzySet1 := FuzzySet 10.0 20.0 20.0 30.0
        fuzzyInput.add_set fuzzySet1
        fuzzySet2 := FuzzySet 20.0 30.0 30.0 40.0
        fuzzyInput.add_set fuzzySet2

        expect_runs: fuzzy.add_input fuzzyInput


    test "FuzzyModel" "addFuzzyOutput":
        fuzzy := FuzzyModel

        fuzzyOutput := FuzzyOutput 0

        fuzzySet0 := FuzzySet 0.0 10.0 10.0 20.0
        fuzzyOutput.add_set fuzzySet0
        fuzzySet1 := FuzzySet 10.0 20.0 20.0 30.0
        fuzzyOutput.add_set fuzzySet1
        fuzzySet2 := FuzzySet 20.0 30.0 30.0 40.0
        fuzzyOutput.add_set fuzzySet2

        expect_runs: fuzzy.add_output fuzzyOutput

    test "FuzzyModel" "addFuzzyRule":

        fuzzy := FuzzyModel

        fuzzySet0 := FuzzySet 0.0 10.0 10.0 20.0
        fuzzySet0.pertinence 0.25
        antecedent0 := Antecedent.set fuzzySet0

        fuzzySet1 := FuzzySet 0.0 10.0 10.0 20.0
        fuzzySet1.pertinence 0.75
        antecedent1 := Antecedent.set fuzzySet1
        
        antecedent2 := Antecedent.AND_ante_ante antecedent0 antecedent1
        fuzzySet2 := FuzzySet 0.0 10.0 10.0 20.0
        fuzzyRuleConsequent := Consequent.output fuzzySet2

        fuzzyRule := FuzzyRule 0 antecedent2 fuzzyRuleConsequent

        expect_runs: fuzzy.add_rule fuzzyRule

    test "FuzzyModel" "setInputAndFuzzifyAndIsFiredRuleAndDefuzzify":
        fuzzy := FuzzyModel

        // FuzzyInput
        temperature := FuzzyInput 0

        low := FuzzySet 0.0 10.0 10.0 20.0
        temperature.add_set low
        mean := FuzzySet 10.0 20.0 30.0 40.0
        expect_true: mean is TrapezoidalSet
        temperature.add_set mean
        high := FuzzySet 30.0 40.0 40.0 50.0
        temperature.add_set high

        fuzzy.add_input temperature

        // FuzzyOutput
        climate := FuzzyOutput 0

        cold := FuzzySet 0.0 10.0 10.0 20.0
        climate.add_set cold
        good := FuzzySet 10.0 20.0 30.0 40.0
        climate.add_set good
        hot := FuzzySet 30.0 40.0 40.0 50.0
        climate.add_set hot

        fuzzy.add_output climate

        // Building FuzzyRule
        if_TemperatureLow := Antecedent.set low
        then_ClimateCold := Consequent.output cold

        fuzzyRule0 := FuzzyRule 0 if_TemperatureLow then_ClimateCold
        fuzzy.add_rule fuzzyRule0

        // Building FuzzyRule
        if_TemperatureMean := Antecedent.set mean
        then_ClimateGood := Consequent.output good

        fuzzyRule1 := FuzzyRule 1 if_TemperatureMean then_ClimateGood
        fuzzy.add_rule fuzzyRule1

        // Building FuzzyRule
        if_TemperatureHigh := Antecedent.set high
        then_ClimateHot := Consequent.output cold

        fuzzyRule2 := FuzzyRule 2 if_TemperatureHigh then_ClimateHot
        fuzzy.add_rule fuzzyRule2

        expect_runs: fuzzy.set_input 0 15.0

        fuzzy.fuzzify  // was expect_runs //todo

        expect_true:  (fuzzy.is_fired 0)
        expect_true:  (fuzzy.is_fired 1)
        expect_false: (fuzzy.is_fired 2)

        expect_near 19.375 (fuzzy.defuzzify 0)

    test_end