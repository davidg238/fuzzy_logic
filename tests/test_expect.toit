// Copyright (c) 2021 Ekorau LLC


import expect show *

main:

    try: 
        expect false
    finally:
        print "failed"
    expect_equals 5 4