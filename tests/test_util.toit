// Copyright (c) 2021 Ekorau LLC

import .float_util show almost_equal_abs_ulps

tot_test := 0
test_fail := 0
case := 0
case_fail := 0
tot_case:= 0
tot_case_fail := 0
err_str := ""


test_start:
    
test_end:
    print "-----------------------------------------------------"
    print "Tests run/failed: $tot_test/$test_fail Cases run/failed: $tot_case/$tot_case_fail"
    // latch.set 0

test suite_name/string test_name/string [block] ->none:
    try:
        print "Test $tot_test class $suite_name, feature: $test_name"
        case = 0
        case_fail = 0
        exception := catch:
            block.call
        if exception:
            print "      Case $case threw, $exception"
            print "       (No further cases run in this suite)"
            case++ // since unwound during the exception
            case_fail++
            // print "c/c_f  $case / $case_fail"
    finally:
        test_finished

test_finished -> none:
    print "  run: $case failed: $case_fail"
    tot_test++
    tot_case = tot_case + case
    if case_fail > 0: 
        test_fail++
        tot_case_fail = tot_case_fail + case_fail

expect_equals expected/int val/int ->none:
    if expected != val:
        print_err "expected $expected but got $val" 
        case_fail++
    case++

expect_near expected/float val/float ->none:
    if not almost_equal_abs_ulps expected val:  
        print_err "expected $(%.7f expected) but got $(%.7f val)" 
        case_fail++
    case++

expect_not_null val/any ->none:
    if val == null:
        print_err "expected non-null value" 
        case_fail++
    case++

expect_runs [block] ->none:
    exception := catch:
        block.call
    if exception:
        print_err "threw $exception"
        case_fail++
    case++

expect_false [condition] -> none:
    if condition.call:
        print_err "expected false"     
        case_fail++
    case++

expect_true [condition] -> none:
    if not condition.call:
        print_err "expected true"     
        case_fail++
    case++

print_err msg/string -> none:
    print "      Case $case failed, $msg" 



