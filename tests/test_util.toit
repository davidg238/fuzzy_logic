// Copyright (c) 2021 Ekorau LLC

/*
This is just enough code to enable the eFLL test suites to be rewritten in Toit, with minimal effort.
It does NOT import expect.
*/
test := 0
test_fail := 0
case := 0
case_fail := 0
tot_case:= 0
tot_case_fail := 0

TEST_START:
    
TEST_END:
    print "-----------------------------------------------------"
    print "Tests run/failed: $test/$test_fail Cases run/failed: $tot_case/$tot_case_fail"
    print ""
    print ""

TEST aclass/string afeature/string [block] ->none:
    try:
        test++
        print "Test $test class $aclass, feature: $afeature"
        case = 0
        case_fail = 0
        exception := catch:
            block.call
        if exception:
            print "      Case $case threw, $exception"
            case_failed
    finally:
        test_finished

ASSERT_EQ expected/int val/int ->none:
    case++
    if expected != val:
        print_err "expected $expected but got $val" 
        case_failed

ASSERT_FLOAT_EQ expected/float val/float ->none:
    case++
    if expected != val:
        print_err "expected $expected but got $val" 
        case_failed

ASSERT_NOT_NULL val/any ->none:
    case++
    if val == null:
        print_err "expected non-null value" 
        case_failed

ASSERT_RUNS [block] ->none:
    case++
    exception := catch:
        block.call
    if exception:
        print_err "threw $exception"
        case_failed

ASSERT_FALSE val/bool ->none:
    case++
    if false != val:
        print_err "expected false but got $val"     
        case_failed

ASSERT_TRUE val/bool ->none:
    case++
    if true != val:
        print_err "expected true but got $val"     
        case_failed

print_err msg/string -> none:
    print "      Case $case failed, $msg" 

case_failed -> none:
    case_fail++
    
test_finished -> none:
    print "  run: $case failed: $case_fail"
    print ""
    tot_case = tot_case + case
    if case_fail > 0: 
        test_fail++
        tot_case_fail = tot_case_fail + case_fail
