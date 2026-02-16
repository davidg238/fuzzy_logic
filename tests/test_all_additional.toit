// Copyright (c) 2025 Ekorau LLC
// Test runner for all proposed additional tests

import btest show *
import .test_edge_cases as edge-cases
import .test_performance as perf-main
import .test_integration as integration-main
import .test_validation as val-main
import .test_api_usability as api-main


main:
  test-start
  
  print "\n=== Running Edge Case Tests ==="
  edge-cases.main

  print "\n=== Running Performance Tests ==="
  perf-main.main
  
  print "\n=== Running Integration Tests ==="
  integration-main.main
  
  print "\n=== Running Validation Tests ==="
  val-main.main
  
  print "\n=== Running API Usability Tests ==="
  api-main.main
  
  print "\n=== All Additional Tests Completed ==="
  test-end