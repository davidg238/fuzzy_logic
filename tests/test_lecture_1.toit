
import btest show *

import fuzzy-logic show *

// ##### Tests from explanation Fuzzy System

// From: https://www.massey.ac.nz/~nhreyes/MASSEY/159741/Lectures/Lec2012-3-159741-FuzzyLogic-v.2.pdf

main:
  test-start
  test "Fuzzy" "testFromLectureSystemsOne":
    fuzzy := FuzzyModel

    // FuzzyInputs
    smallSize := FuzzySet 0.0 0.0 0.0 10.0
    largeSize := FuzzySet 0.0 10.0 10.0 10.0
    size := FuzzyInput.sets [smallSize, largeSize] --name="size"
    fuzzy.add-input size

    smallWeight := FuzzySet 0.0 0.0 0.0 100.0
    largeWeight := FuzzySet 0.0 100.0 100.0 100.0
    weight := FuzzyInput.sets [smallWeight, largeWeight] --name="weight"
    fuzzy.add-input weight

    // FuzzyOutput

    bad := FuzzySet 0.0 0.0 0.0 0.5
    medium := FuzzySet 0.0 0.5 0.5 1.0
    good := FuzzySet 0.5 1.0 1.0 1.0
    quality := FuzzyOutput.sets [bad, medium, good] --name="quality"
    fuzzy.add-output quality

    // Building FuzzyRule
    ante1 := (Antecedent.fl-and smallSize smallWeight)
    ante2 := (Antecedent.fl-and smallSize largeWeight)
    ante3 := (Antecedent.fl-and largeSize smallWeight)
    ante4 := (Antecedent.fl-and largeSize largeWeight)

    fuzzyRule0 := FuzzyRule.fl-if ante1 --fl-then=(Consequent.output bad)
    fuzzyRule1 := FuzzyRule.fl-if ante2 --fl-then=(Consequent.output medium)
    fuzzyRule2 := FuzzyRule.fl-if ante3 --fl-then=(Consequent.output medium)
    fuzzyRule3 := FuzzyRule.fl-if ante4 --fl-then=(Consequent.output good)

    fuzzy.add-rule fuzzyRule0
    fuzzy.add-rule fuzzyRule1
    fuzzy.add-rule fuzzyRule2
    fuzzy.add-rule fuzzyRule3

    fuzzy.crisp-input 0 2.0
    fuzzy.crisp-input 1 25.0
    fuzzy.changed
    fuzzy.fuzzify

    expect-near 0.75 ante1.term-eval
    expect-near 0.25 ante2.term-eval
    expect-near 0.2 ante3.term-eval
    expect-near 0.2 ante4.term-eval

    expect-near 0.4051688 (fuzzy.defuzzify 0) // 0.3698 on the paper

  test-end