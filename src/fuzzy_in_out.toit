// Copyright (c) 2021 Ekorau LLC

import .composition show Composition
import .geometry show Point2f NoPoint2f

seg idx/int list/List -> List:
    return [list[idx], list[idx + 1]]

class InputOutput:

  fsets/List := []
  name/string

  constructor .name="":

  add-set a-set -> none:
    fsets.add a-set

  add-all-sets sets/List-> none:
    fsets.add-all sets

  clear -> none:
    fsets.do: it.clear

  /// Test method, not API
  clear-all -> none:
    fsets = []

  set-names -> List:
    names := []
    fsets.do: names.add it.name
    return names

class FuzzyInput extends InputOutput:

  constructor name="" :
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

