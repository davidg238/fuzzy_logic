import fuzzy-logic show *

/*
Pretty ugly, but no models in memory until requested.
Could have used Map + block.call ,but to be replaced with FCL parser.
*/

model-names -> List:
  return ["driver", "driver_advanced", "casco", "fan-speed", "air-conditioning", "container-crane"]

get-model name/string -> FuzzyModel?:
  if name == "driver":
    return get-driver
  else if name == "driver_advanced":
    return get-driver-advanced
  else if name == "casco":
    return get-casco
  else if name == "fan-speed":
    return get-fan-speed
  else if name == "air-conditioning": 
    return get-air-conditioning
  else if name == "container-crane":
    return get-container-crane
  else:
    return null

get-driver -> FuzzyModel:    
  small := FuzzySet 0.0 20.0 20.0 40.0 "small"
  safe  := FuzzySet 30.0 50.0 50.0 70.0 "safe"
  big   := FuzzySet 60.0 80.0 100.0 100.0 "big"    //60.0 80.0 80.0 80.0 "big"  originally !
  distance := FuzzyInput.sets [small, safe, big] --name="distance"

  slow    := FuzzySet 0.0 10.0 10.0 20.0 "slow"
  average := FuzzySet 10.0 20.0 30.0 40.0 "average"
  fast    := FuzzySet 30.0 40.0 40.0 50.0 "fast"
  speed := FuzzyOutput.sets [slow, average, fast] --name="speed"

  rule-01 := FuzzyRule.fl-if (Antecedent.fl-set small) --fl-then=(Consequent.output slow)     // "IF distance = small THEN speed = slow"
  rule-02 := FuzzyRule.fl-if (Antecedent.fl-set safe) --fl-then=(Consequent.output average)   // "IF distance = safe THEN speed = average"
  rule-03 := FuzzyRule.fl-if (Antecedent.fl-set big) --fl-then=(Consequent.output fast)       // "IF distance = big THEN speed = high"

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
    distance := FuzzyInput.sets [near, safe, distant] --name="distance"
    speedInput := FuzzyInput.sets [stoppedInput, slowInput, normalInput, quickInput] --name="speed"
    temperature := FuzzyInput.sets [cold, good, hot] --name="temperature"

    // FuzzyOutput
    risk := FuzzyOutput.sets [minimum, average, maximum] --name="risk"
    speedOutput :=  FuzzyOutput.sets [stoppedOutput, slowOutput, normalOutput, quickOutput] --name="throttle"

    rule0 := FuzzyRule.fl-if (Antecedent.fl-or (Antecedent.fl-or near quickInput) (Antecedent.fl-set cold)) --fl-then=(Consequent.output maximum)
    rule1 := FuzzyRule.fl-if (Antecedent.fl-or (Antecedent.fl-and safe normalInput) good) --fl-then=(Consequent.outputs [average, normalOutput])
    rule2 := FuzzyRule.fl-if (Antecedent.fl-or (Antecedent.fl-and distant slowInput) hot) --fl-then=(Consequent.outputs [minimum, quickOutput])
    
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
  humidity := FuzzyInput.sets [dry, wet, puddled] --name="humidity"             // humedad  
  fuzzy.add-input humidity
  // FuzzyInput
  cold :=         FuzzySet -5.0 -5.0 -5.0 12.5 "cold" // frio
  tempered :=     FuzzySet  7.5 17.5 17.5 27.5 "tempered" // templado
  heat :=        FuzzySet 22.5 45.0 45.0 45.0 "heat" // calor
  temperature := FuzzyInput.sets [cold, tempered, heat] --name="temperature"
  fuzzy.add-input temperature
  // FuzzyInput
  summer :=       FuzzySet 0.0  0.0  0.0  3.5 "summer" // summer
  fall :=        FuzzySet 2.5  4.5  4.5  6.5 "fall" // fall
  winter :=     FuzzySet 5.5  7.5  7.5  9.5 "winter" // winter
  spring :=    FuzzySet 8.5 12.0 12.0 12.0 "spring" // spring
  season := FuzzyInput.sets [summer, fall, winter, spring] --name= "season" // season
  fuzzy.add-input season

  // FuzzyOutput
  anys :=         FuzzySet  0.0  0.0  0.0  0.0 "anys" // any
  very-little :=      FuzzySet  0.0  0.0  0.0  5.5 "very_little" // muy poco
  little-bit :=         FuzzySet  4.5  7.5  7.5 10.5 "little_bit" // poco
  medium :=        FuzzySet  9.5 12.5 12.5 15.5 "medium" // medium
  quite :=     FuzzySet 14.5 17.5 17.5 20.5 "quite" // quite
  much :=        FuzzySet 19.5 22.5 22.5 25.5 "much" // much
  very-much :=    FuzzySet 24.5 30.0 30.0 30.0 "very_much" // very_much
  weather := FuzzyOutput.sets [anys, very-little, little-bit, medium, quite, much, very-much] --name="weather" // weather
  fuzzy.add-output weather

  rule-template := : |seta setb setc out|
      fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and (Antecedent.fl-and seta setb) setc) --fl-then=(Consequent.output out))

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

  veryLow :=  FuzzySet -5 -5 0 15 "veryLow"
  low := FuzzySet 10 20 20 30 "low"
  high := FuzzySet 25 30 30 35 "high"
  veryHigh := FuzzySet 30 45 50 50 "veryHigh"
  temperature := FuzzyInput.sets [veryLow, low, high, veryHigh] --name="termperature"
  fuzzy.add-input temperature

  dry := FuzzySet -5 -5 0 30 "dry"
  comfortable := FuzzySet 20 35 35 50 "comfortable"
  humid := FuzzySet 40 55 55 70 "humid"
  sticky := FuzzySet 60 100 105 105 "sticky"
  humidity := FuzzyInput.sets [dry, comfortable, humid, sticky] --name="humidity"
  fuzzy.add-input humidity

  off := FuzzySet 0 0 0 0 "off"
  lowHumidity := FuzzySet 30 45 45 60 "lowHumidity"
  medium := FuzzySet 50 65 65 80 "medium"
  fast := FuzzySet 70 90 95 95 "fast"
  speed := FuzzyOutput.sets [off, lowHumidity, medium, fast] --name="speed"
  fuzzy.add-output speed
  
  fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and veryLow dry)          --fl-then=(Consequent.output off))
  fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and veryLow comfortable)  --fl-then=(Consequent.output off))
  fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and veryLow humid)        --fl-then=(Consequent.output off))
  fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and veryLow sticky)       --fl-then=(Consequent.output lowHumidity))
  fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and low dry)              --fl-then=(Consequent.output off))
  fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and low comfortable)      --fl-then=(Consequent.output off))
  fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and low humid)            --fl-then=(Consequent.output lowHumidity))
  fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and low sticky)           --fl-then=(Consequent.output medium))
  fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and high dry)             --fl-then=(Consequent.output lowHumidity))
  fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and high comfortable)     --fl-then=(Consequent.output medium))
  fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and high humid)           --fl-then=(Consequent.output fast))
  fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and high sticky)          --fl-then=(Consequent.output fast))
  fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and veryHigh dry)         --fl-then=(Consequent.output medium))
  fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and veryHigh comfortable) --fl-then=(Consequent.output fast))
  fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and veryHigh humid)       --fl-then=(Consequent.output fast))
  fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and veryHigh sticky)      --fl-then=(Consequent.output fast))

  return fuzzy

