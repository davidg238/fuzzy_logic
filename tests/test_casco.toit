
import btest show *

import fuzzy-logic show *


// ##### Tests from real systems, received from eFLL users
// From miss Casco (Paraguay)

main:

    test-start
    test "Fuzzy" "testFromLibraryUsersSystemsCasco":

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

        rule-template := : |id set-a set-b set-c output|
            fuzzy.add-rule (FuzzyRule (Antecedent.AND-ante-set (Antecedent.AND-sets set-a set-b) set-c) (Consequent.output output))

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
        
        // TEST 01
        fuzzy.crisp-input 0 54.82
        fuzzy.crisp-input 1 20.0
        fuzzy.crisp-input 2  6.0

        fuzzy.changed
        fuzzy.fuzzify
        expect-near 7.5 (fuzzy.defuzzify 0)

        // TEST 02
        fuzzy.crisp-input 0 12.65
        fuzzy.crisp-input 1  1.928
        fuzzy.crisp-input 2  6.0

        fuzzy.changed
        fuzzy.fuzzify
        expect-near 2.4226191 (fuzzy.defuzzify 0) // 2.35 on original file

        // TEST 03
        fuzzy.crisp-input 0 25.9
        fuzzy.crisp-input 1  8.55
        fuzzy.crisp-input 2  6.0

        fuzzy.changed
        fuzzy.fuzzify
        expect-near 6.4175873 (fuzzy.defuzzify 0) // 6.21 on original file

        // TEST 04
        fuzzy.crisp-input 0 71.69
        fuzzy.crisp-input 1  8.554
        fuzzy.crisp-input 2  6.0

        fuzzy.changed
        fuzzy.fuzzify
        expect-near 4.2093439 (fuzzy.defuzzify 0) // 4.12 on original file

        // TEST 05
        fuzzy.crisp-input 0 71.69
        fuzzy.crisp-input 1 27.83
        fuzzy.crisp-input 2  9.036

        fuzzy.changed
        fuzzy.fuzzify
        expect-near 15.478251 (fuzzy.defuzzify 0) // 15.5 on original file

        // TEST 06
        fuzzy.crisp-input 0 16.27
        fuzzy.crisp-input 1 27.83
        fuzzy.crisp-input 2  9.036

        fuzzy.changed
        fuzzy.fuzzify
        expect-near 16.58123  (fuzzy.defuzzify 0) // 16.6 on original file

        // TEST 07
        fuzzy.crisp-input 0 82.53
        fuzzy.crisp-input 1 27.83
        fuzzy.crisp-input 2 10.63

        fuzzy.changed
        fuzzy.fuzzify
        expect-near 2.4555054 (fuzzy.defuzzify 0) // 2.38 on original file

        // TEST 08
        fuzzy.crisp-input 0 7.831
        fuzzy.crisp-input 1 27.83
        fuzzy.crisp-input 2 10.63

        fuzzy.changed
        fuzzy.fuzzify
        expect-near 22.5 (fuzzy.defuzzify 0)

        // TEST 09
        fuzzy.crisp-input 0 7.831
        fuzzy.crisp-input 1 7.952
        fuzzy.crisp-input 2 10.63

        fuzzy.changed
        fuzzy.fuzzify
        expect-near 5.0615907 (fuzzy.defuzzify 0) // 4.96 on original file

    test-end
    