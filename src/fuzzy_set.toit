// Copyright (c) 2021, 2026 Ekorau LLC

import .fuzzy_rule show RuleTerm

F-error3 ::= 0.0009  // Floating-point tolerance, retained for compare-to.

y-rising p q r -> float:
  return (p - q) / (r - q)

y-falling p q r -> float:
  return 1.0 - (p - q) / (r - q)


abstract class FuzzySet implements RuleTerm:

  a_/float
  b_/float
  c_/float
  d_/float

  pertinence_/float := 0.0
  name := ""

  constructor.with-points a b c d .name="":
    a_ = a.to-float
    b_ = b.to-float
    c_ = c.to-float
    d_ = d.to-float

  constructor a/num b/num c/num d/num aname="":
    if a == b and b == c and c == d: return SingletonSet a b c d aname
    if a == b and b == c:             return LraTriangularSet a b c d aname
    if b == c and c == d:             return RraTriangularSet a b c d aname
    if b == c:                        return TriangularSet a b c d aname
    if a == b:                        return LTrapezoidalSet a b c d aname
    if c == d:                        return RTrapezoidalSet a b c d aname
    return TrapezoidalSet a b c d aname

  clear -> none:
    pertinence_ = 0.0

  compare-to other/FuzzySet -> any:
    if a_ < other.a_: return -1
    if a_ > other.a_: return 1
    if a_ == other.a_ and b_ == other.b_ and c_ == other.c_ and d_ == other.d_: return 0
    if pertinence_ < other.pertinence_: return -1
    if pertinence_ > other.pertinence_: return 1
    return 0

  is-pertinent -> bool:
    return pertinence_ > 0.0

  pertinence -> float:
    return pertinence_

  term-eval -> float:
    return pertinence_

  fuzzify crisp-val/num -> none:
    pertinence_ = lookup_ crisp-val.to-float

  range -> List:
    return [a_, d_]

  abstract lookup_ val/float -> float

  max val/float -> none:
    if pertinence_ < val:
      pertinence_ = val

  truncated-area -> float:
    h := pertinence_
    xL := a_ + h * (b_ - a_)
    xR := d_ - h * (d_ - c_)
    return h * ((d_ - a_) + (xR - xL)) / 2.0

  truncated-weighted-centroid -> float:
    h := pertinence_
    xL := a_ + h * (b_ - a_)
    xR := d_ - h * (d_ - c_)
    return h * (d_*d_ + d_*xR + xR*xR - xL*xL - a_*xL - a_*a_) / 6.0

  stype: return ""

  stringify: return "$name/$(%.1f pertinence_)"

  // Test accessors.
  test-a -> float: return a_
  test-b -> float: return b_
  test-c -> float: return c_
  test-d -> float: return d_


class SingletonSet extends FuzzySet:

  constructor a aname="":
    super.with-points a a a a aname

  constructor a b c d name:
    super.with-points a b c d name

  stype: return "sing"

  lookup_ cVal/float -> float:
    return (a_ - cVal).abs < F-error3 ? 1.0 : 0.0

  truncated-weighted-centroid -> float:
    return a_

  truncated-area -> float:
    return 0.0


class LTrapezoidalSet extends FuzzySet:

  constructor a c d name:
    super.with-points a a c d name

  constructor a b c d name:
    super.with-points a b c d name

  stype: return "trap.l"

  lookup_ cVal/float -> float:
    if cVal <= c_:    return 1.0
    if cVal >= d_:    return 0.0
    return y-falling cVal c_ d_


class RTrapezoidalSet extends FuzzySet:

  constructor a b c name:
    super.with-points a b c c name

  constructor a b c d name:
    super.with-points a b c d name

  stype: return "trap.r"

  lookup_ cVal/float -> float:
    if cVal <= a_:    return 0.0
    if cVal >= b_:    return 1.0
    return y-rising cVal a_ b_


class TrapezoidalSet extends FuzzySet:

  constructor a b c d name:
    super.with-points a b c d name

  stype: return "trap"

  lookup_ cVal/float -> float:
    if cVal <= a_ or cVal >= d_:        return 0.0
    if cVal >= b_ and cVal <= c_:       return 1.0
    if cVal < b_:                       return y-rising cVal a_ b_
    return y-falling cVal c_ d_


class LraTriangularSet extends FuzzySet:

  constructor a d name:
    super.with-points a a a d name

  constructor a b c d name:
    super.with-points a b c d name

  stype: return "tri.lra"

  lookup_ cVal/float -> float:
    if cVal <= a_ or cVal >= d_:        return 0.0
    return y-falling cVal c_ d_


class RraTriangularSet extends FuzzySet:

  constructor a b c d name:
    super.with-points a b c d name

  constructor a d name:
    super.with-points a d d d name

  stype: return "tri.rra"

  lookup_ cVal/float -> float:
    if cVal <= a_ or cVal >= d_:        return 0.0
    return y-rising cVal a_ b_


class TriangularSet extends FuzzySet:

  constructor a b d name:
    super.with-points a b b d name

  constructor a b c d name:
    super.with-points a b c d name

  stype: return "tri"

  lookup_ cVal/float -> float:
    if cVal <= a_ or cVal >= d_:        return 0.0
    if cVal < b_:                       return y-rising cVal a_ b_
    if cVal > b_:                       return y-falling cVal c_ d_
    return 1.0