get-air-conditioning -> FuzzyModel:

  // From: http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.486.1238&rep=rep1&type=pdf

  fuzzy := FuzzyModel "air-conditioning"

  // FuzzyInput
  veryLow :=  FuzzySet 5.0 5.0 5.0 15.0     "veryLow"
  low :=      FuzzySet 10.0 20.0 20.0 30.0  "low"
  high :=     FuzzySet 25.0 30.0 30.0 35.0  "high"
  veryHigh := FuzzySet 30.0 50.0 50.0 50.0  "veryHigh"
  temperature := FuzzyInput.sets [veryLow, low, high, veryHigh] --name="temperature"
  fuzzy.add-input temperature

  // FuzzyInput
  dry :=          FuzzySet 5.0 5.0 5.0 30.0     "dry"
  comfortable :=  FuzzySet 20.0 35.0 35.0 50.0  "comfortable"
  humid :=        FuzzySet 40.0 55.0 55.0 70.0  "humid"
  sticky :=       FuzzySet 60.0 100.0 100.0 100.0 "sticky"
  humidity := FuzzyInput.sets [dry, comfortable, humid, sticky] --name="humidity"
  fuzzy.add-input humidity

  // FuzzyOutput
  off :=          FuzzySet 0.0 0.0 0.0 0.0      "off"
  lowHumidity :=  FuzzySet 30.0 45.0 45.0 60.0  "lowHumidity"
  medium :=       FuzzySet 50.0 65.0 65.0 80.0  "medium"
  fast :=         FuzzySet 70.0 90.0 95.0 95.0  "fast"
  speed := FuzzyOutput.sets [off, lowHumidity, medium, fast] --name="speed"
  fuzzy.add-output speed

  // Building FuzzyRules
  fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and veryLow dry)          --fl-then=(Consequent.output off))
  fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and veryLow comfortable)  --fl-then=(Consequent.output off))
  fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and veryLow humid)        --fl-then=(Consequent.output off))
  fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and veryLow sticky)       --fl-then=(Consequent.output lowHumidity))
  fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and low dry)              --fl-then=(Consequent.output off))
  fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and low comfortable)      --fl-then=(Consequent.output off))
  fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and low humid)            --fl-then=(Consequent.output lowHumidity))
  fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and low sticky)           --fl-then=(Consequent.output medium))
  fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and high dry)             --fl-then=(Consequent.output lowHumidity))
  fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and high comfortable)     --fl-then=(Consequent.output medium))
  fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and high humid)           --fl-then=(Consequent.output fast))
  fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and high sticky)          --fl-then=(Consequent.output fast))
  fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and veryHigh dry)         --fl-then=(Consequent.output medium))
  fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and veryHigh comfortable) --fl-then=(Consequent.output fast))
  fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and veryHigh humid)       --fl-then=(Consequent.output fast))
  fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and veryHigh sticky)      --fl-then=(Consequent.output fast))

  return fuzzy


