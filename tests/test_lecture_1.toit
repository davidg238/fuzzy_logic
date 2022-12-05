
import btest show *

import fuzzy_logic show *

// ##### Tests from explanation Fuzzy System

// From: https://www.massey.ac.nz/~nhreyes/MASSEY/159741/Lectures/Lec2012-3-159741-FuzzyLogic-v.2.pdf

main:
  test_start
  test "Fuzzy" "testFromLectureSystemsOne":
    fuzzy := FuzzyModel

    // FuzzyInput
    size := FuzzyInput "size"

    smallSize := FuzzySet 0.0 0.0 0.0 10.0
    size.add_set smallSize
    largeSize := FuzzySet 0.0 10.0 10.0 10.0
    size.add_set largeSize

    fuzzy.add_input size

    // FuzzyInput
    weight := FuzzyInput "weight"

    smallWeight := FuzzySet 0.0 0.0 0.0 100.0
    weight.add_set smallWeight
    largeWeight := FuzzySet 0.0 100.0 100.0 100.0
    weight.add_set largeWeight

    fuzzy.add_input weight

    // FuzzyOutput
    quality := FuzzyOutput "quality"

    bad := FuzzySet 0.0 0.0 0.0 0.5
    quality.add_set bad
    medium := FuzzySet 0.0 0.5 0.5 1.0
    quality.add_set medium
    good := FuzzySet 0.5 1.0 1.0 1.0
    quality.add_set good

    fuzzy.add_output quality

    // Building FuzzyRule
    if_SizeSmallAndWeightSmall := Antecedent.AND_sets smallSize smallWeight
    then_QualityBad := Consequent.output bad
    
    fuzzyRule0 := FuzzyRule if_SizeSmallAndWeightSmall then_QualityBad
    fuzzy.add_rule fuzzyRule0

    // Building FuzzyRule
    if_SizeSmallAndWeightLarge := Antecedent.AND_sets smallSize largeWeight
    then_QualityMedium1 := Consequent.output medium
    fuzzyRule1 := FuzzyRule if_SizeSmallAndWeightLarge then_QualityMedium1
    fuzzy.add_rule fuzzyRule1

    // Building FuzzyRule
    if_SizeLargeAndWeightSmall := Antecedent.AND_sets largeSize smallWeight
    then_QualityMedium2 := Consequent.output medium
    fuzzyRule2 := FuzzyRule if_SizeLargeAndWeightSmall then_QualityMedium2
    fuzzy.add_rule fuzzyRule2

    // Building FuzzyRule
    if_SizeLargeAndWeightLarge := Antecedent.AND_sets largeSize largeWeight
    then_QualityGood := Consequent.output good
    fuzzyRule3 := FuzzyRule if_SizeLargeAndWeightLarge then_QualityGood
    fuzzy.add_rule fuzzyRule3

    print "run it"
    fuzzy.crisp_input 0 2.0
    fuzzy.crisp_input 1 25.0
    fuzzy.changed
    fuzzy.fuzzify
    print "got to here"
    expect_near 0.75 if_SizeSmallAndWeightSmall.evaluate
    expect_near 0.25 if_SizeSmallAndWeightLarge.evaluate
    expect_near 0.2 if_SizeLargeAndWeightSmall.evaluate
    expect_near 0.2 if_SizeLargeAndWeightLarge.evaluate

    expect_near 0.37692466 (fuzzy.defuzzify 0) // 0.3698 on the paper
    print "... all done"
  test_end