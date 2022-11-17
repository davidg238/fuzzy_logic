// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

// Copyright (c) 2021 Ekorau LLC

/*
Some helper functions for Toit floats (size 64-bit).
Refer:
  1) https://google.github.io/googletest/reference/assertions.html
  2) https://randomascii.wordpress.com/2012/02/25/comparing-floating-point-numbers-2012-edition/
  3) https://en.wikipedia.org/wiki/Double-precision_floating-point_format
  4) https://frama-c.com/2013/05/09/Definition-of-FLT_EPSILON.html
  5) https://www.cplusplus.com/reference/cfloat/

  Inline usage guidance taken from 2)

*/
FLT_PZERO := float.from_bits 0x0 // +0
FLT_NZERO := float.from_bits 0x8000_0000_0000_0000 // -0
FLT_EPSILON  := 0.000000119209290 // For 32bit.
FLT_MAX_DIFF := 0.000001          // Good enough?

// Floats are 64-bit doubles
class FUnion:
  raw_mantissa/int
  raw_exponent/int
  f/float
  i/int

  constructor .f:
    raw_mantissa = ((1 << 52)-1)  & f.bits
    raw_exponent = (f.bits >> 52) & 0x7FF
    i = f.bits

  negative -> bool: return i < 0

  stringify -> string:
    return "$(%x i)"

almost_equal_rel a/float b/float max_rel_diff/float=FLT_EPSILON -> bool:
  // Calculate the difference.
  diff := (a - b).abs
  am := a.abs
  bm := b.abs
  // Find the largest.
  largest := bm>am ? b : a
  return diff <= largest*max_rel_diff

almost_equal_ulps a/float b/float max_ulps_diff=4 -> bool:
  uA := FUnion a
  uB := FUnion b
  if uA.negative != uB.negative:  // Comparing number of differing sign doesn't make sense
    return a == b                 // Returns true for the special case of +0 and -0.
  ulps_diff := (uA.i - uB.i).abs
  return ulps_diff <= max_ulps_diff

almost_equal_abs_ulps a/float b/float max_diff/float=FLT_MAX_DIFF max_ulps_diff/int=4 -> bool:
  // Check if the numbers are really close -- needed
  // when comparing numbers near zero.
  return (a-b).abs <= max_diff or
      almost_equal_ulps a b max_ulps_diff

almost_equal_abs_rel a/float b/float max_diff/float=FLT_MAX_DIFF max_rel_diff/float=FLT_EPSILON -> bool:
  // Check if the numbers are really close -- needed
  // when comparing numbers near zero.
  diff := (a - b).abs
  if diff <= max_diff: return true
  aa := a.abs
  ba := b.abs
  largest := ba > aa ? b : a
  return diff <= largest * max_rel_diff

/// ------------------ not for production, for understanding ------------------
diff_ulps a/float b/float -> int:
  uA := FUnion a
  uB := FUnion b
  if uA.negative != uB.negative:  // Comparing number of differing sign doesn't make sense
    return (a==b)? 0: -1          // Returns 0 for the special case of +0 and -0
  return (uA.i - uB.i).abs.to_int
