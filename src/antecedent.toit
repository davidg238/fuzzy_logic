// Copyright (c) 2021, 2022 Ekorau LLC

import math
import .fuzzy-set show FuzzySet

abstract class Antecedent:

  op-and := true  // there are only 2 operators: and and or, so a bool is possible
  fuzzy-set-1_ := null
  fuzzy-set-2_ := null
  antecedent-1_ := null
  antecedent-2_ := null

  constructor:

  constructor.set fuzzy-set/FuzzySet:
    return Ante-FS fuzzy-set

  constructor.AND-sets fuzzy-set-1/FuzzySet fuzzy-set-2/FuzzySet:
    return Ante-FS-FS fuzzy-set-1 fuzzy-set-2 true

  constructor.OR-sets fuzzy-set-1/FuzzySet fuzzy-set-2/FuzzySet:
    return Ante-FS-FS fuzzy-set-1 fuzzy-set-2 false

  constructor.AND-set-ante fuzzy-set/FuzzySet antecedent/Antecedent:
    return Ante-FS-FRA fuzzy-set antecedent true
    
  constructor.AND-ante-set antecedent/Antecedent fuzzy-set/FuzzySet:
    return Ante-FS-FRA fuzzy-set antecedent true

  constructor.OR-set-ante fuzzy-set/FuzzySet antecedent/Antecedent:
    return Ante-FS-FRA fuzzy-set antecedent false

  constructor.OR-ante-set antecedent/Antecedent fuzzy-set/FuzzySet:
    return Ante-FS-FRA fuzzy-set antecedent false

  constructor.AND-ante-ante antecedent-1/Antecedent antecedent-2/Antecedent:
    return Ante-FRA-FRA antecedent-1 antecedent-2 true

  constructor.OR-ante-ante antecedent-1/Antecedent  antecedent-2/Antecedent:
    return Ante-FRA-FRA antecedent-1 antecedent-2 false

  abstract evaluate -> float

class Ante-FS extends Antecedent:

  constructor fuzzy-set/FuzzySet:
    fuzzy-set-1_ = fuzzy-set

  stringify -> string:
    return fuzzy-set-1_.name

  evaluate -> float:
    return fuzzy-set-1_.pertinence

class Ante-FS-FS extends Antecedent:

  constructor fuzzy-set-1/FuzzySet fuzzy-set-2/FuzzySet op/bool:
    op-and = op
    fuzzy-set-1_ = fuzzy-set-1    
    fuzzy-set-2_ = fuzzy-set-2

  stringify -> string:
    return op-and?    
      "($fuzzy-set-1_.name and $fuzzy-set-2_.name)":
      "($fuzzy-set-1_.name or $fuzzy-set-2_.name)"

  evaluate -> float:
    // a join of two FuzzySet, switch by the operator
    // the operator is AND, check if both has pertinence bigger then 0.0
    // the operator is OR, check if one has pertinence bigger then 0.0
    return op-and?
      max 0.0 (min fuzzy-set-1_.pertinence fuzzy-set-2_.pertinence):
      max 0.0 (max fuzzy-set-1_.pertinence fuzzy-set-2_.pertinence)

class Ante-FS-FRA extends Antecedent:

  constructor fuzzy-set/FuzzySet antecedent/Antecedent op/bool:
    op-and = op
    fuzzy-set-1_ = fuzzy-set
    antecedent-1_ = antecedent

  stringify -> string:
    return op-and?    
      "($fuzzy-set-1_.name and $antecedent-1_)":
      "($fuzzy-set-1_.name or $antecedent-1_)"

  evaluate -> float:
      return op-and?
        max 0.0 (min fuzzy-set-1_.pertinence antecedent-1_.evaluate):
        max 0.0 (max fuzzy-set-1_.pertinence antecedent-1_.evaluate)

class Ante-FRA-FRA extends Antecedent:
  
  constructor antecedent-1/Antecedent antecedent-2/Antecedent op/bool:
    op-and = op
    antecedent-1_ = antecedent-1
    antecedent-2_ = antecedent-2

  stringify -> string:
    return op-and?     
      "($antecedent-1_ and $antecedent-2_)":
      "($antecedent-1_ or $antecedent-2_)"

  evaluate -> float:
    // a join of two FuzzyRuleAntecedent, switch by the operator
    // the operator is AND, check if both has pertinence bigger then 0.0
    // the operator is OR, check if one has pertinence bigger then 0.0
    return op-and?         
      max 0.0 (min antecedent-1_.evaluate antecedent-2_.evaluate):
      max 0.0 (max antecedent-1_.evaluate antecedent-2_.evaluate)
