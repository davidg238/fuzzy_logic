import fuzzy_logic show *

get_model name/string -> FuzzyModel?:
  if name == "driver":
    return get_driver
  else if name == "driver_advanced":
    return get_driver_advanced
  else if name == "casco":
    return get_casco
  else:
    return null

get_driver -> FuzzyModel:    
  small := FuzzySet 0.0 20.0 20.0 40.0 "small"
  safe  := FuzzySet 30.0 50.0 50.0 70.0 "safe"
  big   := FuzzySet 60.0 80.0 100.0 100.0 "big"    //60.0 80.0 80.0 80.0 "big"  originally !
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

get_driver_advanced -> FuzzyModel:
      // FuzzyInput
    near := FuzzySet 0.0 20.0 20.0 40.0 "near"
    safe := FuzzySet 30.0 50.0 50.0 70.0 "safe"
    distant := FuzzySet 60.0 80.0 100.0 100.0 "distant"

    // FuzzyInput
    stoppedInput := FuzzySet 0.0 0.0 0.0 0.0 "stpd"
    slowInput := FuzzySet 1.0 10.0 10.0 20.0  "slow"
    normalInput := FuzzySet 15.0 30.0 30.0 50.0 "norm"
    quickInput := FuzzySet 45.0 60.0 70.0 70.0  "quick"

    // FuzzyInput  (use F instead of C)
    cold :=  FuzzySet 0 0 1 14 "cold" // -30.0 -30.0 -20.0 -10.0 "cold"
    good :=  FuzzySet 5 32 32 59  "good" //-15.0 0.0 0.0 15.0  "good"
    hot :=  FuzzySet 50 68 86 86  "hot" // 10.0 20.0 30.0 30.0  "hot"

    // FuzzyOutput
    minimum :=  FuzzySet 0.0 20.0 20.0 40.0 "min" 
    average :=  FuzzySet 30.0 50.0 50.0 70.0  "avg" 
    maximum :=  FuzzySet 60.0 80.0 80.0 100.0 "max" 

    // FuzzyOutput
    stoppedOutput :=  FuzzySet 0.0 0.0 0.0 0.0 "sptd_o"
    slowOutput := FuzzySet 1.0 10.0 10.0 20.0 "slow_o" 
    normalOutput := FuzzySet 15.0 30.0 30.0 50.0  "norm_o" 
    quickOutput := FuzzySet 45.0 60.0 70.0 70.0 "quick_o"

    // FuzzyInput
    distance := FuzzyInput "distance"
    distance.add_set near
    distance.add_set safe
    distance.add_set distant

    // FuzzyInput
    speedInput := FuzzyInput "speed"
    speedInput.add_set stoppedInput
    speedInput.add_set slowInput
    speedInput.add_set normalInput
    speedInput.add_set quickInput

    // FuzzyInput
    temperature := FuzzyInput "temperature"
    temperature.add_set cold
    temperature.add_set good
    temperature.add_set hot

    // FuzzyOutput
    risk := FuzzyOutput "risk"
    risk.add_set minimum
    risk.add_set average
    risk.add_set maximum

    // FuzzyOutput
    speedOutput :=  FuzzyOutput "throttle"
    speedOutput.add_set stoppedOutput 
    speedOutput.add_set slowOutput
    speedOutput.add_set normalOutput
    speedOutput.add_set quickOutput


    distanceNearAndSpeedQuick := Antecedent.AND_sets near quickInput
    temperatureCold := Antecedent.set cold
    if_DistanceNearAndSpeedQuickOrTempCold := Antecedent.OR_ante_ante distanceNearAndSpeedQuick temperatureCold

    then_RiskMaxAndSpeedSlow := Consequent.output maximum
    then_RiskMaxAndSpeedSlow.add_output slowOutput

    rule0 := FuzzyRule if_DistanceNearAndSpeedQuickOrTempCold then_RiskMaxAndSpeedSlow
    

    distanceSafeAndSpeedNormal := Antecedent.AND_sets safe normalInput
    if_DistanceSafeAndSpeedNormalOrTemperatureGood := Antecedent.OR_ante_set distanceSafeAndSpeedNormal good

    then_RiskAverageAndSpeedNormal := Consequent.output average
    then_RiskAverageAndSpeedNormal.add_output normalOutput

    rule1 := FuzzyRule if_DistanceSafeAndSpeedNormalOrTemperatureGood then_RiskAverageAndSpeedNormal

    
    distanceDistantAndSpeedSlow := Antecedent.AND_sets distant slowInput
    if_DistanceDistantAndSpeedSlowOrTemperatureHot := Antecedent.OR_ante_set distanceDistantAndSpeedSlow hot

    then_RiskMinimumSpeedQuick := Consequent.output minimum
    then_RiskMinimumSpeedQuick.add_output quickOutput

    rule2 :=  FuzzyRule if_DistanceDistantAndSpeedSlowOrTemperatureHot then_RiskMinimumSpeedQuick
    
    model := FuzzyModel "driver_advanced"
    model.add_input distance
    model.add_input speedInput
    model.add_input temperature
    model.add_output risk
    model.add_output speedOutput
    model.add_rule rule0
    model.add_rule rule1
    model.add_rule rule2

    return model