get-container-crane -> FuzzyModel:

  // From: https://jfuzzylogic.sourceforge.net/html/pdf/iec_1131_7_cd1.pdf  Fig C.15

  fuzzy := FuzzyModel "container-crane"

  // FuzzyInput
  d-too-far :=  FuzzySet -5 -5 -5 0 "too_far"
  d-zero :=   FuzzySet -5 0 0 5    "d-zero"
  d-close :=    FuzzySet 0 5 5 10    "close"
  d-medium :=   FuzzySet 5 10 10 22    "medium"
  d-far :=      FuzzySet 10 22 22 22       "far"
  distance := FuzzyInput.sets [d-too-far, d-far, d-medium, d-close, d-zero] --name="distance"
  fuzzy.add-input distance

  // FuzzyInput
  a-neg-big :=    FuzzySet -50 -50 -50 -5       "neg-big"
  a-neg-small :=  FuzzySet -50 -5 -5 0    "neg-small"
  a-zero :=     FuzzySet 5 0 0 5    "a-zero"
  a-pos-small :=  FuzzySet 0 5 5 50 "pos-small"
  a-pos-big :=    FuzzySet 5 50 50 50 "pos-big"
  angle := FuzzyInput.sets [a-neg-big, a-neg-small, a-zero, a-pos-small, a-pos-big] --name="angle"
  fuzzy.add-input angle

  // FuzzyOutput
  p-neg-high :=   FuzzySet -27 -27 -27 -27      "neg-high"
  p-neg-medium := FuzzySet -12 -12 -12 -12  "neg-medium"
  p-zero :=       FuzzySet 0 0 0 0   "p-zero"
  p-pos-medium := FuzzySet 12 12 12 12  "pos-medium"
  p-pos-high :=   FuzzySet 27 27 27 27  "pos-high"
  power :=        FuzzyOutput.sets [p-neg-high, p-neg-medium, p-zero, p-pos-medium, p-pos-high] --name="power"
  fuzzy.add-output power

  // Building FuzzyRules
  fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and d-far a-zero)          --fl-then=(Consequent.output p-pos-medium))
  fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and d-far a-neg-small)     --fl-then=(Consequent.output p-pos-high))
  fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and d-far a-neg-big)       --fl-then=(Consequent.output p-pos-medium))
  fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and d-medium a-neg-small)  --fl-then=(Consequent.output p-neg-medium))
  fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and d-close a-pos-small)   --fl-then=(Consequent.output p-pos-medium))
  fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and d-zero a-zero)         --fl-then=(Consequent.output p-zero))

  return fuzzy

  /* Original casco model, in Spanish

        fuzzy := FuzzyModel "casco"
        // FuzzyInput
        seco :=         FuzzySet  0.0   0.0   0.0  42.5
        humedo :=       FuzzySet 37.5  60.0  60.0  82.5
        encharcado :=   FuzzySet 77.5 100.0 100.0 100.0
        humedad := FuzzyInput "humedad"
        humedad.add-all-sets [seco, humedo, encharcado]
        fuzzy.add-input humedad
        // FuzzyInput
        frio :=         FuzzySet -5.0 -5.0 -5.0 12.5
        templado :=     FuzzySet  7.5 17.5 17.5 27.5
        calor :=        FuzzySet 22.5 45.0 45.0 45.0
        temperatura := FuzzyInput "temperatura"
        temperatura.add-all-sets [frio, templado, calor]
        fuzzy.add-input temperatura
        // FuzzyInput
        verano :=       FuzzySet 0.0  0.0  0.0  3.5
        otono :=        FuzzySet 2.5  4.5  4.5  6.5
        invierno :=     FuzzySet 5.5  7.5  7.5  9.5
        primavera :=    FuzzySet 8.5 12.0 12.0 12.0
        mes := FuzzyInput "mes"
        mes.add-all-sets [verano, otono, invierno, primavera]
        fuzzy.add-input mes

        // FuzzyOutput
        nada :=         FuzzySet  0.0  0.0  0.0  0.0
        muyPoco :=      FuzzySet  0.0  0.0  0.0  5.5
        poco :=         FuzzySet  4.5  7.5  7.5 10.5
        medio :=        FuzzySet  9.5 12.5 12.5 15.5
        bastante :=     FuzzySet 14.5 17.5 17.5 20.5
        mucho :=        FuzzySet 19.5 22.5 22.5 25.5
        muchisimo :=    FuzzySet 24.5 30.0 30.0 30.0
        tiempo := FuzzyOutput "tiempo"
        tiempo.add-all-sets [nada, muyPoco, poco, medio, bastante, mucho, muchisimo]
        fuzzy.add-output tiempo

        rule-template := : |id set-a set-b set-c a-output|
            fuzzy.add-rule (FuzzyRule.fl-if (Antecedent.fl-and (Antecedent.fl-and set-a set-b) set-c) --fl-then=(Consequent.output a-output))

        rule-template.call  0 seco frio verano              medio
        rule-template.call  1 seco frio otono               muyPoco
        rule-template.call  2 seco frio invierno            muyPoco
        rule-template.call  3 seco frio primavera           muyPoco
        rule-template.call  4 humedo frio verano            muyPoco
        rule-template.call  5 humedo frio otono             muyPoco
        rule-template.call  6 humedo frio invierno          muyPoco
        rule-template.call  7 humedo frio primavera         muyPoco
        rule-template.call  8 encharcado frio primavera     nada
        rule-template.call  9 encharcado frio otono         nada
        rule-template.call 10 encharcado frio invierno      nada
        rule-template.call 11 encharcado frio primavera     nada
        rule-template.call 12 seco templado verano          bastante
        rule-template.call 13 seco templado otono           medio
        rule-template.call 14 seco templado invierno        poco
        rule-template.call 15 seco templado primavera       bastante
        rule-template.call 16 humedo templado verano        medio
        rule-template.call 17 humedo templado otono         poco
        rule-template.call 18 humedo templado invierno      poco
        rule-template.call 19 humedo templado primavera     medio
        rule-template.call 20 encharcado templado primavera muyPoco
        rule-template.call 21 encharcado templado otono     nada
        rule-template.call 22 encharcado templado invierno  nada
        rule-template.call 23 encharcado templado primavera muyPoco
        rule-template.call 24 seco calor verano             mucho
        rule-template.call 25 seco calor otono              medio
        rule-template.call 26 seco calor invierno           medio
        rule-template.call 27 seco calor primavera          mucho
        rule-template.call 28 humedo calor verano           bastante
        rule-template.call 29 humedo calor otono            bastante
        rule-template.call 30 humedo calor invierno         bastante
        rule-template.call 31 humedo calor primavera        medio
        rule-template.call 32 encharcado calor verano       muyPoco
        rule-template.call 33 encharcado calor otono        nada
        rule-template.call 34 encharcado calor invierno     nada
        rule-template.call 35 encharcado calor primavera    muyPoco
*/