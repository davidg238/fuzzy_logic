// Copyright 2021 Ekorau LLC
/*
import fuzzy_model show FuzzyModel
import fuzzy_input show FuzzyInput
import fuzzy_output show FuzzyOutput
import fuzzy_set show FuzzySet
import fuzzy_rule show FuzzyRule
import antecedent show Antecedent
import consequent show Consequent
*/
import fuzzy-logic show *
import .models show *

main:

  amodel := get-model "driver"
  start := Time.monotonic-us
  m-input := 35 //todo, test with 100
  amodel.crisp-input 0 m-input
  amodel.changed
  amodel.fuzzify
  m-output := amodel.defuzzify 0
  end := Time.monotonic-us

  print "Time: $(%.1f (end-start)/1000.0)ms Distance: $m-input ---> Speed: $(%.1f m-output)"