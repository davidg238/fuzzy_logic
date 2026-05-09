// Copyright (c) 2021, 2026 Ekorau LLC

import .fuzzy_in_out show FuzzyOutput
import .fuzzy_set show FuzzySet SingletonSet

/*
A composition aggregates the truncated areas of every pertinent set
in a $FuzzyOutput and reports the defuzzified crisp value (centre of
gravity).
*/
class Composition:

  foutput_ /FuzzyOutput
  crisp-out_ /float? := null

  constructor .foutput_/FuzzyOutput:

  clear -> none:
    crisp-out_ = null

  defuzzify -> float:
    if crisp-out_ == null:
      crisp-out_ = centroid-x collect-pertinent_
    return crisp-out_

  collect-pertinent_ -> List:
    subset := []
    foutput_.fsets.do:
      if it.is-pertinent:
        subset.add it
    return subset

  centroid-x subset/List -> float:
    if subset.size == 1 and subset[0] is SingletonSet:
      return subset[0].truncated-weighted-centroid
    weighted := 0.0
    tot-area := 0.0
    subset.do:
      tot-area += it.truncated-area
      weighted += it.truncated-weighted-centroid
    return weighted / tot-area