get_casco -> FuzzyModel:

  fuzzy := FuzzyModel "casco"
  // FuzzyInput
  dry :=       FuzzySet  0.0   0.0   0.0  42.5  "dry" // seco
  wet :=       FuzzySet 37.5  60.0  60.0  82.5  "wet" // humedo
  puddled :=   FuzzySet 77.5 100.0 100.0 100.0  "puddled" // charco
  humidity := FuzzyInput "humidity"             // humedad  
  humidity.add_all_sets [dry, wet, puddled]
  fuzzy.add_input humidity
  // FuzzyInput
  cold :=         FuzzySet -5.0 -5.0 -5.0 12.5 "cold" // frio
  tempered :=     FuzzySet  7.5 17.5 17.5 27.5 "tempered" // templado
  heat :=        FuzzySet 22.5 45.0 45.0 45.0 "heat" // calor
  temperature := FuzzyInput "temperature"
  temperature.add_all_sets [cold, tempered, heat]
  fuzzy.add_input temperature
  // FuzzyInput
  summer :=       FuzzySet 0.0  0.0  0.0  3.5 "summer" // summer
  fall :=        FuzzySet 2.5  4.5  4.5  6.5 "fall" // fall
  winter :=     FuzzySet 5.5  7.5  7.5  9.5 "winter" // winter
  spring :=    FuzzySet 8.5 12.0 12.0 12.0 "spring" // spring
  season := FuzzyInput "season" // season
  season.add_all_sets [summer, fall, winter, spring]
  fuzzy.add_input season

  // FuzzyOutput
  anys :=         FuzzySet  0.0  0.0  0.0  0.0 "anys" // any
  very_little :=      FuzzySet  0.0  0.0  0.0  5.5 "very_little" // muy poco
  little_bit :=         FuzzySet  4.5  7.5  7.5 10.5 "little_bit" // poco
  medium :=        FuzzySet  9.5 12.5 12.5 15.5 "medium" // medium
  quite :=     FuzzySet 14.5 17.5 17.5 20.5 "quite" // quite
  much :=        FuzzySet 19.5 22.5 22.5 25.5 "much" // much
  very_much :=    FuzzySet 24.5 30.0 30.0 30.0 "very_much" // very_much
  weather := FuzzyOutput "weather" // weather
  weather.add_all_sets [anys, very_little, little_bit, medium, quite, much, very_much]
  fuzzy.add_output weather

  rule_template := : |set_a set_b set_c output|
      fuzzy.add_rule (FuzzyRule (Antecedent.AND_ante_set (Antecedent.AND_sets set_a set_b) set_c) (Consequent.output output))

  rule_template.call   dry cold summer              medium
  rule_template.call   dry cold fall               very_little
  rule_template.call   dry cold winter            very_little
  rule_template.call   dry cold spring           very_little
  rule_template.call   wet cold summer            very_little
  rule_template.call   wet cold fall             very_little
  rule_template.call   wet cold winter          very_little
  rule_template.call   wet cold spring         very_little
  rule_template.call   puddled cold spring     anys
  rule_template.call   puddled cold fall         anys
  rule_template.call  puddled cold winter      anys
  rule_template.call  puddled cold spring     anys
  rule_template.call  dry tempered summer          quite
  rule_template.call  dry tempered fall           medium
  rule_template.call  dry tempered winter        little_bit
  rule_template.call  dry tempered spring       quite
  rule_template.call  wet tempered summer        medium
  rule_template.call  wet tempered fall         little_bit
  rule_template.call  wet tempered winter      little_bit
  rule_template.call  wet tempered spring     medium
  rule_template.call  puddled tempered spring very_little
  rule_template.call  puddled tempered fall     anys
  rule_template.call  puddled tempered winter  anys
  rule_template.call  puddled tempered spring very_little
  rule_template.call  dry heat summer             much
  rule_template.call  dry heat fall              medium
  rule_template.call  dry heat winter           medium
  rule_template.call  dry heat spring          much
  rule_template.call  wet heat summer           quite
  rule_template.call  wet heat fall            quite
  rule_template.call  wet heat winter         quite
  rule_template.call  wet heat spring        medium
  rule_template.call  puddled heat summer       very_little
  rule_template.call  puddled heat fall        anys
  rule_template.call  puddled heat winter     anys
  rule_template.call  puddled heat spring    very_little
  
  return fuzzy