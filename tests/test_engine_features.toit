// Copyright (c) 2026 Ekorau LLC

import btest show *
import fuzzy-logic show *

main:
  test-start

  test "Antecedent" "fl-not inverts pertinence":
    set := FuzzySet 0.0 10.0 10.0 20.0 "tri"
    set.max 0.3                             // pertinence_ = 0.3
    not-term := Antecedent.fl-not (Antecedent.fl-set set)
    expect-near 0.7 not-term.term-eval

    set.clear
    set.max 0.0
    not-term2 := Antecedent.fl-not (Antecedent.fl-set set)
    expect-near 1.0 not-term2.term-eval

    set.clear
    set.max 1.0
    not-term3 := Antecedent.fl-not (Antecedent.fl-set set)
    expect-near 0.0 not-term3.term-eval

  test "Antecedent" "fl-not nests under fl-and":
    a := FuzzySet 0.0 10.0 10.0 20.0 "a"
    b := FuzzySet 0.0 10.0 10.0 20.0 "b"
    a.max 0.6
    b.max 0.4

    // (a AND NOT b) -> min(0.6, 1.0 - 0.4) = min(0.6, 0.6) = 0.6
    expr := Antecedent.fl-and a (Antecedent.fl-not (Antecedent.fl-set b))
    expect-near 0.6 expr.term-eval

  test-end
