// Copyright (c) 2021 Ekorau LLC

import .composition show Composition
import .geometry show Point2f NoPoint2f

seg idx/int list/List -> List:
    return [list[idx], list[idx + 1]]

class InputOutput:

  fsets/List := []
  range_/List? := null
  name/string

  constructor.sets .fsets/List --.name="":

  constructor .name="":


  add-set a-set -> none:
    fsets.add a-set
    range_ = null

  add-all-sets sets/List-> none:
    fsets.add-all sets
    range_ = null

  clear -> none:
    fsets.do: it.clear
    range_ = null

  range -> List:
    if range_ == null:
      range_ = [0, 0]
      fsets.do:
        range_[0] = min range_[0] it.range[0]
        range_[1] = max range_[1] it.range[1]
    return range_

  set-names -> List:
    names := []
    fsets.do: names.add it.name
    return names

class FuzzyInput extends InputOutput:

  constructor.sets sets/List --name="":
    super.sets sets --name=name

  constructor name="":
    super name

  fuzzify crisp-in/num -> none:
    fsets.do: it.fuzzify crisp-in

  stringify -> string:
    in-str := "in: $name\n"
    fsets.do:
      in-str = in-str + "    " + it.stringify + "\n"
    return "$in-str"


class FuzzyOutput extends InputOutput:

  composition_ /Composition? := null

  constructor.sets sets/List --name="":
    super.sets sets --name=name
    composition_ = Composition this

  constructor name="":
      super name
      composition_ = Composition this

  clear -> none:
    composition_.clear
    super

  composition -> Composition:
      return composition_

  defuzzify -> float:
    return composition_.defuzzify

  stringify -> string:
      out-str := "out: $name\n"
      fsets.do:
          out-str = out-str + "    " + it.stringify + "\n"
      return "$out-str"        

