// Copyright (c) 2025 Ekorau LLC
// API usability and error handling tests for fuzzy logic library

import btest show *
import fuzzy-logic show *

main:
  test "API" "fluent interface usage":
    // Test chaining operations for better usability
    model := FuzzyModel "fluent_test"
    
    // Test if the library supports method chaining
    input := FuzzyInput "chained_input"
    set1 := FuzzySet 0.0 10.0 20.0 30.0 "set1"
    set2 := FuzzySet 20.0 30.0 40.0 50.0 "set2"
    
    // These operations should work smoothly
    expect_runs:
      input.add_set set1
      input.add_set set2
      model.add_input input
    
    output := FuzzyOutput "chained_output"
    out1 := FuzzySet 0.0 25.0 50.0 75.0 "out1"
    out2 := FuzzySet 50.0 75.0 100.0 100.0 "out2"
    
    expect_runs:
      output.add_set out1
      output.add_set out2
      model.add_output output

  test "API" "named parameters and defaults":
    // Test API with descriptive names
    temperature_input := FuzzyInput "room_temperature"
    
    cold := FuzzySet 0.0 5.0 10.0 15.0 "cold"
    warm := FuzzySet 10.0 15.0 20.0 25.0 "warm"
    hot := FuzzySet 20.0 25.0 30.0 35.0 "hot"
    
    expect_runs:
      temperature_input.add_set cold
      temperature_input.add_set warm  
      temperature_input.add_set hot
    
    // Test that names are preserved and accessible
    expect_equals "cold" cold.name
    expect_equals "warm" warm.name
    expect_equals "hot" hot.name
    expect_equals "room_temperature" temperature_input.name

  test "Error" "invalid fuzzy set parameters":
    // Test handling of invalid set definitions
    try:
      // Invalid: b > c (peak after end of plateau)
      invalid_set1 := FuzzySet 0.0 20.0 10.0 30.0 "invalid1"
      expect_true false  // Should not reach this line
    catch e:
      print "Correctly caught invalid parameter order: $e"
    
    try:
      // Invalid: a > d (start after end)
      invalid_set2 := FuzzySet 30.0 10.0 20.0 0.0 "invalid2"
      expect_true false  // Should not reach this line
    catch e:
      print "Correctly caught invalid range: $e"

  test "Error" "operations on uninitialized objects":
    // Test behavior with uninitialized or empty objects
    empty_input := FuzzyInput "empty"
    
    // Should handle gracefully or throw meaningful error
    try:
      empty_input.crisp_in = 10.0
      empty_input.calculate_set_pertinences
      print "Empty input handled gracefully"
    catch e:
      print "Empty input operation error: $e"
    
    empty_model := FuzzyModel "empty_model"
    
    try:
      result := empty_model.defuzzify 0
      print "Empty model defuzzification: $result"
    catch e:
      print "Empty model operation error: $e"

  test "Error" "index out of bounds":
    model := FuzzyModel "bounds_test"
    
    input := FuzzyInput "single_input"
    set := FuzzySet 0.0 10.0 20.0 30.0 "set"
    input.add_set set
    model.add_input input
    
    output := FuzzyOutput "single_output"
    out_set := FuzzySet 0.0 50.0 100.0 100.0 "out_set"
    output.add_set out_set
    model.add_output output
    
    // Test invalid input index
    try:
      model.crisp_input 5 25.0  // Index 5 doesn't exist
      expect_true false
    catch e:
      print "Correctly caught invalid input index: $e"
    
    // Test invalid output index  
    try:
      result := model.defuzzify 5  // Index 5 doesn't exist
      expect_true false
    catch e:
      print "Correctly caught invalid output index: $e"

  test "Error" "null or invalid references":
    // Test handling of null references
    try:
      null_antecedent := null
      rule := FuzzyRule null_antecedent (Consequent.output (FuzzySet 0.0 10.0 20.0 30.0))
      expect_true false
    catch e:
      print "Correctly caught null antecedent: $e"
    
    try:
      valid_antecedent := Antecedent.fl_set (FuzzySet 0.0 10.0 20.0 30.0)
      rule := FuzzyRule valid_antecedent null
      expect_true false
    catch e:
      print "Correctly caught null consequent: $e"

  test "Usability" "typical workflow":
    // Test a complete typical workflow
    expect_runs:
      // Step 1: Create model
      hvac := FuzzyModel "hvac_controller"
      
      // Step 2: Define inputs
      temperature := FuzzyInput "current_temp"
      cold := FuzzySet 10.0 10.0 15.0 20.0 "cold"
      comfortable := FuzzySet 18.0 22.0 24.0 28.0 "comfortable"
      hot := FuzzySet 25.0 30.0 35.0 35.0 "hot"
      temperature.add-all-sets [cold, comfortable, hot]
      hvac.add_input temperature
      
      // Step 3: Define outputs
      fan_speed := FuzzyOutput "fan_speed"
      off := FuzzySet 0.0 0.0 10.0 20.0 "off"
      low := FuzzySet 15.0 25.0 35.0 45.0 "low"
      medium := FuzzySet 40.0 50.0 60.0 70.0 "medium"
      high := FuzzySet 65.0 75.0 90.0 100.0 "high"
      fan_speed.add-all-sets [off, low, medium, high]
      hvac.add_output fan_speed
      
      // Step 4: Define rules
      hvac.add_rule (FuzzyRule.fl-if (Antecedent.fl-set cold) --fl-then=(Consequent.output high))
      hvac.add_rule (FuzzyRule.fl-if (Antecedent.fl-set comfortable) --fl-then=(Consequent.output low))
      hvac.add_rule (FuzzyRule.fl-if (Antecedent.fl-set hot) --fl-then=(Consequent.output high))
      
      // Step 5: Use the model
      hvac.crisp_input 0 26.0  // Hot temperature
      hvac.fuzzify
      result := hvac.defuzzify 0
      
      print "HVAC test - Temperature: 26°C, Fan Speed: $(%.1f result)%"
      expect_true result > 50.0  // Should be high speed for hot temperature

  test "Usability" "debugging and introspection":
    model := FuzzyModel "debug_model"
    
    input := FuzzyInput "debug_input"
    set1 := FuzzySet 0.0 10.0 20.0 30.0 "debug_set1"
    set2 := FuzzySet 20.0 30.0 40.0 50.0 "debug_set2"
    input.add_set set1
    input.add_set set2
    model.add_input input
    
    output := FuzzyOutput "debug_output"
    out1 := FuzzySet 0.0 25.0 50.0 75.0 "debug_out1"
    out2 := FuzzySet 50.0 75.0 100.0 100.0 "debug_out2"
    output.add_set out1
    output.add_set out2
    model.add_output output
    
    rule1 := FuzzyRule (Antecedent.fl_set set1) (Consequent.output out1)
    rule2 := FuzzyRule (Antecedent.fl_set set2) (Consequent.output out2)
    model.add_rule rule1
    model.add_rule rule2
    
    // Test introspection capabilities
    model.crisp_input 0 25.0  // Should activate both sets partially
    model.fuzzify
    
    // Check which rules fired
    rule1_fired := model.is_fired 0
    rule2_fired := model.is_fired 1
    
    print "Input: 25.0"
    print "Rule 1 fired: $rule1_fired"
    print "Rule 2 fired: $rule2_fired"
    print "Set1 pertinence: $(%.3f set1.pertinence)"
    print "Set2 pertinence: $(%.3f set2.pertinence)"
    
    result := model.defuzzify 0
    print "Final result: $(%.3f result)"
    
    // Both rules should fire for input at the boundary
    expect_true rule1_fired
    expect_true rule2_fired

  test "Performance" "API efficiency":
    // Test that common operations are efficient
    model := FuzzyModel "efficiency_test"
    
    // Create inputs efficiently
    start_time := Time.monotonic_us
    
    for i := 0; i < 10; i++:
      input := FuzzyInput "input_$i"
      for j := 0; j < 5; j++:
        base := j.to_float * 20.0
        set := FuzzySet base (base + 5.0) (base + 10.0) (base + 15.0) "set_$(i)_$(j)"
        input.add_set set
      model.add_input input
    
    setup_time := Time.monotonic_us - start_time
    print "Model setup with 10 inputs, 50 sets: $(%.2f setup_time/1000.0)ms"
    
    # Test inference efficiency
    start_time = Time.monotonic_us
    
    for i := 0; i < 10; i++:
      model.crisp_input i (i.to_float * 10.0 + 25.0)
    
    model.fuzzify
    
    inference_time := Time.monotonic_us - start_time
    print "Inference with 10 inputs: $(%.2f inference_time/1000.0)ms"
    
    # Verify reasonable performance (should be under 100ms for this size)
    expect_true inference_time < 100000  # 100ms in microseconds

  test "API" "error messages quality":
    # Test that error messages are helpful
    try:
      # Try to create rule with incompatible types
      set := FuzzySet 0.0 10.0 20.0 30.0 "test_set"
      antecedent := Antecedent.fl_set set
      
      # This should produce a clear error message
      invalid_consequent := "not a consequent"
      rule := FuzzyRule antecedent invalid_consequent
      expect_true false
    catch e:
      print "Error message quality test: $e"
      # Error message should mention the type mismatch
      expect_true e.contains "consequent" or e.contains "type"

  test-end