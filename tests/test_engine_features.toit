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

  test "FuzzyRule" "weight scales antecedent power":
    in-set := FuzzySet 0.0 10.0 10.0 20.0 "a"
    out-set := FuzzySet 0.0 10.0 10.0 20.0 "b"

    in-set.max 1.0  // antecedent power = 1.0

    // weight = 1.0 (default): consequent receives full power
    rule-default := FuzzyRule.fl-if
        (Antecedent.fl-set in-set)
        --fl-then=(Consequent.output out-set)
    out-set.clear
    in-set.max 1.0
    rule-default.evaluate
    expect-near 1.0 out-set.pertinence

    // weight = 0.5: consequent receives 0.5
    out-set.clear
    in-set.max 1.0
    rule-half := FuzzyRule.fl-if
        (Antecedent.fl-set in-set)
        --fl-then=(Consequent.output out-set)
        --weight=0.5
    rule-half.evaluate
    expect-near 0.5 out-set.pertinence

  test "FuzzyRule" "weight=0 mutes the rule":
    in-set := FuzzySet 0.0 10.0 10.0 20.0 "a"
    out-set := FuzzySet 0.0 10.0 10.0 20.0 "b"
    in-set.max 1.0
    rule := FuzzyRule.fl-if
        (Antecedent.fl-set in-set)
        --fl-then=(Consequent.output out-set)
        --weight=0.0
    rule.evaluate
    expect-near 0.0 out-set.pertinence

  test-end
