
import btest show *

import fuzzy-logic show FuzzyModel Composition FuzzyInput FuzzyOutput FuzzySet FuzzyRule Antecedent Consequent TriangularSet TrapezoidalSet LTrapezoidalSet RTrapezoidalSet Ante-AND-Terms
/*
import fuzzy_model show FuzzyModel
import composition show Composition
import fuzzy_input show FuzzyInput
import fuzzy_output show FuzzyOutput
import fuzzy_set show FuzzySet
import fuzzy_rule show FuzzyRule
import antecedent show Antecedent
import consequent show Consequent

import set_triangular show TriangularSet
import set_trapezoidal show TrapezoidalSet
import set_trapezoidal_l show LTrapezoidalSet
import set_trapezoidal_r show RTrapezoidalSet
*/

// From: http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.486.1238&rep=rep1&type=pdf

main:

    test-start

    test "Fuzzy" "testFromLectureSystemsTwo":

        fuzzy := FuzzyModel

        // FuzzyInput
        veryLow :=  FuzzySet 5.0 5.0 5.0 15.0
        low :=      FuzzySet 10.0 20.0 20.0 30.0
        high :=     FuzzySet 25.0 30.0 30.0 35.0
        veryHigh := FuzzySet 30.0 50.0 50.0 50.0
        temperature := FuzzyInput "temperature"
        temperature.add-all-sets [veryLow, low, high, veryHigh]
        fuzzy.add-input temperature

        // FuzzyInput
        dry :=          FuzzySet 5.0 5.0 5.0 30.0
        comfortable :=  FuzzySet 20.0 35.0 35.0 50.0
        humid :=        FuzzySet 40.0 55.0 55.0 70.0
        sticky :=       FuzzySet 60.0 100.0 100.0 100.0
        humidity := FuzzyInput "humidity"
        humidity.add-all-sets [dry, comfortable, humid, sticky]
        fuzzy.add-input humidity

        // FuzzyOutput
        off :=          FuzzySet 0.0 0.0 0.0 0.0
        lowHumidity :=  FuzzySet 30.0 45.0 45.0 60.0
        medium :=       FuzzySet 50.0 65.0 65.0 80.0
        fast :=         FuzzySet 70.0 90.0 95.0 95.0
        speed := FuzzyOutput "speed"
        speed.add-all-sets [off, lowHumidity, medium, fast]
        fuzzy.add-output speed

        // Building FuzzyRules
        fuzzy.add-rule (FuzzyRule.fl-if (Ante-AND-Terms veryLow dry) --fl-then=(Consequent.output off))
        fuzzy.add-rule (FuzzyRule.fl-if (Ante-AND-Terms veryLow comfortable) --fl-then=(Consequent.output off))
        fuzzy.add-rule (FuzzyRule.fl-if (Ante-AND-Terms veryLow humid) --fl-then=(Consequent.output off))
        fuzzy.add-rule (FuzzyRule.fl-if (Ante-AND-Terms veryLow sticky) --fl-then=(Consequent.output lowHumidity))
        fuzzy.add-rule (FuzzyRule.fl-if (Ante-AND-Terms low dry) --fl-then=(Consequent.output off))
        fuzzy.add-rule (FuzzyRule.fl-if (Ante-AND-Terms low comfortable) --fl-then=(Consequent.output off))
        fuzzy.add-rule (FuzzyRule.fl-if (Ante-AND-Terms low humid) --fl-then=(Consequent.output lowHumidity))
        fuzzy.add-rule (FuzzyRule.fl-if (Ante-AND-Terms low sticky) --fl-then=(Consequent.output medium))
        fuzzy.add-rule (FuzzyRule.fl-if (Ante-AND-Terms high dry) --fl-then=(Consequent.output lowHumidity))
        fuzzy.add-rule (FuzzyRule.fl-if (Ante-AND-Terms high comfortable) --fl-then=(Consequent.output medium))
        fuzzy.add-rule (FuzzyRule.fl-if (Ante-AND-Terms high humid) --fl-then=(Consequent.output fast))
        fuzzy.add-rule (FuzzyRule.fl-if (Ante-AND-Terms high sticky) --fl-then=(Consequent.output fast))
        fuzzy.add-rule (FuzzyRule.fl-if (Ante-AND-Terms veryHigh dry) --fl-then=(Consequent.output medium))
        fuzzy.add-rule (FuzzyRule.fl-if (Ante-AND-Terms veryHigh comfortable) --fl-then=(Consequent.output fast))
        fuzzy.add-rule (FuzzyRule.fl-if (Ante-AND-Terms veryHigh humid) --fl-then=(Consequent.output fast))
        fuzzy.add-rule (FuzzyRule.fl-if (Ante-AND-Terms veryHigh sticky) --fl-then=(Consequent.output fast))
        // run it
        fuzzy.crisp-input 0 20.0
        fuzzy.crisp-input 1 65.0
        fuzzy.changed
        fuzzy.fuzzify

        expect-near 50.568535 (fuzzy.defuzzify 0) // This value was not extracted from the paper

    test-end


    /*
        if_VeryLowAndDry := Ante-AND-Terms veryLow dry
        then_Off1 := Consequent.output off
        fuzzyRule0 := FuzzyRule.fl-if if_VeryLowAndDry --fl-then=then_Off1 --name="0"
        fuzzy.add-rule fuzzyRule0

        if_VeryLowAndComfortable := Ante-AND-Terms veryLow comfortable
        then_Off2 := Consequent.output off
        fuzzyRule1 := FuzzyRule.fl-if if_VeryLowAndComfortable --fl-then=then_Off2 --name="1"
        fuzzy.add-rule fuzzyRule1

        if_VeryLowAndHumid := Ante-AND-Terms veryLow humid
        then_Off3 := Consequent.output off
        fuzzyRule2 := FuzzyRule.fl-if if_VeryLowAndHumid --fl-then=then_Off3 --name="2"
        fuzzy.add-rule fuzzyRule2

        if_VeryLowAndSticky := Ante-AND-Terms veryLow sticky
        then_Low1 := Consequent.output lowHumidity
        fuzzyRule3 := FuzzyRule.fl-if if_VeryLowAndSticky --fl-then=then_Low1 --name="3"
        fuzzy.add-rule fuzzyRule3

        if_LowAndDry := Ante-AND-Terms low dry
        then_Off4 := Consequent.output off
        fuzzyRule4 := FuzzyRule.fl-if if_LowAndDry --fl-then=then_Off4 --name="4"
        fuzzy.add-rule fuzzyRule4

        if_LowAndComfortable := Ante-AND-Terms low comfortable
        then_Off5 := Consequent.output off
        fuzzyRule5 := FuzzyRule.fl-if if_LowAndComfortable --fl-then=then_Off5 --name="5"
        fuzzy.add-rule fuzzyRule5

        if_LowAndHumid := Ante-AND-Terms low humid
        then_Low2 := Consequent.output lowHumidity
        fuzzyRule6 := FuzzyRule.fl-if if_LowAndHumid --fl-then=then_Low2 --name="6"
        fuzzy.add-rule fuzzyRule6

        if_LowAndSticky := Ante-AND-Terms low sticky
        then_Medium1 := Consequent.output medium
        fuzzyRule7 := FuzzyRule.fl-if if_LowAndSticky --fl-then=then_Medium1 --name="7"
        fuzzy.add-rule fuzzyRule7

        if_HighAndDry := Ante-AND-Terms high dry
        then_Low3 := Consequent.output lowHumidity
        fuzzyRule8 := FuzzyRule.fl-if if_HighAndDry --fl-then=then_Low3 --name="8"
        fuzzy.add-rule fuzzyRule8

        if_HighAndComfortable := Ante-AND-Terms high comfortable
        then_Medium2 := Consequent.output medium
        fuzzyRule9 := FuzzyRule.fl-if if_HighAndComfortable --fl-then=then_Medium2 --name="9"
        fuzzy.add-rule fuzzyRule9

        if_HighAndHumid := Ante-AND-Terms high humid
        then_Fast1 := Consequent.output fast
        fuzzyRule10 := FuzzyRule.fl-if if_HighAndHumid --fl-then=then_Fast1 --name="10"
        fuzzy.add-rule fuzzyRule10

        if_HighAndSticky := Ante-AND-Terms high sticky
        then_Fast2 := Consequent.output fast
        fuzzyRule11 := FuzzyRule.fl-if if_HighAndSticky --fl-then=then_Fast2 --name="11"
        fuzzy.add-rule fuzzyRule11

        if_VeryHighAndDry := Ante-AND-Terms veryHigh dry
        then_Medium3 := Consequent.output medium
        fuzzyRule12 := FuzzyRule.fl-if if_VeryHighAndDry --fl-then=then_Medium3 --name="12"
        fuzzy.add-rule fuzzyRule12

        if_VeryHighAndComfortable := Ante-AND-Terms veryHigh comfortable
        then_Fast3 := Consequent.output fast
        fuzzyRule13 := FuzzyRule.fl-if if_VeryHighAndComfortable --fl-then=then_Fast3 --name="13"
        fuzzy.add-rule fuzzyRule13
  
        if_VeryHighAndHumid := Ante-AND-Terms veryHigh humid
        then_Fast4 := Consequent.output fast
        fuzzyRule14 := FuzzyRule.fl-if if_VeryHighAndHumid --fl-then=then_Fast4 --name="14"
        fuzzy.add-rule fuzzyRule14

        if_VeryHighAndSticky := Ante-AND-Terms veryHigh sticky
        then_Fast5 := Consequent.output fast
        fuzzyRule15 := FuzzyRule.fl-if if_VeryHighAndSticky --fl-then=then_Fast5 --name="15"
        fuzzy.add-rule fuzzyRule15
*/