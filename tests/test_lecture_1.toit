
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


// ##### Tests from explanation Fuzzy System

// From: https://www.massey.ac.nz/~nhreyes/MASSEY/159741/Lectures/Lec2012-3-159741-FuzzyLogic-v.2.pdf

main:

    TEST_START

    TEST "Fuzzy" "testFromLectureSystemsOne":
        fuzzy := FuzzyModel

        // FuzzyInput
        size := FuzzyInput 0

        smallSize := FuzzySet 0.0 0.0 0.0 10.0
        size.add_set smallSize
        largeSize := FuzzySet 0.0 10.0 10.0 10.0
        size.add_set largeSize

        fuzzy.add_input size

        // FuzzyInput
        weight := FuzzyInput 1

        smallWeight := FuzzySet 0.0 0.0 0.0 100.0
        weight.add_set smallWeight
        largeWeight := FuzzySet 0.0 100.0 100.0 100.0
        weight.add_set largeWeight

        fuzzy.add_input weight

        // FuzzyOutput
        quality := FuzzyOutput 0

        bad := FuzzySet 0.0 0.0 0.0 0.5
        quality.add_set bad
        medium := FuzzySet 0.0 0.5 0.5 1.0
        quality.add_set medium
        good := FuzzySet 0.5 1.0 1.0 1.0
        quality.add_set good

        fuzzy.add_output quality

        // Building FuzzyRule
        if_SizeSmallAndWeightSmall := Antecedent.join_sets_AND smallSize smallWeight
        then_QualityBad := Consequent.output bad
        
        fuzzyRule0 := FuzzyRule 0 if_SizeSmallAndWeightSmall then_QualityBad
        fuzzy.add_rule fuzzyRule0

        // Building FuzzyRule
        if_SizeSmallAndWeightLarge := Antecedent.join_sets_AND smallSize largeWeight
        then_QualityMedium1 := Consequent.output medium
        fuzzyRule1 := FuzzyRule 1 if_SizeSmallAndWeightLarge then_QualityMedium1
        fuzzy.add_rule fuzzyRule1

        // Building FuzzyRule
        if_SizeLargeAndWeightSmall := Antecedent.join_sets_AND largeSize smallWeight
        then_QualityMedium2 := Consequent.output medium
        fuzzyRule2 := FuzzyRule 2 if_SizeLargeAndWeightSmall then_QualityMedium2
        fuzzy.add_rule fuzzyRule2

        // Building FuzzyRule
        if_SizeLargeAndWeightLarge := Antecedent.join_sets_AND largeSize largeWeight
        then_QualityGood := Consequent.output good
        fuzzyRule3 := FuzzyRule 3 if_SizeLargeAndWeightLarge then_QualityGood
        fuzzy.add_rule fuzzyRule3

        // run it
        fuzzy.set_input 0 2.0
        fuzzy.set_input 1 25.0
        fuzzy.fuzzify

        ASSERT_FLOAT_EQ 0.75 if_SizeSmallAndWeightSmall.evaluate
        ASSERT_FLOAT_EQ 0.25 if_SizeSmallAndWeightLarge.evaluate
        ASSERT_FLOAT_EQ 0.2 if_SizeLargeAndWeightSmall.evaluate
        ASSERT_FLOAT_EQ 0.2 if_SizeLargeAndWeightLarge.evaluate

        ASSERT_FLOAT_EQ 0.37692466 (fuzzy.defuzzify 0) // 0.3698 on the paper
    
    TEST_END