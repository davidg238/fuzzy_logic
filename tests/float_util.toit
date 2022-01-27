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
FLT_EPSILON :=  0.000000119209290 // for 32bit
FLT_MAX_DIFF := 0.000001          // good enough?

// Floats are 64-bit doubles
class FUnion:
  raw_mantissa/int
  raw_exponent/int
  f/float
  i/int

  constructor .f:
    raw_mantissa = f.bits & ((1 << 52)-1)
    raw_exponent = (f.bits >> 52) & 0xFF
    i = f.bits

  negative -> bool: return (i < 0)

  stringify -> string:
    return "$(%x i)"

almost_equal_rel a/float b/float maxRelDiff/float=FLT_EPSILON -> bool:
  // Calculate the difference.
  diff := (a - b).abs
  am := a.abs
  bm := b.abs
  // Find the largest
  largest := bm>am ? b : a
  return diff <= largest*maxRelDiff

almost_equal_ulps a/float b/float maxUlpsDiff=4 -> bool:
    if not a.sign==b.sign:  
      return a==b   // since returns true for +0==-0
    else:
      uA := FUnion a
      uB := FUnion b
      ulpsDiff := (uA.i - uB.i).abs.to_int
      return ulpsDiff <= maxUlpsDiff

almost_equal_abs_ulps a/float b/float maxDiff/float=FLT_MAX_DIFF maxUlpsDiff/int=4 -> bool:
  // Check if the numbers are really close -- needed
  // when comparing numbers near zero.
  return (a-b).abs<=maxDiff?
    true : 
    almost_equal_ulps a b

almost_equal_abs_rel a/float b/float maxDiff/float=FLT_MAX_DIFF maxRelDiff/float=FLT_EPSILON -> bool:
  // Check if the numbers are really close -- needed
  // when comparing numbers near zero.
  diff := (a - b).abs
  if diff<=maxDiff: return true
  aa := a.abs
  ba := b.abs
  largest := ba > aa ? b : a
  return diff <= largest*maxRelDiff

/// ------------------ not for production, for understanding ------------------
diff_ulps a/float b/float -> int:
  uA := FUnion a
  uB := FUnion b
  if uA.negative != uB.negative:  // comparing number of differing sign doesn't make sense
    return (a==b)? 0: -1          // returns 0 for the special case of +0 and -0
  return (uA.i - uB.i).abs.to_int
