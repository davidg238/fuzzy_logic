// Copyright (c) 2021, 2022 Ekorau LLC

import math
import .fuzzy_set show FuzzySet
import .fuzzy_rule show RuleTerm

abstract class Antecedent implements RuleTerm:

  term1 /RuleTerm? := null
  term2 /RuleTerm? := null

  constructor .term1 .term2:

  constructor.fl-set fuzzy-set/FuzzySet:
    return Ante-Set fuzzy-set

  constructor.fl-and terma/RuleTerm termb/RuleTerm:
    return Ante-And terma termb

  constructor.fl-or terma/RuleTerm termb/RuleTerm:
    return Ante-Or terma termb
  
  abstract term-eval -> float


class Ante-Set extends Antecedent:

  constructor term:
    super term null

  stringify -> string:
    return (term1 as FuzzySet).name

  term-eval -> float:
    return term1.term-eval

// A join of two FuzzySet:
//  if the operator is AND, check if both has pertinence bigger then 0.0
//  if the operator is OR, check if one has pertinence bigger then 0.0


class Ante-And extends Antecedent:

  constructor term1/RuleTerm term2/RuleTerm:
    super term1 term2

  stringify -> string:
    return "($term1 and $term2)"

  term-eval -> float:
    return max 0.0 (min term1.term-eval term2.term-eval)

class Ante-Or extends Antecedent:

  constructor term1/RuleTerm term2/RuleTerm:
    super term1 term2

  stringify -> string:
    return "($term1 or $term2)"

  term-eval -> float:
    return max 0.0 (max term1.term-eval term2.term-eval)
