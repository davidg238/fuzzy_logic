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

import set_triangular show TriangularSet
import set_trapezoidal show TrapezoidalSet
import set_trapezoidal_l show LTrapezoidalSet
import set_trapezoidal_r show RTrapezoidalSet

import expect show *

main:

    TEST_START

/// Test FuzzySet

    TEST "FuzzySet" "getPoints":

        fuzzySet := FuzzySet 0.0 10.0 20.0 30.0 "set"
        ASSERT_FLOAT_EQ 0.0 fuzzySet.a
        ASSERT_FLOAT_EQ 10.0 fuzzySet.b
        ASSERT_FLOAT_EQ 20.0 fuzzySet.c
        ASSERT_FLOAT_EQ 30.0 fuzzySet.d

    TEST "FuzzySet" "calculateAndGetPertinence":

        fuzzySet1 := FuzzySet 0.0 10.0 10.0 20.0 "set1"

        ASSERT_TRUE fuzzySet1 is TriangularSet

        fuzzySet1.calculate_pertinence -5.0
        ASSERT_FLOAT_EQ 0.0 fuzzySet1.pertinence

        fuzzySet1.calculate_pertinence 5.0
        ASSERT_FLOAT_EQ 0.5 fuzzySet1.pertinence

        fuzzySet1.calculate_pertinence 10.0
        ASSERT_FLOAT_EQ 1.0 fuzzySet1.pertinence

        fuzzySet1.calculate_pertinence 15.0
        ASSERT_FLOAT_EQ 0.5 fuzzySet1.pertinence
        // expect_equals 0.4 fuzzySet1.pertinence  //usage of expect methods?

        fuzzySet1.calculate_pertinence 25.0
        ASSERT_FLOAT_EQ 0.0 fuzzySet1.pertinence

        fuzzySet2 := FuzzySet  0.0 0.0 20.0 30.0

        ASSERT_TRUE fuzzySet2 is LTrapezoidalSet

        fuzzySet2.calculate_pertinence -5.0
        ASSERT_FLOAT_EQ 1.0 fuzzySet2.pertinence

        fuzzySet3 := FuzzySet 0.0 10.0 20.0 20.0

        ASSERT_TRUE fuzzySet3 is RTrapezoidalSet

        fuzzySet3.calculate_pertinence 25.0
        ASSERT_FLOAT_EQ 1.0 fuzzySet3.pertinence


    TEST "FuzzyInput" "addFuzzySet":
        fuzzyInput := FuzzyInput 0
        fuzzySet := FuzzySet 0.0 10.0 10.0 20.0

        ASSERT_TRUE fuzzySet is TriangularSet

        ASSERT_RUNS: // deleted bool return of C functions, since in usual code, unchecked?
            fuzzyInput.add_set fuzzySet

    TEST "FuzzyInput" "setCrispInputAndGetCrispInput":

        fuzzyInput := FuzzyInput 1;
        fuzzyInput.crisp_in = 10.190
        ASSERT_FLOAT_EQ 10.190 fuzzyInput.crisp_in


    TEST "FuzzyInput" "calculateFuzzySetPertinences":

        fuzzyInput := FuzzyInput 0
        fuzzySet1 := FuzzySet 0.0 10.0 10.0 20.0 "set1"
        fuzzyInput.add_set fuzzySet1
        fuzzySet2 := FuzzySet 10.0 20.0 20.0 30.0 "set2"

        ASSERT_TRUE fuzzySet2 is TriangularSet
        fuzzyInput.add_set fuzzySet2
        fuzzyInput.crisp_in = 5.0

        ASSERT_RUNS: fuzzyInput.calculate_set_pertinences

        ASSERT_FLOAT_EQ 0.5 fuzzySet1.pertinence
        ASSERT_FLOAT_EQ 0.0 fuzzySet2.pertinence


    TEST "Composition" "addPointAndCheckPoint":
        composition := Composition 

        ASSERT_RUNS: composition.add_point 1.0 0.1
        ASSERT_TRUE  (composition.any_point 1.0 0.1)

        ASSERT_RUNS: composition.add_point 5.0 0.5
        ASSERT_TRUE  (composition.any_point 5.0 0.5)

        ASSERT_RUNS: composition.add_point 9.0 0.9
        ASSERT_TRUE  (composition.any_point 9.0 0.9)

        ASSERT_FALSE (composition.any_point 5.0 0.1)


    TEST "Composition" "build":
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

        ASSERT_RUNS: composition.simplify

        //print "composition: $composition"

        ASSERT_TRUE (composition.any_point 0.0 0.0)
        ASSERT_TRUE (composition.any_point 10.0 1.0)
        ASSERT_FALSE (composition.any_point 20.0 0.0)
        ASSERT_TRUE (composition.any_point 15.0 0.5)
        ASSERT_FALSE (composition.any_point 10.0 0.0)
        ASSERT_TRUE (composition.any_point 20.0 1.0)
        ASSERT_TRUE (composition.any_point 30.0 0.0)

    TEST "Composition" "calculateAndEmptyAndCountPoints":
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
        ASSERT_RUNS: composition.simplify
        ASSERT_EQ 2 composition.size // size should be 2, not 3 ? ... check original
        ASSERT_FLOAT_EQ 25.0 composition.calculate_centroid
        ASSERT_RUNS: composition.clear


        tri := FuzzySet 10.0 20.0 20.0 30.0
        tri.pertinence 1.0
        composition.union tri.truncated
        // print "tri composition: $composition"
