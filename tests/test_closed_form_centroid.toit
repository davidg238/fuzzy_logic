// Copyright (c) 2026 Ekorau LLC

import btest show *
import fuzzy-logic show *

main:
  test-start

  test "ClosedForm" "TriangularSet area at h=1.0":
    set := FuzzySet 0.0 5.0 5.0 10.0 "tri"
    set.max 1.0
    expect-near 5.0 set.truncated-area
    expect-near 5.0 (set.truncated-weighted-centroid / set.truncated-area)

  test "ClosedForm" "TriangularSet area at h=0.5":
    set := FuzzySet 0.0 5.0 5.0 10.0 "tri"
    set.max 0.5
    expect-near 3.75 set.truncated-area
    expect-near 5.0 (set.truncated-weighted-centroid / set.truncated-area)

  test "ClosedForm" "TrapezoidalSet area at h=1.0":
    set := FuzzySet 0.0 2.0 8.0 10.0 "trap"
    set.max 1.0
    // trapezoid (0,0),(2,1),(8,1),(10,0): bases 10 (bottom) and 6 (top), height 1
    //   area = (10 + 6) / 2 * 1 = 8.0; centroid x = 5.0 by symmetry
    expect-near 8.0 set.truncated-area
    expect-near 5.0 (set.truncated-weighted-centroid / set.truncated-area)

  test "ClosedForm" "LTrapezoidalSet at h=1.0":
    set := FuzzySet 0.0 0.0 5.0 10.0 "ltrap"
    set.max 1.0
    expect-near 7.5 set.truncated-area
    // polygon (0,0),(10,0),(5,1),(0,1): 6*A*Cx = 175 -> Cx = 175/45
    expect-near 3.8888888 (set.truncated-weighted-centroid / set.truncated-area)

  test "ClosedForm" "RTrapezoidalSet at h=1.0":
    set := FuzzySet 0.0 5.0 10.0 10.0 "rtrap"
    set.max 1.0
    expect-near 7.5 set.truncated-area
    expect-near 6.1111111 (set.truncated-weighted-centroid / set.truncated-area)

  test "ClosedForm" "SingletonSet area is zero, weighted centroid is a":
    set := FuzzySet 7.0 7.0 7.0 7.0 "sing"
    set.max 1.0
    expect-near 0.0 set.truncated-area
    expect-near 7.0 set.truncated-weighted-centroid

  test "ClosedForm" "untruncated set has zero area":
    set := FuzzySet 0.0 5.0 5.0 10.0 "tri"
    set.max 0.0
    expect-near 0.0 set.truncated-area
    expect-near 0.0 set.truncated-weighted-centroid

  test-end
