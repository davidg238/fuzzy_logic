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

  test "ClosedForm" "LraTriangularSet at h=1.0":
    set := FuzzySet 0.0 0.0 0.0 10.0 "lra"
    set.max 1.0
    // right triangle (0,0)-(10,0)-(0,1): area = 10*1/2 = 5.0; centroid x = (2a+d)/3 = 10/3
    expect-near 5.0 set.truncated-area
    expect-near 3.3333333 (set.truncated-weighted-centroid / set.truncated-area)

  test "ClosedForm" "LraTriangularSet at h=0.5":
    set := FuzzySet 0.0 0.0 0.0 10.0 "lra"
    set.max 0.5
    // truncated trapezoid: bases (d-a)=10 and (1-h)(d-a)=5, height 0.5 -> area = 15/2 * 0.5 = 3.75
    // centroid: rect (b2=5, h=0.5, cx=2.5) + triangle (a=1.25, cx=20/3) -> (6.25 + 25/3)/3.75 = 35/9
    expect-near 3.75 set.truncated-area
    expect-near 3.8888888 (set.truncated-weighted-centroid / set.truncated-area)

  test "ClosedForm" "RraTriangularSet at h=1.0":
    set := FuzzySet 0.0 10.0 10.0 10.0 "rra"
    set.max 1.0
    // right triangle (0,0)-(10,0)-(10,1): area = 5.0; centroid x = (a+2d)/3 = 20/3 (mirror of LRA)
    expect-near 5.0 set.truncated-area
    expect-near 6.6666666 (set.truncated-weighted-centroid / set.truncated-area)

  test "ClosedForm" "SingletonSet area is pertinence, weighted centroid is a*pertinence":
    set := FuzzySet 7.0 7.0 7.0 7.0 "sing"
    set.max 1.0
    expect-near 1.0 set.truncated-area
    expect-near 7.0 set.truncated-weighted-centroid
    set.clear
    set.max 0.5
    expect-near 0.5 set.truncated-area
    expect-near 3.5 set.truncated-weighted-centroid

  test "ClosedForm" "untruncated set has zero area":
    set := FuzzySet 0.0 5.0 5.0 10.0 "tri"
    set.max 0.0
    expect-near 0.0 set.truncated-area
    expect-near 0.0 set.truncated-weighted-centroid

  test-end
