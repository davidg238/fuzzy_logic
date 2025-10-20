// Copyright (c) 2025 Ekorau LLC
// Test runner for all proposed additional tests

import btest show *

main:
  test-start
  
  print "\n=== Running Edge Case Tests ==="
  import .test_edge_cases show main as edge_main
  edge_main
  
  print "\n=== Running Performance Tests ==="
  import .test_performance show main as perf_main
  perf_main
  
  print "\n=== Running Integration Tests ==="
  import .test_integration show main as int_main
  int_main
  
  print "\n=== Running Validation Tests ==="
  import .test_validation show main as val_main
  val_main
  
  print "\n=== Running API Usability Tests ==="
  import .test_api_usability show main as api_main
  api_main
  
  print "\n=== All Additional Tests Completed ==="
  test-end