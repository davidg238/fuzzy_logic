// Copyright (c) 2025 Ekorau LLC
// Additional edge case and boundary tests for fuzzy logic library

import btest show *
import fuzzy-logic show *

main:
  test "FuzzySet" "boundary values":
    // Test with extreme values
    fuzzySet := FuzzySet 0.0 0.0 0.0 0.0 "point_set"
    fuzzySet.set_pertinence 0.0
    expect_near 1.0 fuzzySet.pertinence  // Point set should have pertinence 1.0 at the point
    
    // Test with negative values
    negativeSet := FuzzySet -10.0 -5.0 5.0 10.0 "negative_set"
    negativeSet.set_pertinence -7.5
    expect_near 0.5 negativeSet.pertinence
    
    // Test with very large values
    largeSet := FuzzySet 1000.0 2000.0 3000.0 4000.0 "large_set"
    largeSet.set_pertinence 2500.0
    expect_near 0.5 largeSet.pertinence

  test "FuzzySet" "invalid parameter handling":
    // Test with reversed parameters (should handle gracefully)
    try:
      invalidSet := FuzzySet 10.0 5.0 15.0 20.0 "invalid"
      // Should either throw or auto-correct
    catch e:
      // Expected behavior - invalid parameters should be caught

  test "FuzzyInput" "empty sets":
    fuzzyInput := FuzzyInput "empty_input"
    // Test with no sets added
    fuzzyInput.crisp_in = 5.0
    expect_runs: fuzzyInput.calculate_set_pertinences

  test "FuzzyInput" "extreme crisp values":
    fuzzyInput := FuzzyInput "extreme_input"
    fuzzySet := FuzzySet 0.0 10.0 20.0 30.0 "normal_set"
    fuzzyInput.add_set fuzzySet
    
    // Test with value far below range
    fuzzyInput.crisp_in = -1000.0
    expect_runs: fuzzyInput.calculate_set_pertinences
    expect_near 0.0 fuzzySet.pertinence
    
    // Test with value far above range
    fuzzyInput.crisp_in = 1000.0
    expect_runs: fuzzyInput.calculate_set_pertinences
    expect_near 0.0 fuzzySet.pertinence

  test "Composition" "empty composition":
    composition := Composition
    // Test centroid calculation with empty composition
    expect_near 0.0 composition.centroid_x
    expect_equals 0 composition.size

  test "Composition" "single point composition":
    composition := Composition
    singlePoint := FuzzySet 5.0 5.0 5.0 5.0 "point"
    singlePoint.max 1.0
    composition.union singlePoint.truncated singlePoint.name
    expect_near 5.0 composition.centroid_x

  test "Antecedent" "zero pertinence values":
    fuzzySet1 := FuzzySet 0.0 10.0 20.0 30.0 "set1"
    fuzzySet2 := FuzzySet 10.0 20.0 30.0 40.0 "set2"
    fuzzySet1.max 0.0
    fuzzySet2.max 0.0
    
    andAntecedent := Antecedent.AND_sets fuzzySet1 fuzzySet2
    expect_near 0.0 andAntecedent.evaluate
    
    orAntecedent := Antecedent.OR_sets fuzzySet1 fuzzySet2
    expect_near 0.0 orAntecedent.evaluate

  test "FuzzyModel" "no rules model":
    fuzzy := FuzzyModel "empty_model"
    
    // Add input and output but no rules
    input := FuzzyInput "test_input"
    set1 := FuzzySet 0.0 10.0 20.0 30.0 "input_set"
    input.add_set set1
    fuzzy.add_input input
    
    output := FuzzyOutput "test_output"
    set2 := FuzzySet 0.0 10.0 20.0 30.0 "output_set"
    output.add_set set2
    fuzzy.add_output output
    
    fuzzy.crisp_input 0 15.0
    fuzzy.fuzzify
    
    // Should handle gracefully with no rules
    result := fuzzy.defuzzify 0
    // Result should be meaningful (likely 0 or center of output range)

  test-end