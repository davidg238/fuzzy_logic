import fuzzy-logic show *

/*
Pretty ugly, but no models in memory until requested.
Could have used Map + block.call ,but to be replaced with FCL parser.
*/

model-names -> List:
  return ["driver", "driver_advanced", "casco", "fan-speed"]

get-model name/string -> FuzzyModel?:
  if name == "driver":
    return get-driver
  else if name == "driver_advanced":
    return get-driver-advanced
  else if name == "casco":
    return get-casco
  else if name == "fan-speed":
    return get-fan-speed
  else:
    return null

get-driver -> FuzzyModel:    
  small := FuzzySet 0.0 20.0 20.0 40.0 "small"
  safe  := FuzzySet 30.0 50.0 50.0 70.0 "safe"
  big   := FuzzySet 60.0 80.0 100.0 100.0 "big"    //60.0 80.0 80.0 80.0 "big"  originally !
  distance := FuzzyInput "distance"
  distance.add-set small
  distance.add-set safe
  distance.add-set big

  slow    := FuzzySet 0.0 10.0 10.0 20.0 "slow"
  average := FuzzySet 10.0 20.0 30.0 40.0 "average"
  fast    := FuzzySet 30.0 40.0 40.0 50.0 "fast"
  speed := FuzzyOutput "speed"
  speed.add-set slow
  speed.add-set average
  speed.add-set fast

  rule-01 := FuzzyRule (Antecedent.set small) (Consequent.output slow)     // "IF distance = small THEN speed = slow"
  rule-02 := FuzzyRule (Antecedent.set safe) (Consequent.output average)   // "IF distance = safe THEN speed = average"
  rule-03 := FuzzyRule (Antecedent.set big) (Consequent.output fast)       // "IF distance = big THEN speed = high"

  model := FuzzyModel "driver"
  model.add-input distance
  model.add-output speed
  model.add-rule rule-01
  model.add-rule rule-02
  model.add-rule rule-03

  return model

get-driver-advanced -> FuzzyModel:
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
    distance.add-set near
    distance.add-set safe
    distance.add-set distant

    // FuzzyInput
    speedInput := FuzzyInput "speed"
    speedInput.add-set stoppedInput
    speedInput.add-set slowInput
    speedInput.add-set normalInput
    speedInput.add-set quickInput

    // FuzzyInput
    temperature := FuzzyInput "temperature"
    temperature.add-set cold
    temperature.add-set good
    temperature.add-set hot

    // FuzzyOutput
    risk := FuzzyOutput "risk"
    risk.add-set minimum
    risk.add-set average
    risk.add-set maximum

    // FuzzyOutput
    speedOutput :=  FuzzyOutput "throttle"
    speedOutput.add-set stoppedOutput 
    speedOutput.add-set slowOutput
    speedOutput.add-set normalOutput
    speedOutput.add-set quickOutput


    distanceNearAndSpeedQuick := Antecedent.AND-sets near quickInput
    temperatureCold := Antecedent.set cold
    if-DistanceNearAndSpeedQuickOrTempCold := Antecedent.OR-ante-ante distanceNearAndSpeedQuick temperatureCold

    then-RiskMaxAndSpeedSlow := Consequent.output maximum
    then-RiskMaxAndSpeedSlow.add-output slowOutput

    rule0 := FuzzyRule if-DistanceNearAndSpeedQuickOrTempCold then-RiskMaxAndSpeedSlow
    

    distanceSafeAndSpeedNormal := Antecedent.AND-sets safe normalInput
    if-DistanceSafeAndSpeedNormalOrTemperatureGood := Antecedent.OR-ante-set distanceSafeAndSpeedNormal good

    then-RiskAverageAndSpeedNormal := Consequent.output average
    then-RiskAverageAndSpeedNormal.add-output normalOutput

    rule1 := FuzzyRule if-DistanceSafeAndSpeedNormalOrTemperatureGood then-RiskAverageAndSpeedNormal

    
    distanceDistantAndSpeedSlow := Antecedent.AND-sets distant slowInput
    if-DistanceDistantAndSpeedSlowOrTemperatureHot := Antecedent.OR-ante-set distanceDistantAndSpeedSlow hot

    then-RiskMinimumSpeedQuick := Consequent.output minimum
    then-RiskMinimumSpeedQuick.add-output quickOutput

    rule2 :=  FuzzyRule if-DistanceDistantAndSpeedSlowOrTemperatureHot then-RiskMinimumSpeedQuick
    
    model := FuzzyModel "driver_advanced"
    model.add-input distance
    model.add-input speedInput
    model.add-input temperature
    model.add-output risk
    model.add-output speedOutput
    model.add-rule rule0
    model.add-rule rule1
    model.add-rule rule2

    return model