/*
        composition.add_point 10.0 0.0
        composition.add_point 20.0 1.0
        composition.add_point 30.0 0.0
*/        
        ASSERT_RUNS: composition.simplify
        ASSERT_EQ 3 composition.size
        ASSERT_FLOAT_EQ 20.0 composition.calculate_centroid
        ASSERT_RUNS: composition.clear

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
        ASSERT_RUNS: composition.simplify
        ASSERT_EQ 4 composition.size
        ASSERT_FLOAT_EQ 40.0 composition.calculate_centroid
        ASSERT_RUNS: composition.clear

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
        ASSERT_RUNS: composition.simplify
        ASSERT_EQ 7 composition.size
        ASSERT_FLOAT_EQ 20.0 composition.calculate_centroid
*/
    TEST "FuzzyOutput" "getIndex":
        fuzzyOutput := FuzzyOutput 0
        ASSERT_EQ 0 fuzzyOutput.index  //check original cpp, used 0 index


    TEST "FuzzyOutput" "setCrispInputAndGetCrispInput":
        fuzzyOutput := FuzzyOutput 0
        fuzzyOutput.crisp_in = 10.190
        ASSERT_FLOAT_EQ 10.190 fuzzyOutput.crisp_in


    TEST "FuzzyOutput" "addFuzzySetAndResetFuzzySets":
        fuzzyOutput := FuzzyOutput 0
        fuzzySetTest := FuzzySet 0.0 10.0 10.0 20.0

        ASSERT_RUNS: fuzzyOutput.add_set fuzzySetTest

        fuzzySetTest.pertinence 0.242
        ASSERT_FLOAT_EQ 0.242 fuzzySetTest.pertinence

        fuzzyOutput.reset_sets

        ASSERT_FLOAT_EQ 0.0 fuzzySetTest.pertinence


    TEST "FuzzyOutput" "truncateAndGetCrispOutputAndGetFuzzyComposition":
        fuzzyOutput := FuzzyOutput 0

        ASSERT_EQ 0 fuzzyOutput.index

        fuzzySetTest0 := FuzzySet 0.0 10.0 10.0 20.0 "set0"
        ASSERT_TRUE fuzzySetTest0 is TriangularSet
        fuzzySetTest0.pertinence 1.0
        fuzzyOutput.add_set fuzzySetTest0

        fuzzySetTest1 := FuzzySet 10.0 20.0 20.0 30.0
        ASSERT_TRUE fuzzySetTest1 is TriangularSet
        fuzzySetTest1.pertinence 1.0
        fuzzyOutput.add_set fuzzySetTest1

        fuzzySetTest2 := FuzzySet 20.0 30.0 30.0 40.0 "set2"
        ASSERT_TRUE fuzzySetTest2 is TriangularSet
        fuzzySetTest2.pertinence 1.0
        fuzzyOutput.add_set fuzzySetTest2

        ASSERT_RUNS : fuzzyOutput.truncate

        fuzzyComposition := fuzzyOutput.composition

        ASSERT_NOT_NULL fuzzyComposition

        ASSERT_EQ 7 fuzzyComposition.size //todo, original .cpp test shows 8 ... pen&paper looks 7

        ASSERT_TRUE (fuzzyComposition.any_point 0.0 0.0)
        ASSERT_TRUE (fuzzyComposition.any_point 10.0 1.0)
        ASSERT_FALSE (fuzzyComposition.any_point 20.0 0.0)

        ASSERT_TRUE (fuzzyComposition.any_point 15.0 0.5)

        ASSERT_FALSE (fuzzyComposition.any_point 10.0 0.0)
        ASSERT_TRUE (fuzzyComposition.any_point 20.0 1.0)
        ASSERT_FALSE (fuzzyComposition.any_point 30.0 0.0)

        ASSERT_TRUE (fuzzyComposition.any_point 25.0 0.5)

        ASSERT_FALSE (fuzzyComposition.any_point 20.0 0.0)
        ASSERT_TRUE (fuzzyComposition.any_point 30.0 1.0)
        ASSERT_TRUE (fuzzyComposition.any_point 40.0 0.0)

        ASSERT_FLOAT_EQ 20.0 fuzzyOutput.crisp_out


    TEST "Antecedent" "joinSingleAndEvaluate":
        antecedent := null

        fuzzySet := FuzzySet 0.0 10.0 10.0 20.0
        fuzzySet.pertinence 0.25

        ASSERT_RUNS: antecedent = Antecedent.join_set fuzzySet
        ASSERT_FLOAT_EQ 0.25 antecedent.evaluate     


    TEST "Antecedent" "joinTwoFuzzySetAndEvaluate":

        fuzzySet1 := FuzzySet 0.0 10.0 10.0 20.0
        fuzzySet1.pertinence 0.25
        fuzzySet2 := FuzzySet 10.0 20.0 20.0 30.0
        fuzzySet2.pertinence 0.75

        antecedent1 := null
        ASSERT_RUNS:
            antecedent1 = Antecedent.join_sets_AND fuzzySet1 fuzzySet2
        ASSERT_FLOAT_EQ 0.25 antecedent1.evaluate   

        antecedent2 := null
        ASSERT_RUNS: antecedent2 = Antecedent.join_sets_OR fuzzySet1 fuzzySet2
        ASSERT_FLOAT_EQ 0.75 antecedent2.evaluate   


    TEST "Antecedent" "joinOneFuzzySetAndOneFuzzyAntecedentAndEvaluate":
        fuzzySet1 := FuzzySet 0.0 10.0 10.0 20.0
        fuzzySet1.pertinence 0.25

        fuzzySet2 := FuzzySet 10.0 20.0 20.0 30.0
        fuzzySet2.pertinence 0.75
        antecedent1 := Antecedent.join_set fuzzySet2

        antecedent2 := Antecedent.join_set_ante_AND fuzzySet1 antecedent1
        ASSERT_FLOAT_EQ 0.25 antecedent2.evaluate

        antecedent3 := Antecedent.join_ante_set_AND antecedent1 fuzzySet1
        ASSERT_FLOAT_EQ 0.25 antecedent3.evaluate    //4

        antecedent4 := Antecedent.join_set_ante_OR fuzzySet1 antecedent1
        ASSERT_FLOAT_EQ 0.75 antecedent4.evaluate    

        antecedent5 := Antecedent.join_ante_set_OR antecedent1 fuzzySet1
        ASSERT_FLOAT_EQ 0.75 antecedent5.evaluate    //8


    TEST "Antecedent" "joinTwoFuzzyAntecedentAndEvaluate":
        fuzzySet1 := FuzzySet  0.0 10.0 10.0 20.0 "set1"
        fuzzySet1.pertinence 0.25
        antecedent1 := Antecedent.join_set fuzzySet1

        fuzzySet2 := FuzzySet  10.0 20.0 20.0 30.0 "set2"
        fuzzySet2.pertinence 0.75
        fuzzySet3 := FuzzySet  30.0 40.0 40.0 50.0 "set3"
        fuzzySet3.pertinence 0.5
        antecedent2 := Antecedent.join_sets_OR fuzzySet2 fuzzySet3

        antecedent3 := null
        ASSERT_RUNS: antecedent3 = Antecedent.join_ante_ante_AND antecedent1 antecedent2

        ASSERT_FLOAT_EQ 0.25 antecedent3.evaluate    
        antecedent4 := null
        ASSERT_RUNS: antecedent4 = Antecedent.join_ante_ante_OR antecedent1 antecedent2

        ASSERT_FLOAT_EQ 0.75 antecedent4.evaluate    


    TEST "Consequent" "addOutputAndEvaluate":
        fuzzySet1 := FuzzySet 0.0 10.0 10.0 20.0 "set1"
        fuzzySet2 := FuzzySet 10.0 20.0 20.0 30.0 "set2"

        fuzzyRuleConsequent := null
        ASSERT_RUNS: fuzzyRuleConsequent = Consequent.output fuzzySet1

        fuzzyRuleConsequent.add_output fuzzySet2

        ASSERT_RUNS: fuzzyRuleConsequent.evaluate 0.5

        ASSERT_FLOAT_EQ 0.5 fuzzySet1.pertinence
        ASSERT_FLOAT_EQ 0.5 fuzzySet2.pertinence


    TEST "FuzzyRule" "getIndexAndEvaluateExpressionAndIsFired":
        fuzzySet := FuzzySet 0.0 10.0 10.0 20.0
        fuzzySet.pertinence 0.75
        antecedent1 := Antecedent.join_set fuzzySet

        fuzzySet2 := FuzzySet 0.0 10.0 10.0 20.0
        fuzzySet2.pertinence 0.25
        antecedent2 := Antecedent.join_set fuzzySet2

        antecedent3 := Antecedent.join_ante_ante_AND antecedent1 antecedent2

        fuzzySet3 := FuzzySet 0.0 10.0 10.0 20.0
        fuzzyRuleConsequent := Consequent.output fuzzySet3

        fuzzyRule := FuzzyRule 1 antecedent3 fuzzyRuleConsequent

        ASSERT_EQ 1 fuzzyRule.index
        ASSERT_FALSE fuzzyRule.fired

        ASSERT_TRUE fuzzyRule.evaluate

        ASSERT_TRUE fuzzyRule.fired

    TEST "FuzzyModel" "addFuzzyInput":

        fuzzy := FuzzyModel
        fuzzyInput := FuzzyInput 0

        fuzzySet0 := FuzzySet 0.0 10.0 10.0 20.0
        fuzzyInput.add_set fuzzySet0
        fuzzySet1 := FuzzySet 10.0 20.0 20.0 30.0
        fuzzyInput.add_set fuzzySet1
        fuzzySet2 := FuzzySet 20.0 30.0 30.0 40.0
        fuzzyInput.add_set fuzzySet2

        ASSERT_RUNS: fuzzy.add_input fuzzyInput


    TEST "FuzzyModel" "addFuzzyOutput":
        fuzzy := FuzzyModel

        fuzzyOutput := FuzzyOutput 0

        fuzzySet0 := FuzzySet 0.0 10.0 10.0 20.0
        fuzzyOutput.add_set fuzzySet0
        fuzzySet1 := FuzzySet 10.0 20.0 20.0 30.0
        fuzzyOutput.add_set fuzzySet1
        fuzzySet2 := FuzzySet 20.0 30.0 30.0 40.0
        fuzzyOutput.add_set fuzzySet2

        ASSERT_RUNS: fuzzy.add_output fuzzyOutput

    TEST "FuzzyModel" "addFuzzyRule":

        fuzzy := FuzzyModel

        fuzzySet0 := FuzzySet 0.0 10.0 10.0 20.0
        fuzzySet0.pertinence 0.25
        antecedent0 := Antecedent.join_set fuzzySet0

        fuzzySet1 := FuzzySet 0.0 10.0 10.0 20.0
        fuzzySet1.pertinence 0.75
        antecedent1 := Antecedent.join_set fuzzySet1
        
        antecedent2 := Antecedent.join_ante_ante_AND antecedent0 antecedent1
        fuzzySet2 := FuzzySet 0.0 10.0 10.0 20.0
        fuzzyRuleConsequent := Consequent.output fuzzySet2

        fuzzyRule := FuzzyRule 0 antecedent2 fuzzyRuleConsequent

        ASSERT_RUNS: fuzzy.add_rule fuzzyRule

    TEST "FuzzyModel" "setInputAndFuzzifyAndIsFiredRuleAndDefuzzify":
        fuzzy := FuzzyModel

        // FuzzyInput
        temperature := FuzzyInput 0

        low := FuzzySet 0.0 10.0 10.0 20.0
        temperature.add_set low
        mean := FuzzySet 10.0 20.0 30.0 40.0
        ASSERT_TRUE mean is TrapezoidalSet
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

        fuzzy.fuzzify  // was ASSERT_RUNS //todo

        ASSERT_TRUE  (fuzzy.is_fired 0)
        ASSERT_TRUE  (fuzzy.is_fired 1)
        ASSERT_FALSE (fuzzy.is_fired 2)

        ASSERT_FLOAT_EQ 19.375 (fuzzy.defuzzify 0)

    TEST_END