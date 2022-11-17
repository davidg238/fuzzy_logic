// Copyright (c) 2021, 2022 Ekorau LLC

import math
import .fuzzy_set show FuzzySet

abstract class Antecedent:

  op_and := true  // there are only 2 operators: and and or, so a bool is possible
  fuzzy_set_1_ := null
  fuzzy_set_2_ := null
  antecedent_1_ := null
  antecedent_2_ := null

  constructor:

  constructor.set fuzzy_set/FuzzySet:
    return Ante_FS fuzzy_set

  constructor.AND_sets fuzzy_set_1/FuzzySet fuzzy_set_2/FuzzySet:
    return Ante_FS_FS fuzzy_set_1 fuzzy_set_2 true

  constructor.OR_sets fuzzy_set_1/FuzzySet fuzzy_set_2/FuzzySet:
    return Ante_FS_FS fuzzy_set_1 fuzzy_set_2 false

  constructor.AND_set_ante fuzzy_set/FuzzySet antecedent/Antecedent:
    return Ante_FS_FRA fuzzy_set antecedent true
    
  constructor.AND_ante_set antecedent/Antecedent fuzzy_set/FuzzySet:
    return Ante_FS_FRA fuzzy_set antecedent true

  constructor.OR_set_ante fuzzy_set/FuzzySet antecedent/Antecedent:
    return Ante_FS_FRA fuzzy_set antecedent false

  constructor.OR_ante_set antecedent/Antecedent fuzzy_set/FuzzySet:
    return Ante_FS_FRA fuzzy_set antecedent false

  constructor.AND_ante_ante antecedent_1/Antecedent antecedent_2/Antecedent:
    return Ante_FRA_FRA antecedent_1 antecedent_2 true

  constructor.OR_ante_ante antecedent_1/Antecedent  antecedent_2/Antecedent:
    return Ante_FRA_FRA antecedent_1 antecedent_2 false

  abstract evaluate -> float

class Ante_FS extends Antecedent:

  constructor fuzzy_set/FuzzySet:
    fuzzy_set_1_ = fuzzy_set

  stringify -> string:
    return fuzzy_set_1_.name

  evaluate -> float:
    return fuzzy_set_1_.pertinence

class Ante_FS_FS extends Antecedent:

  constructor fuzzy_set_1/FuzzySet fuzzy_set_2/FuzzySet op/bool:
    op_and = op
    fuzzy_set_1_ = fuzzy_set_1    
    fuzzy_set_2_ = fuzzy_set_2

  stringify -> string:
    return op_and?    
      "($fuzzy_set_1_.name and $fuzzy_set_2_.name)":
      "($fuzzy_set_1_.name or $fuzzy_set_2_.name)"

  evaluate -> float:
    // a join of two FuzzySet, switch by the operator
    // the operator is AND, check if both has pertinence bigger then 0.0
    // the operator is OR, check if one has pertinence bigger then 0.0
    return op_and?
      max 0.0 (min fuzzy_set_1_.pertinence fuzzy_set_2_.pertinence):
      max 0.0 (max fuzzy_set_1_.pertinence fuzzy_set_2_.pertinence)

class Ante_FS_FRA extends Antecedent:

  constructor fuzzy_set/FuzzySet antecedent/Antecedent op/bool:
    op_and = op
    fuzzy_set_1_ = fuzzy_set
    antecedent_1_ = antecedent

  stringify -> string:
    return op_and?    
      "($fuzzy_set_1_.name and $antecedent_1_)":
      "($fuzzy_set_1_.name or $antecedent_1_)"

  evaluate -> float:
      return op_and?
        max 0.0 (min fuzzy_set_1_.pertinence antecedent_1_.evaluate):
        max 0.0 (max fuzzy_set_1_.pertinence antecedent_1_.evaluate)

class Ante_FRA_FRA extends Antecedent:
  
  constructor antecedent_1/Antecedent antecedent_2/Antecedent op/bool:
    op_and = op
    antecedent_1_ = antecedent_1
    antecedent_2_ = antecedent_2

  stringify -> string:
    return op_and?     
      "($antecedent_1_ and $antecedent_2_)":
      "($antecedent_1_ or $antecedent_2_)"

  evaluate -> float:
    // a join of two FuzzyRuleAntecedent, switch by the operator
    // the operator is AND, check if both has pertinence bigger then 0.0
    // the operator is OR, check if one has pertinence bigger then 0.0
    return op_and?         
      max 0.0 (min antecedent_1_.evaluate antecedent_2_.evaluate):
      max 0.0 (max antecedent_1_.evaluate antecedent_2_.evaluate)
