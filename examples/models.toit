import fuzzy_logic show *

get_model name/string -> FuzzyModel?:
  if name == "driver":
    return get_driver_model
  else:
    return null

get_driver_model -> FuzzyModel:    
  small := FuzzySet 0.0 20.0 20.0 40.0 "small"
  safe  := FuzzySet 30.0 50.0 50.0 70.0 "safe"
  big   := FuzzySet 60.0 80.0 80.0 80.0 "big"
  distance := FuzzyInput "distance"
  distance.add_set small
  distance.add_set safe
  distance.add_set big

  slow    := FuzzySet 0.0 10.0 10.0 20.0 "slow"
  average := FuzzySet 10.0 20.0 30.0 40.0 "average"
  fast    := FuzzySet 30.0 40.0 40.0 50.0 "fast"
  speed := FuzzyOutput "speed"
  speed.add_set slow
  speed.add_set average
  speed.add_set fast

  rule_01 := FuzzyRule (Antecedent.set small) (Consequent.output slow)     // "IF distance = small THEN speed = slow"
  rule_02 := FuzzyRule (Antecedent.set safe) (Consequent.output average)   // "IF distance = safe THEN speed = average"
  rule_03 := FuzzyRule (Antecedent.set big) (Consequent.output fast)       // "IF distance = big THEN speed = high"

  model := FuzzyModel "driver"
  model.add_input distance
  model.add_output speed
  model.add_rule rule_01
  model.add_rule rule_02
  model.add_rule rule_03

  return model