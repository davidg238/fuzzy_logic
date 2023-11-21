// Copyright (c) 2021 Ekorau LLC

import .antecedent show Antecedent
import .consequent show Consequent

interface RuleTerm:
  term-eval -> float
 
class FuzzyRule:

  fired := false
  antecedent_/Antecedent 
  fl-then/Consequent? := null
  name/string := ""

  constructor.fl-if .antecedent_/Antecedent --.fl-then/Consequent --name="":

  evaluate -> bool:
    antecedent-power := antecedent_.term-eval
    // print "ante $antecedent_power"
    fired = antecedent-power > 0.0? true : false
    fl-then.evaluate antecedent-power
    // print "eval conse $consequent_"
    return fired

  stringify -> string: return "$name: if $antecedent_ then $fl-then"

