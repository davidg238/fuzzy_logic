// Copyright (c) 2021 Ekorau LLC

import .fuzzy_set show FuzzySet

class Consequent:

  sets_/List := []

  constructor.output set/FuzzySet:
    this.add_output set

  add_output fuzzy_set/FuzzySet -> none:
    sets_.add fuzzy_set

  evaluate power/float -> none:
    sets_.do:
      it.max power

  stringify -> string:
    str := "("
    for i:=0; i<sets_.size; i++:
      str += sets_[i].name
      if i < sets_.size-1:
        str += ", "
    return str + ")"