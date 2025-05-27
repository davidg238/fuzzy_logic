
import btest show *

import fuzzy-logic show *

// ##### Tests from explanation Fuzzy System

// From: https://www.massey.ac.nz/~nhreyes/MASSEY/159741/Lectures/Lec2012-3-159741-FuzzyLogic-v.2.pdf

main:
  test-start
  test "Fuzzy" "testFromLectureSystemsOne":
    fuzzy := FuzzyModel

    // FuzzyInput
    size := FuzzyInput "size"

    smallSize := FuzzySet 0.0 0.0 0.0 10.0
    size.add-set smallSize
    largeSize := FuzzySet 0.0 10.0 10.0 10.0
    size.add-set largeSize

    fuzzy.add-input size

    // FuzzyInput
    weight := FuzzyInput "weight"

    smallWeight := FuzzySet 0.0 0.0 0.0 100.0
    weight.add-set smallWeight
    largeWeight := FuzzySet 0.0 100.0 100.0 100.0
    weight.add-set largeWeight

    fuzzy.add-input weight

    // FuzzyOutput
    quality := FuzzyOutput "quality"

    bad := FuzzySet 0.0 0.0 0.0 0.5
    quality.add-set bad
    medium := FuzzySet 0.0 0.5 0.5 1.0
    quality.add-set medium
    good := FuzzySet 0.5 1.0 1.0 1.0
    quality.add-set good

    fuzzy.add-output quality

    // Building FuzzyRule
    if-SizeSmallAndWeightSmall := Antecedent-And smallSize smallWeight
    then-QualityBad := Consequent.output bad
    
    fuzzyRule0 := FuzzyRule.fl-if if-SizeSmallAndWeightSmall --fl-then=then-QualityBad
    fuzzy.add-rule fuzzyRule0

    // Building FuzzyRule
    if-SizeSmallAndWeightLarge := Antecedent-And smallSize largeWeight
    then-QualityMedium1 := Consequent.output medium
    fuzzyRule1 := FuzzyRule.fl-if if-SizeSmallAndWeightLarge --fl-then=then-QualityMedium1
    fuzzy.add-rule fuzzyRule1

    // Building FuzzyRule
    if-SizeLargeAndWeightSmall := Antecedent-And largeSize smallWeight
    then-QualityMedium2 := Consequent.output medium
    fuzzyRule2 := FuzzyRule.fl-if if-SizeLargeAndWeightSmall --fl-then=then-QualityMedium2
    fuzzy.add-rule fuzzyRule2

    // Building FuzzyRule
    if-SizeLargeAndWeightLarge := Antecedent-And largeSize largeWeight
    then-QualityGood := Consequent.output good
    fuzzyRule3 := FuzzyRule.fl-if if-SizeLargeAndWeightLarge --fl-then=then-QualityGood
    fuzzy.add-rule fuzzyRule3

    print "run it"
    fuzzy.crisp-input 0 2.0
    fuzzy.crisp-input 1 25.0
    fuzzy.changed
    fuzzy.fuzzify
    print "got to here"
    expect-near 0.75 if-SizeSmallAndWeightSmall.term-eval
    expect-near 0.25 if-SizeSmallAndWeightLarge.term-eval
    expect-near 0.2 if-SizeLargeAndWeightSmall.term-eval
    expect-near 0.2 if-SizeLargeAndWeightLarge.term-eval

    expect-near 0.37692466 (fuzzy.defuzzify 0) // 0.3698 on the paper
    print "... all done"
  test-end