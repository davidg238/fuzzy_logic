// Copyright 2021 Ekorau LLC

import fuzzy_model show FuzzyModel
import fuzzy_input show FuzzyInput
import fuzzy_output show FuzzyOutput
import fuzzy_set show FuzzySet
import fuzzy_rule show FuzzyRule
import antecedent show Antecedent
import consequent show Consequent

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
    distance := FuzzyInput 0
    distance.add_set near
    distance.add_set safe
    distance.add_set distant

    // FuzzyInput
    speedInput := FuzzyInput 1
    speedInput.add_set stoppedInput
    speedInput.add_set slowInput
    speedInput.add_set normalInput
    speedInput.add_set quickInput

    // FuzzyInput
    temperature := FuzzyInput 2
    temperature.add_set cold
    temperature.add_set good
    temperature.add_set hot

    // FuzzyOutput
    risk := FuzzyOutput 0
    risk.add_set minimum
    risk.add_set average
    risk.add_set maximum

    // FuzzyOutput
    speedOutput :=  FuzzyOutput 1
    speedOutput.add_set stoppedOutput 
    speedOutput.add_set slowOutput
    speedOutput.add_set normalOutput
    speedOutput.add_set quickOutput


    distanceNearAndSpeedQuick := Antecedent.AND_sets near quickInput
    temperatureCold := Antecedent.set cold
    if_DistanceNearAndSpeedQuickOrTempCold := Antecedent.OR_ante_ante distanceNearAndSpeedQuick temperatureCold

    then_RiskMaxAndSpeedSlow := Consequent.output maximum
    then_RiskMaxAndSpeedSlow.add_output slowOutput

    rule0 := FuzzyRule 0 if_DistanceNearAndSpeedQuickOrTempCold then_RiskMaxAndSpeedSlow
    

    distanceSafeAndSpeedNormal := Antecedent.AND_sets safe normalInput
    if_DistanceSafeAndSpeedNormalOrTemperatureGood := Antecedent.OR_ante_set distanceSafeAndSpeedNormal good

    then_RiskAverageAndSpeedNormal := Consequent.output average
    then_RiskAverageAndSpeedNormal.add_output normalOutput

    rule1 := FuzzyRule 1 if_DistanceSafeAndSpeedNormalOrTemperatureGood then_RiskAverageAndSpeedNormal

    
    distanceDistantAndSpeedSlow := Antecedent.AND_sets distant slowInput
    if_DistanceDistantAndSpeedSlowOrTemperatureHot := Antecedent.OR_ante_set distanceDistantAndSpeedSlow hot

    then_RiskMinimumSpeedQuick := Consequent.output minimum
    then_RiskMinimumSpeedQuick.add_output quickOutput

    rule2 :=  FuzzyRule 2 if_DistanceDistantAndSpeedSlowOrTemperatureHot then_RiskMinimumSpeedQuick
    
    model := FuzzyModel
    model.add_input distance
    model.add_input speedInput
    model.add_input temperature
    model.add_output risk
    model.add_output speedOutput
    model.add_rule rule0
    model.add_rule rule1
    model.add_rule rule2

    print "about to loop ..."
    10.repeat:
        // get random entrances
        input0 := random 0 100
        input1 := random 0 70
        input2 := random -30 30

        print "---------------------------- "
        print "Distance: $(%.2f input0)  Speed: $(%.2f input1) Temperature: $(%.2f input2)"

        model.set_input 0 input0.to_float
        model.set_input 1 input1.to_float
        model.set_input 2 input2.to_float

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
        sleep --ms=5000