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
import fuzzy_logic show *
import .models show *

main:

  amodel := get_model "driver"
  start := Time.monotonic_us
  m_input := 35 //todo, test with 100
  amodel.crisp_input 0 m_input
  amodel.changed
  amodel.fuzzify
  m_output := amodel.defuzzify 0
  end := Time.monotonic_us

  print "Time: $(%.1f (end-start)/1000.0)ms Distance: $m_input ---> Speed: $(%.1f m_output)"