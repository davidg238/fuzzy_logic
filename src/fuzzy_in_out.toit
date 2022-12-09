// Copyright (c) 2021 Ekorau LLC

import .composition show Composition
import .geometry show Point2f NoPoint2f

seg idx/int list/List -> List:
    return [list[idx], list[idx + 1]]

class InputOutput:

  fsets/List := []
  name/string

  constructor .name="":

  add_set a_set -> none:
    fsets.add a_set

  add_all_sets sets/List-> none:
    fsets.add_all sets

  clear -> none:
    fsets.do: it.clear

  set_names -> List:
    names := []
    fsets.do: names.add it.name
    return names

class FuzzyInput extends InputOutput:

  constructor name="" :
    super name

  fuzzify crisp_in/num -> none:
    fsets.do: it.fuzzify crisp_in

  stringify -> string:
    in_str := "in: $name\n"
    fsets.do:
      in_str = in_str + "    " + it.stringify + "\n"
    return "$in_str"


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
      out_str := "out: $name\n"
      fsets.do:
          out_str = out_str + "    " + it.stringify + "\n"
      return "$out_str"        

