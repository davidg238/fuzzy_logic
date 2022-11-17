// Copyright (c) 2021 Ekorau LLC

import .fuzzy_set show FuzzySet

class Consequent:

  fuzzy_set_outputs/List := []

  constructor.output set/FuzzySet:
    this.add_output set

  add_output fuzzy_set/FuzzySet -> none:
    fuzzy_set_outputs.add fuzzy_set

  evaluate power/float -> none:
    fuzzy_set_outputs.do:
      it.pertinence power

  stringify -> string:
    str := "("
    fuzzy_set_outputs.do:
        str = str + it.name + ", "
    return str + ")"