// Copyright (c) 2021 Ekorau LLC

import .fuzzy-set show FuzzySet

class Consequent:

  sets_/List := []

  constructor.output set/FuzzySet:
    this.add-output set

  add-output fuzzy-set/FuzzySet -> none:
    sets_.add fuzzy-set

  evaluate power/float -> none:
    sets_.do:
      it.max power

  stringify -> string:
    str := "("
    for i:=0; i<sets_.size; i++:
      str += sets_[i].name
      if i < sets_.size - 1:
        str += ", "
    return str + ")"