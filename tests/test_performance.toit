// Copyright (c) 2025 Ekorau LLC
// Performance and stress tests for fuzzy logic library

import btest show *
import fuzzy-logic show *

main:
  test "Performance" "large number of sets":
    fuzzyInput := FuzzyInput "stress_input"
    
    // Add many overlapping triangular sets
    for i := 0; i < 100; i++:
      start := i.to_float * 2.0
      peak := start + 5.0
      end := start + 10.0
      fuzzySet := FuzzySet start peak peak end "set_$i"
      fuzzyInput.add_set fuzzySet
    
    // Test performance of pertinence calculation
    start_time := Time.monotonic_us
    fuzzyInput.crisp_in = 50.0
    fuzzyInput.calculate_set_pertinences
    end_time := Time.monotonic_us
    
    duration_ms := (end_time - start_time) / 1000.0
    print "Calculated pertinence for 100 sets in $(%.2f duration_ms)ms"
    
    // Verify some sets have non-zero pertinence
    non_zero_count := 0
    for i := 0; i < 100; i++:
      if fuzzyInput.sets[i].pertinence > 0.0:
        non_zero_count++
    
    expect_true non_zero_count > 0

  test "Performance" "complex rule evaluation":
    fuzzy := FuzzyModel "stress_model"
    
    // Create multiple inputs with multiple sets each
    for input_idx := 0; input_idx < 5; input_idx++:
      input := FuzzyInput "input_$input_idx"
      for set_idx := 0; set_idx < 10; set_idx++:
        start := set_idx.to_float * 10.0
        peak := start + 5.0
        end := start + 10.0
        fuzzySet := FuzzySet start peak peak end "set_$(input_idx)_$(set_idx)"
        input.add_set fuzzySet
      fuzzy.add_input input
    
    // Create output
    output := FuzzyOutput "stress_output"
    for set_idx := 0; set_idx < 20; set_idx++:
      start := set_idx.to_float * 5.0
      peak := start + 2.5
      end := start + 5.0
      fuzzySet := FuzzySet start peak peak end "out_set_$set_idx"
      output.add_set fuzzySet
    fuzzy.add_output output
    
    // Create many rules (combinations of input sets)
    rule_count := 0
    for i1 := 0; i1 < 5; i1++:
      for i2 := 0; i2 < 5; i2++:
        for i3 := 0; i3 < 5; i3++:
          if rule_count >= 50: break  // Limit to 50 rules
          
          // Create compound antecedent
          ante1 := Antecedent.fl_set fuzzy.inputs[0].sets[i1]
          ante2 := Antecedent.fl_set fuzzy.inputs[1].sets[i2]
          ante3 := Antecedent.fl_set fuzzy.inputs[2].sets[i3]
          
          compound := Antecedent.AND_ante_ante ante1 ante2
          compound = Antecedent.AND_ante_ante compound ante3
          
          consequent := Consequent.output output.sets[rule_count % 20]
          rule := FuzzyRule compound consequent
          fuzzy.add_rule rule
          rule_count++
    
    // Test performance of inference
    start_time := Time.monotonic_us
    
    for input_idx := 0; input_idx < 5; input_idx++:
      fuzzy.crisp_input input_idx (25.0 + input_idx * 5.0)
    
    fuzzy.fuzzify
    result := fuzzy.defuzzify 0
    
    end_time := Time.monotonic_us
    duration_ms := (end_time - start_time) / 1000.0
    
    print "Inference with 5 inputs, 50 sets, 50 rules took $(%.2f duration_ms)ms"
    print "Result: $(%.3f result)"

  test "Stress" "repeated inference cycles":
    fuzzy := FuzzyModel "cycle_test"
    
    // Simple model for repeated testing
    input := FuzzyInput "cycle_input"
    low := FuzzySet 0.0 0.0 20.0 40.0 "low"
    medium := FuzzySet 20.0 40.0 60.0 80.0 "medium"
    high := FuzzySet 60.0 80.0 100.0 100.0 "high"
    input.add_set low
    input.add_set medium
    input.add_set high
    fuzzy.add_input input
    
    output := FuzzyOutput "cycle_output"
    slow := FuzzySet 0.0 0.0 25.0 50.0 "slow"
    normal := FuzzySet 25.0 50.0 75.0 100.0 "normal"
    fast := FuzzySet 75.0 100.0 100.0 100.0 "fast"
    output.add_set slow
    output.add_set normal
    output.add_set fast
    fuzzy.add_output output
    
    // Add rules
    fuzzy.add_rule (FuzzyRule (Antecedent.fl_set low) (Consequent.output slow))
    fuzzy.add_rule (FuzzyRule (Antecedent.fl_set medium) (Consequent.output normal))
    fuzzy.add_rule (FuzzyRule (Antecedent.fl_set high) (Consequent.output fast))
    
    // Run many inference cycles
    start_time := Time.monotonic_us
    cycles := 1000
    
    for i := 0; i < cycles; i++:
      input_value := (i % 100).to_float
      fuzzy.crisp_input 0 input_value
      fuzzy.fuzzify
      result := fuzzy.defuzzify 0
      
      // Verify result is reasonable
      expect_true result >= 0.0
      expect_true result <= 100.0
    
    end_time := Time.monotonic_us
    total_duration_ms := (end_time - start_time) / 1000.0
    avg_duration_ms := total_duration_ms / cycles
    
    print "Completed $cycles inference cycles"
    print "Total time: $(%.2f total_duration_ms)ms"
    print "Average per cycle: $(%.3f avg_duration_ms)ms"

  test-end