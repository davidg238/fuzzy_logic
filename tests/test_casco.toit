
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

// ##### Tests from real systems, received from eFLL users
// From miss Casco (Paraguay)

main:

    TEST_START
    TEST "Fuzzy" "testFromLibraryUsersSystemsCasco":

        fuzzy := FuzzyModel
        // FuzzyInput
        seco :=         FuzzySet  0.0   0.0   0.0  42.5
        humedo :=       FuzzySet 37.5  60.0  60.0  82.5
        encharcado :=   FuzzySet 77.5 100.0 100.0 100.0
        humedad := FuzzyInput 0
        humedad.add_all_sets [seco, humedo, encharcado]
        fuzzy.add_input humedad
        // FuzzyInput
        frio :=         FuzzySet -5.0 -5.0 -5.0 12.5
        templado :=     FuzzySet  7.5 17.5 17.5 27.5
        calor :=        FuzzySet 22.5 45.0 45.0 45.0
        temperatura := FuzzyInput 1
        temperatura.add_all_sets [frio, templado, calor]
        fuzzy.add_input temperatura
        // FuzzyInput
        verano :=       FuzzySet 0.0  0.0  0.0  3.5
        otono :=        FuzzySet 2.5  4.5  4.5  6.5
        invierno :=     FuzzySet 5.5  7.5  7.5  9.5
        primavera :=    FuzzySet 8.5 12.0 12.0 12.0
        mes := FuzzyInput 2
        mes.add_all_sets [verano, otono, invierno, primavera]
        fuzzy.add_input mes

        // FuzzyOutput
        nada :=         FuzzySet  0.0  0.0  0.0  0.0
        muyPoco :=      FuzzySet  0.0  0.0  0.0  5.5
        poco :=         FuzzySet  4.5  7.5  7.5 10.5
        medio :=        FuzzySet  9.5 12.5 12.5 15.5
        bastante :=     FuzzySet 14.5 17.5 17.5 20.5
        mucho :=        FuzzySet 19.5 22.5 22.5 25.5
        muchisimo :=    FuzzySet 24.5 30.0 30.0 30.0
        tiempo := FuzzyOutput 0
        fuzzy.add_output tiempo

        fuzzy.add_rule (FuzzyRule
                            0 
                            (Antecedent.join_ante_set_AND ((Antecedent.join_sets_AND seco frio) verano)) 
                            (Consequent.add_output medio))

        // ############## Rule 2
        FuzzyRuleAntecedent *fuzzyAntecedentA_2 = new FuzzyRuleAntecedent(
        fuzzyAntecedentA_2->joinWithAND(seco, frio
        FuzzyRuleAntecedent *fuzzyAntecedentB_2 = new FuzzyRuleAntecedent(
        fuzzyAntecedentB_2->joinWithAND(fuzzyAntecedentA_2, otono
        FuzzyRuleConsequent *fuzzyConsequent_2 = new FuzzyRuleConsequent(
        fuzzyConsequent_2->addOutput(muyPoco

        FuzzyRule *fuzzyRule_2 = new FuzzyRule(2, fuzzyAntecedentB_2, fuzzyConsequent_2
        fuzzy->addFuzzyRule(fuzzyRule_2

        // ############## Rule 3
        FuzzyRuleAntecedent *fuzzyAntecedentA_3 = new FuzzyRuleAntecedent(
        fuzzyAntecedentA_3->joinWithAND(seco, frio
        FuzzyRuleAntecedent *fuzzyAntecedentB_3 = new FuzzyRuleAntecedent(
        fuzzyAntecedentB_3->joinWithAND(fuzzyAntecedentA_3, invierno
        FuzzyRuleConsequent *fuzzyConsequent_3 = new FuzzyRuleConsequent(
        fuzzyConsequent_3->addOutput(muyPoco

        FuzzyRule *fuzzyRule_3 = new FuzzyRule(3, fuzzyAntecedentB_3, fuzzyConsequent_3
        fuzzy->addFuzzyRule(fuzzyRule_3

        // ############## Rule 4
        FuzzyRuleAntecedent *fuzzyAntecedentA_4 = new FuzzyRuleAntecedent(
        fuzzyAntecedentA_4->joinWithAND(seco, frio
        FuzzyRuleAntecedent *fuzzyAntecedentB_4 = new FuzzyRuleAntecedent(
        fuzzyAntecedentB_4->joinWithAND(fuzzyAntecedentA_4, primavera
        FuzzyRuleConsequent *fuzzyConsequent_4 = new FuzzyRuleConsequent(
        fuzzyConsequent_4->addOutput(muyPoco

        FuzzyRule *fuzzyRule_4 = new FuzzyRule(4, fuzzyAntecedentB_4, fuzzyConsequent_4
        fuzzy->addFuzzyRule(fuzzyRule_4

        // ############## Rule 5
        FuzzyRuleAntecedent *fuzzyAntecedentA_5 = new FuzzyRuleAntecedent(
        fuzzyAntecedentA_5->joinWithAND(humedo, frio
        FuzzyRuleAntecedent *fuzzyAntecedentB_5 = new FuzzyRuleAntecedent(
        fuzzyAntecedentB_5->joinWithAND(fuzzyAntecedentA_5, verano
        FuzzyRuleConsequent *fuzzyConsequent_5 = new FuzzyRuleConsequent(
        fuzzyConsequent_5->addOutput(muyPoco

        FuzzyRule *fuzzyRule_5 = new FuzzyRule(5, fuzzyAntecedentB_5, fuzzyConsequent_5
        fuzzy->addFuzzyRule(fuzzyRule_5

        // ############## Rule 6
        FuzzyRuleAntecedent *fuzzyAntecedentA_6 = new FuzzyRuleAntecedent(
        fuzzyAntecedentA_6->joinWithAND(humedo, frio
        FuzzyRuleAntecedent *fuzzyAntecedentB_6 = new FuzzyRuleAntecedent(
        fuzzyAntecedentB_6->joinWithAND(fuzzyAntecedentA_6, otono
        FuzzyRuleConsequent *fuzzyConsequent_6 = new FuzzyRuleConsequent(
        fuzzyConsequent_6->addOutput(muyPoco

        FuzzyRule *fuzzyRule_6 = new FuzzyRule(6, fuzzyAntecedentB_6, fuzzyConsequent_6
        fuzzy->addFuzzyRule(fuzzyRule_6

        // ############## Rule 7
        FuzzyRuleAntecedent *fuzzyAntecedentA_7 = new FuzzyRuleAntecedent(
        fuzzyAntecedentA_7->joinWithAND(humedo, frio
        FuzzyRuleAntecedent *fuzzyAntecedentB_7 = new FuzzyRuleAntecedent(
        fuzzyAntecedentB_7->joinWithAND(fuzzyAntecedentA_7, invierno
        FuzzyRuleConsequent *fuzzyConsequent_7 = new FuzzyRuleConsequent(
        fuzzyConsequent_7->addOutput(muyPoco

        FuzzyRule *fuzzyRule_7 = new FuzzyRule(7, fuzzyAntecedentB_7, fuzzyConsequent_7
        fuzzy->addFuzzyRule(fuzzyRule_7

        // ############## Rule 8
        FuzzyRuleAntecedent *fuzzyAntecedentA_8 = new FuzzyRuleAntecedent(
        fuzzyAntecedentA_8->joinWithAND(humedo, frio
        FuzzyRuleAntecedent *fuzzyAntecedentB_8 = new FuzzyRuleAntecedent(
        fuzzyAntecedentB_8->joinWithAND(fuzzyAntecedentA_8, primavera
        FuzzyRuleConsequent *fuzzyConsequent_8 = new FuzzyRuleConsequent(
        fuzzyConsequent_8->addOutput(muyPoco

        FuzzyRule *fuzzyRule_8 = new FuzzyRule(8, fuzzyAntecedentB_8, fuzzyConsequent_8
        fuzzy->addFuzzyRule(fuzzyRule_8

        // ############## Rule 9
        FuzzyRuleAntecedent *fuzzyAntecedentA_9 = new FuzzyRuleAntecedent(
        fuzzyAntecedentA_9->joinWithAND(encharcado, frio
        FuzzyRuleAntecedent *fuzzyAntecedentB_9 = new FuzzyRuleAntecedent(
        fuzzyAntecedentB_9->joinWithAND(fuzzyAntecedentA_9, primavera
        FuzzyRuleConsequent *fuzzyConsequent_9 = new FuzzyRuleConsequent(
        fuzzyConsequent_9->addOutput(nada

        FuzzyRule *fuzzyRule_9 = new FuzzyRule(9, fuzzyAntecedentB_9, fuzzyConsequent_9
        fuzzy->addFuzzyRule(fuzzyRule_9

        // ############## Rule 10
        FuzzyRuleAntecedent *fuzzyAntecedentA_10 = new FuzzyRuleAntecedent(
        fuzzyAntecedentA_10->joinWithAND(encharcado, frio
        FuzzyRuleAntecedent *fuzzyAntecedentB_10 = new FuzzyRuleAntecedent(
        fuzzyAntecedentB_10->joinWithAND(fuzzyAntecedentA_10.0 otono
        FuzzyRuleConsequent *fuzzyConsequent_10 = new FuzzyRuleConsequent(
        fuzzyConsequent_10->addOutput(nada

        FuzzyRule *fuzzyRule_10 = new FuzzyRule(10.0 fuzzyAntecedentB_10.0 fuzzyConsequent_10
        fuzzy->addFuzzyRule(fuzzyRule_10

        // ############## Rule 11
        FuzzyRuleAntecedent *fuzzyAntecedentA_11 = new FuzzyRuleAntecedent(
        fuzzyAntecedentA_11->joinWithAND(encharcado, frio
        FuzzyRuleAntecedent *fuzzyAntecedentB_11 = new FuzzyRuleAntecedent(
        fuzzyAntecedentB_11->joinWithAND(fuzzyAntecedentA_11, invierno
        FuzzyRuleConsequent *fuzzyConsequent_11 = new FuzzyRuleConsequent(
        fuzzyConsequent_11->addOutput(nada

        FuzzyRule *fuzzyRule_11 = new FuzzyRule(11, fuzzyAntecedentB_11, fuzzyConsequent_11
        fuzzy->addFuzzyRule(fuzzyRule_11

        // ############## Rule 12
        FuzzyRuleAntecedent *fuzzyAntecedentA_12 = new FuzzyRuleAntecedent(
        fuzzyAntecedentA_12->joinWithAND(encharcado, frio
        FuzzyRuleAntecedent *fuzzyAntecedentB_12 = new FuzzyRuleAntecedent(
        fuzzyAntecedentB_12->joinWithAND(fuzzyAntecedentA_12, primavera
        FuzzyRuleConsequent *fuzzyConsequent_12 = new FuzzyRuleConsequent(
        fuzzyConsequent_12->addOutput(nada

        FuzzyRule *fuzzyRule_12 = new FuzzyRule(12, fuzzyAntecedentB_12, fuzzyConsequent_12
        fuzzy->addFuzzyRule(fuzzyRule_12

        // ############## Rule 13
        FuzzyRuleAntecedent *fuzzyAntecedentA_13 = new FuzzyRuleAntecedent(
        fuzzyAntecedentA_13->joinWithAND(seco, templado
        FuzzyRuleAntecedent *fuzzyAntecedentB_13 = new FuzzyRuleAntecedent(
        fuzzyAntecedentB_13->joinWithAND(fuzzyAntecedentA_13, verano
        FuzzyRuleConsequent *fuzzyConsequent_13 = new FuzzyRuleConsequent(
        fuzzyConsequent_13->addOutput(bastante

        FuzzyRule *fuzzyRule_13 = new FuzzyRule(13, fuzzyAntecedentB_13, fuzzyConsequent_13
        fuzzy->addFuzzyRule(fuzzyRule_13

        // ############## Rule 14
        FuzzyRuleAntecedent *fuzzyAntecedentA_14 = new FuzzyRuleAntecedent(
        fuzzyAntecedentA_14->joinWithAND(seco, templado
        FuzzyRuleAntecedent *fuzzyAntecedentB_14 = new FuzzyRuleAntecedent(
        fuzzyAntecedentB_14->joinWithAND(fuzzyAntecedentA_14, otono
        FuzzyRuleConsequent *fuzzyConsequent_14 = new FuzzyRuleConsequent(
        fuzzyConsequent_14->addOutput(medio

        FuzzyRule *fuzzyRule_14 = new FuzzyRule(14, fuzzyAntecedentB_14, fuzzyConsequent_14
        fuzzy->addFuzzyRule(fuzzyRule_14

        // ############## Rule 15
        FuzzyRuleAntecedent *fuzzyAntecedentA_15 = new FuzzyRuleAntecedent(
        fuzzyAntecedentA_15->joinWithAND(seco, templado
        FuzzyRuleAntecedent *fuzzyAntecedentB_15 = new FuzzyRuleAntecedent(
        fuzzyAntecedentB_15->joinWithAND(fuzzyAntecedentA_15, invierno
        FuzzyRuleConsequent *fuzzyConsequent_15 = new FuzzyRuleConsequent(
        fuzzyConsequent_15->addOutput(poco

        FuzzyRule *fuzzyRule_15 = new FuzzyRule(15, fuzzyAntecedentB_15, fuzzyConsequent_15
        fuzzy->addFuzzyRule(fuzzyRule_15

        // ############## Rule 16
        FuzzyRuleAntecedent *fuzzyAntecedentA_16 = new FuzzyRuleAntecedent(
        fuzzyAntecedentA_16->joinWithAND(seco, templado
        FuzzyRuleAntecedent *fuzzyAntecedentB_16 = new FuzzyRuleAntecedent(
        fuzzyAntecedentB_16->joinWithAND(fuzzyAntecedentA_16, primavera
        FuzzyRuleConsequent *fuzzyConsequent_16 = new FuzzyRuleConsequent(
        fuzzyConsequent_16->addOutput(bastante

        FuzzyRule *fuzzyRule_16 = new FuzzyRule(16, fuzzyAntecedentB_16, fuzzyConsequent_16
        fuzzy->addFuzzyRule(fuzzyRule_16

        // ############## Rule 17
        FuzzyRuleAntecedent *fuzzyAntecedentA_17 = new FuzzyRuleAntecedent(
        fuzzyAntecedentA_17->joinWithAND(humedo, templado
        FuzzyRuleAntecedent *fuzzyAntecedentB_17 = new FuzzyRuleAntecedent(
        fuzzyAntecedentB_17->joinWithAND(fuzzyAntecedentA_17, verano
        FuzzyRuleConsequent *fuzzyConsequent_17 = new FuzzyRuleConsequent(
        fuzzyConsequent_17->addOutput(medio

        FuzzyRule *fuzzyRule_17 = new FuzzyRule(17, fuzzyAntecedentB_17, fuzzyConsequent_17
        fuzzy->addFuzzyRule(fuzzyRule_17

        // ############## Rule 18
        FuzzyRuleAntecedent *fuzzyAntecedentA_18 = new FuzzyRuleAntecedent(
        fuzzyAntecedentA_18->joinWithAND(humedo, templado
        FuzzyRuleAntecedent *fuzzyAntecedentB_18 = new FuzzyRuleAntecedent(
        fuzzyAntecedentB_18->joinWithAND(fuzzyAntecedentA_18, otono
        FuzzyRuleConsequent *fuzzyConsequent_18 = new FuzzyRuleConsequent(
        fuzzyConsequent_18->addOutput(poco

        FuzzyRule *fuzzyRule_18 = new FuzzyRule(18, fuzzyAntecedentB_18, fuzzyConsequent_18
        fuzzy->addFuzzyRule(fuzzyRule_18

        // ############## Rule 19
        FuzzyRuleAntecedent *fuzzyAntecedentA_19 = new FuzzyRuleAntecedent(
        fuzzyAntecedentA_19->joinWithAND(humedo, templado
        FuzzyRuleAntecedent *fuzzyAntecedentB_19 = new FuzzyRuleAntecedent(
        fuzzyAntecedentB_19->joinWithAND(fuzzyAntecedentA_19, invierno
        FuzzyRuleConsequent *fuzzyConsequent_19 = new FuzzyRuleConsequent(
        fuzzyConsequent_19->addOutput(poco

        FuzzyRule *fuzzyRule_19 = new FuzzyRule(19, fuzzyAntecedentB_19, fuzzyConsequent_19
        fuzzy->addFuzzyRule(fuzzyRule_19

        // ############## Rule 20
        FuzzyRuleAntecedent *fuzzyAntecedentA_20 = new FuzzyRuleAntecedent(
        fuzzyAntecedentA_20->joinWithAND(humedo, templado
        FuzzyRuleAntecedent *fuzzyAntecedentB_20 = new FuzzyRuleAntecedent(
        fuzzyAntecedentB_20->joinWithAND(fuzzyAntecedentA_20.0 primavera
        FuzzyRuleConsequent *fuzzyConsequent_20 = new FuzzyRuleConsequent(
        fuzzyConsequent_20->addOutput(medio

        FuzzyRule *fuzzyRule_20 = new FuzzyRule(20.0 fuzzyAntecedentB_20.0 fuzzyConsequent_20
        fuzzy->addFuzzyRule(fuzzyRule_20

        // ############## Rule 21
        FuzzyRuleAntecedent *fuzzyAntecedentA_21 = new FuzzyRuleAntecedent(
        fuzzyAntecedentA_21->joinWithAND(encharcado, templado
        FuzzyRuleAntecedent *fuzzyAntecedentB_21 = new FuzzyRuleAntecedent(
        fuzzyAntecedentB_21->joinWithAND(fuzzyAntecedentA_21, primavera
        FuzzyRuleConsequent *fuzzyConsequent_21 = new FuzzyRuleConsequent(
        fuzzyConsequent_21->addOutput(muyPoco

        FuzzyRule *fuzzyRule_21 = new FuzzyRule(21, fuzzyAntecedentB_21, fuzzyConsequent_21
        fuzzy->addFuzzyRule(fuzzyRule_21

        // ############## Rule 22
        FuzzyRuleAntecedent *fuzzyAntecedentA_22 = new FuzzyRuleAntecedent(
        fuzzyAntecedentA_22->joinWithAND(encharcado, templado
        FuzzyRuleAntecedent *fuzzyAntecedentB_22 = new FuzzyRuleAntecedent(
        fuzzyAntecedentB_22->joinWithAND(fuzzyAntecedentA_22, otono
        FuzzyRuleConsequent *fuzzyConsequent_22 = new FuzzyRuleConsequent(
        fuzzyConsequent_22->addOutput(nada

        FuzzyRule *fuzzyRule_22 = new FuzzyRule(22, fuzzyAntecedentB_22, fuzzyConsequent_22
        fuzzy->addFuzzyRule(fuzzyRule_22

        // ############## Rule 23
        FuzzyRuleAntecedent *fuzzyAntecedentA_23 = new FuzzyRuleAntecedent(
        fuzzyAntecedentA_23->joinWithAND(encharcado, templado
        FuzzyRuleAntecedent *fuzzyAntecedentB_23 = new FuzzyRuleAntecedent(
        fuzzyAntecedentB_23->joinWithAND(fuzzyAntecedentA_23, invierno
        FuzzyRuleConsequent *fuzzyConsequent_23 = new FuzzyRuleConsequent(
        fuzzyConsequent_23->addOutput(nada

        FuzzyRule *fuzzyRule_23 = new FuzzyRule(23, fuzzyAntecedentB_23, fuzzyConsequent_23
        fuzzy->addFuzzyRule(fuzzyRule_23

        // ############## Rule 24
        FuzzyRuleAntecedent *fuzzyAntecedentA_24 = new FuzzyRuleAntecedent(
        fuzzyAntecedentA_24->joinWithAND(encharcado, templado
        FuzzyRuleAntecedent *fuzzyAntecedentB_24 = new FuzzyRuleAntecedent(
        fuzzyAntecedentB_24->joinWithAND(fuzzyAntecedentA_24, primavera
        FuzzyRuleConsequent *fuzzyConsequent_24 = new FuzzyRuleConsequent(
        fuzzyConsequent_24->addOutput(muyPoco

        FuzzyRule *fuzzyRule_24 = new FuzzyRule(24, fuzzyAntecedentB_24, fuzzyConsequent_24
        fuzzy->addFuzzyRule(fuzzyRule_24

        // ############## Rule 25
        FuzzyRuleAntecedent *fuzzyAntecedentA_25 = new FuzzyRuleAntecedent(
        fuzzyAntecedentA_25->joinWithAND(seco, calor
        FuzzyRuleAntecedent *fuzzyAntecedentB_25 = new FuzzyRuleAntecedent(
        fuzzyAntecedentB_25->joinWithAND(fuzzyAntecedentA_25, verano
        FuzzyRuleConsequent *fuzzyConsequent_25 = new FuzzyRuleConsequent(
        fuzzyConsequent_25->addOutput(mucho

        FuzzyRule *fuzzyRule_25 = new FuzzyRule(25, fuzzyAntecedentB_25, fuzzyConsequent_25
        fuzzy->addFuzzyRule(fuzzyRule_25

        // ############## Rule 26
        FuzzyRuleAntecedent *fuzzyAntecedentA_26 = new FuzzyRuleAntecedent(
        fuzzyAntecedentA_26->joinWithAND(seco, calor
        FuzzyRuleAntecedent *fuzzyAntecedentB_26 = new FuzzyRuleAntecedent(
        fuzzyAntecedentB_26->joinWithAND(fuzzyAntecedentA_26, otono
        FuzzyRuleConsequent *fuzzyConsequent_26 = new FuzzyRuleConsequent(
        fuzzyConsequent_26->addOutput(medio

        FuzzyRule *fuzzyRule_26 = new FuzzyRule(26, fuzzyAntecedentB_26, fuzzyConsequent_26
        fuzzy->addFuzzyRule(fuzzyRule_26

        // ############## Rule 27
        FuzzyRuleAntecedent *fuzzyAntecedentA_27 = new FuzzyRuleAntecedent(
        fuzzyAntecedentA_27->joinWithAND(seco, calor
        FuzzyRuleAntecedent *fuzzyAntecedentB_27 = new FuzzyRuleAntecedent(
        fuzzyAntecedentB_27->joinWithAND(fuzzyAntecedentA_27, invierno
        FuzzyRuleConsequent *fuzzyConsequent_27 = new FuzzyRuleConsequent(
        fuzzyConsequent_27->addOutput(medio

        FuzzyRule *fuzzyRule_27 = new FuzzyRule(27, fuzzyAntecedentB_27, fuzzyConsequent_27
        fuzzy->addFuzzyRule(fuzzyRule_27

        // ############## Rule 28
        FuzzyRuleAntecedent *fuzzyAntecedentA_28 = new FuzzyRuleAntecedent(
        fuzzyAntecedentA_28->joinWithAND(seco, calor
        FuzzyRuleAntecedent *fuzzyAntecedentB_28 = new FuzzyRuleAntecedent(
        fuzzyAntecedentB_28->joinWithAND(fuzzyAntecedentA_28, primavera
        FuzzyRuleConsequent *fuzzyConsequent_28 = new FuzzyRuleConsequent(
        fuzzyConsequent_28->addOutput(mucho

        FuzzyRule *fuzzyRule_28 = new FuzzyRule(28, fuzzyAntecedentB_28, fuzzyConsequent_28
        fuzzy->addFuzzyRule(fuzzyRule_28

        // ############## Rule 29
        FuzzyRuleAntecedent *fuzzyAntecedentA_29 = new FuzzyRuleAntecedent(
        fuzzyAntecedentA_29->joinWithAND(humedo, calor
        FuzzyRuleAntecedent *fuzzyAntecedentB_29 = new FuzzyRuleAntecedent(
        fuzzyAntecedentB_29->joinWithAND(fuzzyAntecedentA_29, verano
        FuzzyRuleConsequent *fuzzyConsequent_29 = new FuzzyRuleConsequent(
        fuzzyConsequent_29->addOutput(bastante

        FuzzyRule *fuzzyRule_29 = new FuzzyRule(29, fuzzyAntecedentB_29, fuzzyConsequent_29
        fuzzy->addFuzzyRule(fuzzyRule_29

        // ############## Rule 30
        FuzzyRuleAntecedent *fuzzyAntecedentA_30 = new FuzzyRuleAntecedent(
        fuzzyAntecedentA_30->joinWithAND(humedo, calor
        FuzzyRuleAntecedent *fuzzyAntecedentB_30 = new FuzzyRuleAntecedent(
        fuzzyAntecedentB_30->joinWithAND(fuzzyAntecedentA_30.0 otono
        FuzzyRuleConsequent *fuzzyConsequent_30 = new FuzzyRuleConsequent(
        fuzzyConsequent_30->addOutput(bastante

        FuzzyRule *fuzzyRule_30 = new FuzzyRule(30.0 fuzzyAntecedentB_30.0 fuzzyConsequent_30
        fuzzy->addFuzzyRule(fuzzyRule_30

        // ############## Rule 31
        FuzzyRuleAntecedent *fuzzyAntecedentA_31 = new FuzzyRuleAntecedent(
        fuzzyAntecedentA_31->joinWithAND(humedo, calor
        FuzzyRuleAntecedent *fuzzyAntecedentB_31 = new FuzzyRuleAntecedent(
        fuzzyAntecedentB_31->joinWithAND(fuzzyAntecedentA_31, invierno
        FuzzyRuleConsequent *fuzzyConsequent_31 = new FuzzyRuleConsequent(
        fuzzyConsequent_31->addOutput(bastante

        FuzzyRule *fuzzyRule_31 = new FuzzyRule(31, fuzzyAntecedentB_31, fuzzyConsequent_31
        fuzzy->addFuzzyRule(fuzzyRule_31

        // ############## Rule 32
        FuzzyRuleAntecedent *fuzzyAntecedentA_32 = new FuzzyRuleAntecedent(
        fuzzyAntecedentA_32->joinWithAND(humedo, calor
        FuzzyRuleAntecedent *fuzzyAntecedentB_32 = new FuzzyRuleAntecedent(
        fuzzyAntecedentB_32->joinWithAND(fuzzyAntecedentA_32, primavera
        FuzzyRuleConsequent *fuzzyConsequent_32 = new FuzzyRuleConsequent(
        fuzzyConsequent_32->addOutput(medio

        FuzzyRule *fuzzyRule_32 = new FuzzyRule(32, fuzzyAntecedentB_32, fuzzyConsequent_32
        fuzzy->addFuzzyRule(fuzzyRule_32

        // ############## Rule 33
        FuzzyRuleAntecedent *fuzzyAntecedentA_33 = new FuzzyRuleAntecedent(
        fuzzyAntecedentA_33->joinWithAND(encharcado, calor
        FuzzyRuleAntecedent *fuzzyAntecedentB_33 = new FuzzyRuleAntecedent(
        fuzzyAntecedentB_33->joinWithAND(fuzzyAntecedentA_33, verano
        FuzzyRuleConsequent *fuzzyConsequent_33 = new FuzzyRuleConsequent(
        fuzzyConsequent_33->addOutput(muyPoco

        FuzzyRule *fuzzyRule_33 = new FuzzyRule(33, fuzzyAntecedentB_33, fuzzyConsequent_33
        fuzzy->addFuzzyRule(fuzzyRule_33

        // ############## Rule 34
        FuzzyRuleAntecedent *fuzzyAntecedentA_34 = new FuzzyRuleAntecedent(
        fuzzyAntecedentA_34->joinWithAND(encharcado, calor
        FuzzyRuleAntecedent *fuzzyAntecedentB_34 = new FuzzyRuleAntecedent(
        fuzzyAntecedentB_34->joinWithAND(fuzzyAntecedentA_34, otono
        FuzzyRuleConsequent *fuzzyConsequent_34 = new FuzzyRuleConsequent(
        fuzzyConsequent_34->addOutput(nada

        FuzzyRule *fuzzyRule_34 = new FuzzyRule(34, fuzzyAntecedentB_34, fuzzyConsequent_34
        fuzzy->addFuzzyRule(fuzzyRule_34

        // ############## Rule 35
        FuzzyRuleAntecedent *fuzzyAntecedentA_35 = new FuzzyRuleAntecedent(
        fuzzyAntecedentA_35->joinWithAND(encharcado, calor
        FuzzyRuleAntecedent *fuzzyAntecedentB_35 = new FuzzyRuleAntecedent(
        fuzzyAntecedentB_35->joinWithAND(fuzzyAntecedentA_35, invierno
        FuzzyRuleConsequent *fuzzyConsequent_35 = new FuzzyRuleConsequent(
        fuzzyConsequent_35->addOutput(nada

        FuzzyRule *fuzzyRule_35 = new FuzzyRule(35, fuzzyAntecedentB_35, fuzzyConsequent_35
        fuzzy->addFuzzyRule(fuzzyRule_35

        // ############## Rule 36
        FuzzyRuleAntecedent *fuzzyAntecedentA_36 = new FuzzyRuleAntecedent(
        fuzzyAntecedentA_36->joinWithAND(encharcado, calor
        FuzzyRuleAntecedent *fuzzyAntecedentB_36 = new FuzzyRuleAntecedent(
        fuzzyAntecedentB_36->joinWithAND(fuzzyAntecedentA_36, primavera
        FuzzyRuleConsequent *fuzzyConsequent_36 = new FuzzyRuleConsequent(
        fuzzyConsequent_36->addOutput(muyPoco

        FuzzyRule *fuzzyRule_36 = new FuzzyRule(36, fuzzyAntecedentB_36, fuzzyConsequent_36
        fuzzy->addFuzzyRule(fuzzyRule_36

        // TEST 01
        fuzzy->setInput(1, 54.82
        fuzzy->setInput(2, 20
        fuzzy->setInput(3, 6

        fuzzy->fuzzify(

        EXPECT_FLOAT_EQ(7.5, fuzzy->defuzzify(1)

        // TEST 02
        fuzzy->setInput(1, 12.65
        fuzzy->setInput(2, 1.928
        fuzzy->setInput(3, 6

        fuzzy->fuzzify(

        EXPECT_FLOAT_EQ(2.4226191, fuzzy->defuzzify(1) // 2.35 on original file

        // TEST 03
        fuzzy->setInput(1, 25.9
        fuzzy->setInput(2, 8.55
        fuzzy->setInput(3, 6

        fuzzy->fuzzify(

        EXPECT_FLOAT_EQ(6.4175873, fuzzy->defuzzify(1) // 6.21 on original file

        // TEST 04
        fuzzy->setInput(1, 71.69
        fuzzy->setInput(2, 8.554
        fuzzy->setInput(3, 6

        fuzzy->fuzzify(

        EXPECT_FLOAT_EQ(4.2093439, fuzzy->defuzzify(1) // 4.12 on original file

        // TEST 05
        fuzzy->setInput(1, 71.69
        fuzzy->setInput(2, 27.83
        fuzzy->setInput(3, 9.036

        fuzzy->fuzzify(

        EXPECT_FLOAT_EQ(15.478251, fuzzy->defuzzify(1) // 15.5 on original file

        // TEST 06
        fuzzy->setInput(1, 16.27
        fuzzy->setInput(2, 27.83
        fuzzy->setInput(3, 9.036

        fuzzy->fuzzify(

        EXPECT_FLOAT_EQ(16.58123, fuzzy->defuzzify(1) // 16.6 on original file

        // TEST 07
        fuzzy->setInput(1, 82.53
        fuzzy->setInput(2, 27.83
        fuzzy->setInput(3, 10.63

        fuzzy->fuzzify(

        EXPECT_FLOAT_EQ(2.4555054, fuzzy->defuzzify(1) // 2.38 on original file

        // TEST 08
        fuzzy->setInput(1, 7.831
        fuzzy->setInput(2, 27.83
        fuzzy->setInput(3, 10.63

        fuzzy->fuzzify(

        EXPECT_FLOAT_EQ(22.5, fuzzy->defuzzify(1)

        // TEST 09
        fuzzy->setInput(1, 7.831
        fuzzy->setInput(2, 7.952
        fuzzy->setInput(3, 10.63

        fuzzy->fuzzify(

        EXPECT_FLOAT_EQ(5.0615907, fuzzy->defuzzify(1) // 4.96 on original file
    