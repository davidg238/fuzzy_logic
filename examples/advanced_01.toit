// Copyright 2021 Ekorau LLC

import fuzzy-logic show *
main:

    // FuzzyInput
    near := FuzzySet 0.0 20.0 20.0 40.0
    safe := FuzzySet 30.0 50.0 50.0 70.0
    distant := FuzzySet 60.0 80.0 100.0 100.0

    // FuzzyInput
    stoppedInput := FuzzySet 0.0 0.0 0.0 0.0
    slowInput := FuzzySet 1.0 10.0 10.0 20.0
    normalInput := FuzzySet 15.0 30.0 30.0 50.0
    quickInput := FuzzySet 45.0 60.0 70.0 70.0

    // FuzzyInput
    cold :=  FuzzySet -30.0 -30.0 -20.0 -10.0
    good :=  FuzzySet -15.0 0.0 0.0 15.0
    hot :=  FuzzySet 10.0 20.0 30.0 30.0

    // FuzzyOutput
    minimum :=  FuzzySet 0.0 20.0 20.0 40.0
    average :=  FuzzySet 30.0 50.0 50.0 70.0
    maximum :=  FuzzySet 60.0 80.0 80.0 100.0

    // FuzzyOutput
    stoppedOutput :=  FuzzySet 0.0 0.0 0.0 0.0
    slowOutput := FuzzySet 1.0 10.0 10.0 20.0
    normalOutput := FuzzySet 15.0 30.0 30.0 50.0
    quickOutput := FuzzySet 45.0 60.0 70.0 70.0

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
    speedOutput :=  FuzzyOutput "speed"
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

    //print "about to loop ..."
    // 10.repeat:
        // get random entrances
    input0 := 51 // random 0 100
    input1 := 47 // random 0 70
    input2 := 55 // random -30 30

    print "---------------------------- "
    print "Distance: $(%.2f input0)  Speed: $(%.2f input1) Temperature: $(%.2f input2)"

    model.crisp-input 0 input0
    model.crisp-input 1 input1
    model.crisp-input 2 input2
    model.changed
    model.fuzzify

    print "Input: "
    print "Distance: Near-> $(%.2f near.pertinence) Safe-> $(%.2f safe.pertinence) Distant-> $(%.2f distant.pertinence)"
    print "Speed: Stopped-> $(%.2f stoppedInput.pertinence) Slow-> $(%.2f slowInput.pertinence) Normal-> $(%.2f normalInput.pertinence) Quick-> $(%.2f quickInput.pertinence)"
    print "Temperature: Cold-> $(%.2f cold.pertinence) Good-> $(%.2f good.pertinence) Hot-> $(%.2f hot.pertinence)"

    output0 := model.defuzzify 0
    output1 := model.defuzzify 1

    print "Output: "
    print "Risk: Minimum-> $(%.2f minimum.pertinence) Average-> $(%.2f average.pertinence) Maximum-> $(%.2f maximum.pertinence)"
    print "Speed: Stopped-> $(%.2f stoppedOutput.pertinence) Slow-> $(%.2f slowOutput.pertinence) Normal-> $(%.2f normalOutput.pertinence) Quick-> $(%.2f quickOutput.pertinence)"

    print "Result ---->  Risk: $(%.2f output0) and Speed: $(%.2f output1)"
    // sleep --ms=5000