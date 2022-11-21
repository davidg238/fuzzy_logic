// Copyright (c) 2021 Ekorau LLC

import .composition show Composition
import .geometry show Point2f NoPoint

seg idx/int list/List -> List:
    return [list[idx], list[idx + 1]]

class InputOutput:

  crisp_in := 0.0
  fsets/List := []
  name/string

  constructor .name="":

  add_set a_set -> none:
      fsets.add a_set

  add_all_sets sets/List-> none:
      fsets.add_all sets

  reset_sets -> none:
      fsets.do: it.reset

class FuzzyInput extends InputOutput:

  constructor name="" :
    super name

  calculate_set_pertinences -> none:
    fsets.do: it.pertinence_for crisp_in

  stringify -> string:
    in_str := "in: $name\n"
    fsets.do:
      in_str = in_str + "    " + it.stringify + "\n"
    return "$in_str"


class FuzzyOutput extends InputOutput:

  composition_ := Composition

  constructor name="":
      super name

  crisp_out -> float:
      return composition_.centroid_x

  composition -> Composition:
      return composition_

  order -> none:
      fsets.sort --in_place=true: | a b | a.compare_to b

  stringify -> string:
      out_str := "out: $name\n"
      fsets.do:
          out_str = out_str + "    " + it.stringify + "\n"
      return "$out_str"        

  truncate -> none:
      // print "truncate output $index_, which looks like: "
      // print "$this"
      sublist := List
      fsets.do:
          if it.is_pertinent: 
              print "output $name, add set: " + it.stringify + "\n"
              sublist.add it
      sublist.sort --in_place: | a b | (a.a_.compare_to b.a_)
      composition_.clear
      sublist.do: |set|
          composition_.union (set.truncated) /// truncate the set shape to the pertinence
      // composition.simplify

