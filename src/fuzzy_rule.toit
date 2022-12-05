// Copyright (c) 2021 Ekorau LLC

import .antecedent show Antecedent
import .consequent show Consequent

class FuzzyRule:

  fired := false
  antecedent_/Antecedent 
  consequent_/Consequent 
  name/string

  constructor .antecedent_ .consequent_ .name="":

  evaluate -> bool:
    antecedent_power := antecedent_.evaluate
    // print "ante $antecedent_power"
    fired = antecedent_power > 0.0? true : false
    consequent_.evaluate antecedent_power
    // print "eval conse $consequent_"
    return fired

  stringify -> string: return "$name: if $antecedent_ then $consequent_"

