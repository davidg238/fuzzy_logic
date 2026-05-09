// Copyright (c) 2021, 2026 Ekorau LLC

import .antecedent show Antecedent
import .consequent show Consequent

interface RuleTerm:
  term-eval -> float

class FuzzyRule:

  fired := false
  antecedent_/Antecedent
  fl-then/Consequent? := null
  name/string := ""
  weight/float := 1.0

  constructor.fl-if .antecedent_/Antecedent --.fl-then/Consequent --.name="" --weight=1.0:
    this.weight = weight.to-float

  evaluate -> bool:
    antecedent-power := antecedent_.term-eval
    fired = antecedent-power > 0.0
    fl-then.evaluate antecedent-power * weight
    return fired

  stringify -> string:
    prefix := ""
    if not name.is-empty:
      prefix = "$name: "
    suffix := ""
    if weight != 1.0:
      suffix = " with $weight"
    return "$(prefix)if $antecedent_ then $fl-then$suffix"