get-casco -> FuzzyModel:

  fuzzy := FuzzyModel "casco"
  // FuzzyInput
  dry :=       FuzzySet  0.0   0.0   0.0  42.5  "dry" // seco
  wet :=       FuzzySet 37.5  60.0  60.0  82.5  "wet" // humedo
  puddled :=   FuzzySet 77.5 100.0 100.0 100.0  "puddled" // charco
  humidity := FuzzyInput "humidity"             // humedad  
  humidity.add-all-sets [dry, wet, puddled]
  fuzzy.add-input humidity
  // FuzzyInput
  cold :=         FuzzySet -5.0 -5.0 -5.0 12.5 "cold" // frio
  tempered :=     FuzzySet  7.5 17.5 17.5 27.5 "tempered" // templado
  heat :=        FuzzySet 22.5 45.0 45.0 45.0 "heat" // calor
  temperature := FuzzyInput "temperature"
  temperature.add-all-sets [cold, tempered, heat]
  fuzzy.add-input temperature
  // FuzzyInput
  summer :=       FuzzySet 0.0  0.0  0.0  3.5 "summer" // summer
  fall :=        FuzzySet 2.5  4.5  4.5  6.5 "fall" // fall
  winter :=     FuzzySet 5.5  7.5  7.5  9.5 "winter" // winter
  spring :=    FuzzySet 8.5 12.0 12.0 12.0 "spring" // spring
  season := FuzzyInput "season" // season
  season.add-all-sets [summer, fall, winter, spring]
  fuzzy.add-input season

  // FuzzyOutput
  anys :=         FuzzySet  0.0  0.0  0.0  0.0 "anys" // any
  very-little :=      FuzzySet  0.0  0.0  0.0  5.5 "very_little" // muy poco
  little-bit :=         FuzzySet  4.5  7.5  7.5 10.5 "little_bit" // poco
  medium :=        FuzzySet  9.5 12.5 12.5 15.5 "medium" // medium
  quite :=     FuzzySet 14.5 17.5 17.5 20.5 "quite" // quite
  much :=        FuzzySet 19.5 22.5 22.5 25.5 "much" // much
  very-much :=    FuzzySet 24.5 30.0 30.0 30.0 "very_much" // very_much
  weather := FuzzyOutput "weather" // weather
  weather.add-all-sets [anys, very-little, little-bit, medium, quite, much, very-much]
  fuzzy.add-output weather

  rule-template := : |set-a set-b set-c output|
      fuzzy.add-rule (FuzzyRule (Antecedent.AND-ante-set (Antecedent.AND-sets set-a set-b) set-c) (Consequent.output output))

  rule-template.call  dry cold summer           medium
  rule-template.call  dry cold fall             very-little
  rule-template.call  dry cold winter           very-little
  rule-template.call  dry cold spring           very-little
  rule-template.call  wet cold summer           very-little
  rule-template.call  wet cold fall             very-little
  rule-template.call  wet cold winter           very-little
  rule-template.call  wet cold spring           very-little
  rule-template.call  puddled cold spring       anys
  rule-template.call  puddled cold fall         anys
  rule-template.call  puddled cold winter       anys
  rule-template.call  puddled cold spring       anys
  rule-template.call  dry tempered summer       quite
  rule-template.call  dry tempered fall         medium
  rule-template.call  dry tempered winter       little-bit
  rule-template.call  dry tempered spring       quite
  rule-template.call  wet tempered summer       medium
  rule-template.call  wet tempered fall         little-bit
  rule-template.call  wet tempered winter       little-bit
  rule-template.call  wet tempered spring       medium
  rule-template.call  puddled tempered spring   very-little
  rule-template.call  puddled tempered fall     anys
  rule-template.call  puddled tempered winter   anys
  rule-template.call  puddled tempered spring   very-little
  rule-template.call  dry heat summer           much
  rule-template.call  dry heat fall             medium
  rule-template.call  dry heat winter           medium
  rule-template.call  dry heat spring           much
  rule-template.call  wet heat summer           quite
  rule-template.call  wet heat fall             quite
  rule-template.call  wet heat winter           quite
  rule-template.call  wet heat spring           medium
  rule-template.call  puddled heat summer       very-little
  rule-template.call  puddled heat fall         anys
  rule-template.call  puddled heat winter       anys
  rule-template.call  puddled heat spring       very-little
  
  return fuzzy

