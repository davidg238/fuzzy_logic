// Copyright (c) 2025 Ekorau LLC
// Validation and robustness tests for fuzzy logic library

import btest show *
import fuzzy-logic show *

main:
  test "Validation" "mathematical properties":
    // Test that AND operation follows mathematical properties
    fuzzySet1 := FuzzySet 0.0 10.0 20.0 30.0 "set1"
    fuzzySet2 := FuzzySet 10.0 20.0 30.0 40.0 "set2"
    fuzzySet3 := FuzzySet 20.0 30.0 40.0 50.0 "set3"
    
    fuzzySet1.max 0.7
    fuzzySet2.max 0.5
    fuzzySet3.max 0.8
    
    // Test commutativity: A AND B = B AND A
    antecedent_ab := Antecedent.AND_sets fuzzySet1 fuzzySet2
    antecedent_ba := Antecedent.AND_sets fuzzySet2 fuzzySet1
    expect_near antecedent_ab.evaluate antecedent_ba.evaluate
    
    // Test associativity: (A AND B) AND C = A AND (B AND C)
    antecedent_ab_c := Antecedent.AND_ante_set antecedent_ab fuzzySet3
    antecedent_bc := Antecedent.AND_sets fuzzySet2 fuzzySet3
    antecedent_a_bc := Antecedent.AND_set_ante fuzzySet1 antecedent_bc
    expect_near antecedent_ab_c.evaluate antecedent_a_bc.evaluate
    
    // Test OR commutativity: A OR B = B OR A
    or_antecedent_ab := Antecedent.OR_sets fuzzySet1 fuzzySet2
    or_antecedent_ba := Antecedent.OR_sets fuzzySet2 fuzzySet1
    expect_near or_antecedent_ab.evaluate or_antecedent_ba.evaluate
    
    // Test De Morgan's laws approximation
    // NOT(A AND B) ≈ (NOT A) OR (NOT B)
    // Using complement (1 - x) for NOT operation
    not_and := 1.0 - antecedent_ab.evaluate
    not_a := 1.0 - fuzzySet1.pertinence
    not_b := 1.0 - fuzzySet2.pertinence
    not_a_or_not_b := math.max not_a not_b
    
    // Should be approximately equal (within tolerance)
    expect_true (math.abs (not_and - not_a_or_not_b)) < 0.1

  test "Validation" "set type consistency":
    // Test that set types are correctly identified
    triangular := FuzzySet 0.0 10.0 10.0 20.0 "triangular"
    expect_true triangular is TriangularSet
    
    trapezoidal := FuzzySet 0.0 10.0 20.0 30.0 "trapezoidal"
    expect_true trapezoidal is TrapezoidalSet
    
    left_trapezoidal := FuzzySet 0.0 0.0 10.0 20.0 "left_trap"
    expect_true left_trapezoidal is LTrapezoidalSet
    
    right_trapezoidal := FuzzySet 0.0 10.0 20.0 20.0 "right_trap"
    expect_true right_trapezoidal is RTrapezoidalSet
    
    // Test edge case - all points same (should be treated as point set)
    point_set := FuzzySet 10.0 10.0 10.0 10.0 "point"
    // Should have some defined behavior for point sets

  test "Validation" "pertinence calculation accuracy":
    // Test precise pertinence calculations for known points
    triangular := FuzzySet 0.0 10.0 10.0 20.0 "precise_tri"
    
    // Test exact points
    triangular.set_pertinence 0.0
    expect_near 0.0 triangular.pertinence
    
    triangular.set_pertinence 10.0
    expect_near 1.0 triangular.pertinence
    
    triangular.set_pertinence 20.0
    expect_near 0.0 triangular.pertinence
    
    // Test interpolated points
    triangular.set_pertinence 5.0
    expect_near 0.5 triangular.pertinence
    
    triangular.set_pertinence 15.0
    expect_near 0.5 triangular.pertinence
    
    triangular.set_pertinence 7.5
    expect_near 0.75 triangular.pertinence
    
    triangular.set_pertinence 17.5
    expect_near 0.25 triangular.pertinence

  test "Validation" "centroid calculation accuracy":
    composition := Composition
    
    // Test simple triangular set centroid
    tri := FuzzySet 0.0 10.0 10.0 20.0 "triangle"
    tri.max 1.0
    composition.union tri.truncated tri.name
    
    // Mathematical centroid of triangle (0,0)-(10,1)-(20,0) should be 10.0
    expect_near 10.0 composition.centroid_x
    
    composition.clear
    
    // Test trapezoidal set centroid  
    trap := FuzzySet 0.0 10.0 20.0 30.0 "trapezoid"
    trap.max 1.0
    composition.union trap.truncated trap.name
    
    // Mathematical centroid of trapezoid should be 15.0
    expect_near 15.0 composition.centroid_x

  test "Robustness" "concurrent access simulation":
    // Simulate concurrent access to fuzzy model
    fuzzy := FuzzyModel "concurrent_test"
    
    // Set up a simple model
    input := FuzzyInput "shared_input"
    set1 := FuzzySet 0.0 25.0 50.0 75.0 "input_set"
    input.add_set set1
    fuzzy.add_input input
    
    output := FuzzyOutput "shared_output"
    out_set := FuzzySet 0.0 25.0 75.0 100.0 "output_set"
    output.add_set out_set
    fuzzy.add_output output
    
    rule := FuzzyRule (Antecedent.fl_set set1) (Consequent.output out_set)
    fuzzy.add_rule rule
    
    // Simulate rapid successive calls (as if from multiple threads)
    previous_result := null
    for i := 0; i < 100; i++:
      input_val := (i % 100).to_float
      fuzzy.crisp_input 0 input_val
      fuzzy.fuzzify
      result := fuzzy.defuzzify 0
      
      // Results should be consistent and deterministic
      if previous_result != null and input_val == ((i-1) % 100).to_float:
        expect_near previous_result result
      
      previous_result = result
      expect_true result >= 0.0
      expect_true result <= 100.0

  test "Robustness" "memory management":
    // Test creation and destruction of many objects
    models := []
    
    for i := 0; i < 50; i++:
      model := FuzzyModel "temp_model_$i"
      
      input := FuzzyInput "temp_input_$i"
      set := FuzzySet (i.to_float) (i.to_float + 10.0) (i.to_float + 20.0) (i.to_float + 30.0) "temp_set_$i"
      input.add_set set
      model.add_input input
      
      output := FuzzyOutput "temp_output_$i"
      out_set := FuzzySet 0.0 50.0 100.0 100.0 "temp_out_$i"
      output.add_set out_set
      model.add_output output
      
      rule := FuzzyRule (Antecedent.fl_set set) (Consequent.output out_set)
      model.add_rule rule
      
      models.add model
    
    // Test all models work
    models.do_with_index: | model, i |
      model.crisp_input 0 (i.to_float + 15.0)
      model.fuzzify
      result := model.defuzzify 0
      expect_true result >= 0.0
    
    // Clear references to allow garbage collection
    models.clear

  test "Robustness" "numeric stability":
    // Test with very small and very large numbers
    small_set := FuzzySet 1e-10 1e-9 1e-8 1e-7 "tiny"
    small_set.set_pertinence 1e-9
    expect_true small_set.pertinence >= 0.0
    expect_true small_set.pertinence <= 1.0
    
    large_set := FuzzySet 1e6 1e7 1e8 1e9 "huge"
    large_set.set_pertinence 5e7
    expect_true large_set.pertinence >= 0.0
    expect_true large_set.pertinence <= 1.0
    
    // Test with numbers close to machine precision
    precision_set := FuzzySet 0.0000001 0.0000002 0.0000003 0.0000004 "precision"
    precision_set.set_pertinence 0.00000025
    expect_true precision_set.pertinence >= 0.0
    expect_true precision_set.pertinence <= 1.0

  test "Validation" "rule firing consistency":
    // Test that rules fire consistently under same conditions
    fuzzy := FuzzyModel "consistency_test"
    
    input := FuzzyInput "test_input"
    low := FuzzySet 0.0 0.0 25.0 50.0 "low"
    high := FuzzySet 50.0 75.0 100.0 100.0 "high"
    input.add_set low
    input.add_set high
    fuzzy.add_input input
    
    output := FuzzyOutput "test_output"
    result_low := FuzzySet 0.0 0.0 30.0 60.0 "result_low"
    result_high := FuzzySet 40.0 70.0 100.0 100.0 "result_high"
    output.add_set result_low
    output.add_set result_high
    fuzzy.add_output output
    
    rule1 := FuzzyRule (Antecedent.fl_set low) (Consequent.output result_low)
    rule2 := FuzzyRule (Antecedent.fl_set high) (Consequent.output result_high)
    fuzzy.add_rule rule1
    fuzzy.add_rule rule2
    
    // Test same input multiple times
    test_input := 25.0
    results := []
    
    for i := 0; i < 10; i++:
      fuzzy.crisp_input 0 test_input
      fuzzy.fuzzify
      result := fuzzy.defuzzify 0
      results.add result
      
      // Check rule firing consistency
      expect_true fuzzy.is_fired 0  // Rule 1 should fire for input 25.0
      expect_false fuzzy.is_fired 1  // Rule 2 should not fire for input 25.0
    
    // All results should be identical
    first_result := results[0]
    results.do: | result |
      expect_near first_result result

  test-end