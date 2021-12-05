
import .test_util show *

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


// From: http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.486.1238&rep=rep1&type=pdf

main:

    TEST_START

    TEST "Fuzzy" "testFromLectureSystemsTwo":

        fuzzy := FuzzyModel

        // FuzzyInput
        veryLow :=  FuzzySet 5.0 5.0 5.0 15.0
        low :=      FuzzySet 10.0 20.0 20.0 30.0
        high :=     FuzzySet 25.0 30.0 30.0 35.0
        veryHigh := FuzzySet 30.0 50.0 50.0 50.0
        temperature := FuzzyInput 0
        temperature.add_all_sets [veryLow, low, high, veryHigh]
        fuzzy.add_input temperature

        // FuzzyInput
        dry :=          FuzzySet 5.0 5.0 5.0 30.0
        comfortable :=  FuzzySet 20.0 35.0 35.0 50.0
        humid :=        FuzzySet 40.0 55.0 55.0 70.0
        sticky :=       FuzzySet 60.0 100.0 100.0 100.0
        humidity := FuzzyInput 1
        humidity.add_all_sets [dry, comfortable, humid, sticky]
        fuzzy.add_input humidity

        // FuzzyOutput
        off :=          FuzzySet 0.0 0.0 0.0 0.0
        lowHumidity :=  FuzzySet 30.0 45.0 45.0 60.0
        medium :=       FuzzySet 50.0 65.0 65.0 80.0
        fast :=         FuzzySet 70.0 90.0 95.0 95.0
        speed := FuzzyOutput 0
        speed.add_all_sets [off, lowHumidity, medium, fast]
        fuzzy.add_output speed

        // Building FuzzyRules
        fuzzy.add_rule (FuzzyRule 0  (Antecedent.join_sets_AND veryLow dry)          (Consequent.output off))
        fuzzy.add_rule (FuzzyRule 1  (Antecedent.join_sets_AND veryLow comfortable)  (Consequent.output off))
        fuzzy.add_rule (FuzzyRule 2  (Antecedent.join_sets_AND veryLow humid)        (Consequent.output off))
        fuzzy.add_rule (FuzzyRule 3  (Antecedent.join_sets_AND veryLow sticky)       (Consequent.output lowHumidity))
        fuzzy.add_rule (FuzzyRule 4  (Antecedent.join_sets_AND low dry)              (Consequent.output off))
        fuzzy.add_rule (FuzzyRule 5  (Antecedent.join_sets_AND low comfortable)      (Consequent.output off))
        fuzzy.add_rule (FuzzyRule 6  (Antecedent.join_sets_AND low humid)            (Consequent.output lowHumidity))
        fuzzy.add_rule (FuzzyRule 7  (Antecedent.join_sets_AND low sticky)           (Consequent.output medium))
        fuzzy.add_rule (FuzzyRule 8  (Antecedent.join_sets_AND high dry)             (Consequent.output lowHumidity))
        fuzzy.add_rule (FuzzyRule 9  (Antecedent.join_sets_AND high comfortable)     (Consequent.output medium))
        fuzzy.add_rule (FuzzyRule 10 (Antecedent.join_sets_AND high humid)           (Consequent.output fast))
        fuzzy.add_rule (FuzzyRule 11 (Antecedent.join_sets_AND high sticky)          (Consequent.output fast))
        fuzzy.add_rule (FuzzyRule 12 (Antecedent.join_sets_AND veryHigh dry)         (Consequent.output medium))
        fuzzy.add_rule (FuzzyRule 13 (Antecedent.join_sets_AND veryHigh comfortable) (Consequent.output fast))
        fuzzy.add_rule (FuzzyRule 14 (Antecedent.join_sets_AND veryHigh humid)       (Consequent.output fast))
        fuzzy.add_rule (FuzzyRule 15 (Antecedent.join_sets_AND veryHigh sticky)      (Consequent.output fast))
        // run it
        fuzzy.set_input 0 20.0
        fuzzy.set_input 1 65.0
        fuzzy.fuzzify

        ASSERT_FLOAT_EQ 50.568535 (fuzzy.defuzzify 0) // This value was not extracted from the paper

    TEST_END


    /*
        if_VeryLowAndDry := Antecedent.join_sets_AND veryLow dry
        then_Off1 := Consequent.output off
        fuzzyRule0 := FuzzyRule 0 if_VeryLowAndDry then_Off1
        fuzzy.add_rule fuzzyRule0

        if_VeryLowAndComfortable := Antecedent.join_sets_AND veryLow comfortable
        then_Off2 := Consequent.output off
        fuzzyRule1 := FuzzyRule 1 if_VeryLowAndComfortable then_Off2
        fuzzy.add_rule fuzzyRule1

        if_VeryLowAndHumid := Antecedent.join_sets_AND veryLow humid
        then_Off3 := Consequent.output off
        fuzzyRule2 := FuzzyRule 2 if_VeryLowAndHumid then_Off3
        fuzzy.add_rule fuzzyRule2

        if_VeryLowAndSticky := Antecedent.join_sets_AND veryLow sticky
        then_Low1 := Consequent.output lowHumidity
        fuzzyRule3 := FuzzyRule 3 if_VeryLowAndSticky then_Low1
        fuzzy.add_rule fuzzyRule3

        if_LowAndDry := Antecedent.join_sets_AND low dry
        then_Off4 := Consequent.output off
        fuzzyRule4 := FuzzyRule 4 if_LowAndDry then_Off4
        fuzzy.add_rule fuzzyRule4

        if_LowAndComfortable := Antecedent.join_sets_AND low comfortable
        then_Off5 := Consequent.output off
        fuzzyRule5 := FuzzyRule 5 if_LowAndComfortable then_Off5
        fuzzy.add_rule fuzzyRule5

        if_LowAndHumid := Antecedent.join_sets_AND low humid
        then_Low2 := Consequent.output lowHumidity
        fuzzyRule6 := FuzzyRule 6 if_LowAndHumid then_Low2
        fuzzy.add_rule fuzzyRule6

        if_LowAndSticky := Antecedent.join_sets_AND low sticky
        then_Medium1 := Consequent.output medium
        fuzzyRule7 := FuzzyRule 7 if_LowAndSticky then_Medium1
        fuzzy.add_rule fuzzyRule7

        if_HighAndDry := Antecedent.join_sets_AND high dry
        then_Low3 := Consequent.output lowHumidity
        fuzzyRule8 := FuzzyRule 8 if_HighAndDry then_Low3
        fuzzy.add_rule fuzzyRule8

        if_HighAndComfortable := Antecedent.join_sets_AND high comfortable
        then_Medium2 := Consequent.output medium
        fuzzyRule9 := FuzzyRule 9 if_HighAndComfortable then_Medium2
        fuzzy.add_rule fuzzyRule9

        if_HighAndHumid := Antecedent.join_sets_AND high humid
        then_Fast1 := Consequent.output fast
        fuzzyRule10 := FuzzyRule 10 if_HighAndHumid then_Fast1
        fuzzy.add_rule fuzzyRule10

        if_HighAndSticky := Antecedent.join_sets_AND high sticky
        then_Fast2 := Consequent.output fast
        fuzzyRule11 := FuzzyRule 11 if_HighAndSticky then_Fast2
        fuzzy.add_rule fuzzyRule11

        if_VeryHighAndDry := Antecedent.join_sets_AND veryHigh dry
        then_Medium3 := Consequent.output medium
        fuzzyRule12 := FuzzyRule 12 if_VeryHighAndDry then_Medium3
        fuzzy.add_rule fuzzyRule12

        if_VeryHighAndComfortable := Antecedent.join_sets_AND veryHigh comfortable
        then_Fast3 := Consequent.output fast
        fuzzyRule13 := FuzzyRule 13 if_VeryHighAndComfortable then_Fast3
        fuzzy.add_rule fuzzyRule13
  
        if_VeryHighAndHumid := Antecedent.join_sets_AND veryHigh humid
        then_Fast4 := Consequent.output fast
        fuzzyRule14 := FuzzyRule 14 if_VeryHighAndHumid then_Fast4
        fuzzy.add_rule fuzzyRule14

        if_VeryHighAndSticky := Antecedent.join_sets_AND veryHigh sticky
        then_Fast5 := Consequent.output fast
        fuzzyRule15 := FuzzyRule 15 if_VeryHighAndSticky then_Fast5
        fuzzy.add_rule fuzzyRule15
*/