get-fan-speed -> FuzzyModel:
  fuzzy := FuzzyModel "fan-speed"
  // FuzzyInput
  temperature := FuzzyInput "termperature"
  veryLow :=  FuzzySet -5 -5 0 15 "veryLow"
  low := FuzzySet 10 20 20 30 "low"
  high := FuzzySet 25 30 30 35 "high"
  veryHigh := FuzzySet 30 45 50 50 "veryHigh"
  temperature.add-all-sets [veryLow, low, high, veryHigh]
  fuzzy.add-input temperature

  humidity := FuzzyInput "humidity"
  dry := FuzzySet -5 -5 0 30 "dry"
  comfortable := FuzzySet 20 35 35 50 "comfortable"
  humid := FuzzySet 40 55 55 70 "humid"
  sticky := FuzzySet 60 100 105 105 "sticky"
  humidity.add-all-sets [dry, comfortable, humid, sticky]
  fuzzy.add-input humidity

  speed := FuzzyOutput "speed"
  off := FuzzySet 0 0 0 0 "off"
  lowHumidity := FuzzySet 30 45 45 60 "lowHumidity"
  medium := FuzzySet 50 65 65 80 "medium"
  fast := FuzzySet 70 90 95 95 "fast"
  speed.add-all-sets [off, lowHumidity, medium, fast]
  fuzzy.add-output speed
  
  fuzzy.add-rule (FuzzyRule (Antecedent.AND-sets veryLow dry)          (Consequent.output off))
  fuzzy.add-rule (FuzzyRule (Antecedent.AND-sets veryLow comfortable)  (Consequent.output off))
  fuzzy.add-rule (FuzzyRule (Antecedent.AND-sets veryLow humid)        (Consequent.output off))
  fuzzy.add-rule (FuzzyRule (Antecedent.AND-sets veryLow sticky)       (Consequent.output lowHumidity))
  fuzzy.add-rule (FuzzyRule (Antecedent.AND-sets low dry)              (Consequent.output off))
  fuzzy.add-rule (FuzzyRule (Antecedent.AND-sets low comfortable)      (Consequent.output off))
  fuzzy.add-rule (FuzzyRule (Antecedent.AND-sets low humid)            (Consequent.output lowHumidity))
  fuzzy.add-rule (FuzzyRule (Antecedent.AND-sets low sticky)           (Consequent.output medium))
  fuzzy.add-rule (FuzzyRule (Antecedent.AND-sets high dry)             (Consequent.output lowHumidity))
  fuzzy.add-rule (FuzzyRule (Antecedent.AND-sets high comfortable)     (Consequent.output medium))
  fuzzy.add-rule (FuzzyRule (Antecedent.AND-sets high humid)           (Consequent.output fast))
  fuzzy.add-rule (FuzzyRule (Antecedent.AND-sets high sticky)          (Consequent.output fast))
  fuzzy.add-rule (FuzzyRule (Antecedent.AND-sets veryHigh dry)         (Consequent.output medium))
  fuzzy.add-rule (FuzzyRule (Antecedent.AND-sets veryHigh comfortable) (Consequent.output fast))
  fuzzy.add-rule (FuzzyRule (Antecedent.AND-sets veryHigh humid)       (Consequent.output fast))
  fuzzy.add-rule (FuzzyRule (Antecedent.AND-sets veryHigh sticky)      (Consequent.output fast))

  return fuzzy