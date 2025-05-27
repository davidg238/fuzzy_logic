import btest show *
import statistics show OnlineStatistics

import fuzzy-logic show *

// ##### Tests from real systems, received from eFLL users
// From miss Casco (Paraguay)

main:

    fuzzy := FuzzyModel
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
        fuzzy.add-rule (FuzzyRule.fl-if (Antecedent-And (Antecedent-And set-a set-b) set-c) --fl-then=(Consequent.output output))

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
    
    // timing test
    fuzzy.crisp-input 0 12.65
    fuzzy.crisp-input 1  1.928
    fuzzy.crisp-input 2  6.0

    100.repeat:
        xtime := Duration.of:
            fuzzy.fuzzify
            fuzzy.defuzzify 0

    print "---------------------------"

    cases := [
        [54.82, 20.0, 6.0],
        [12.65, 1.928, 6.0], 
        [25.9, 8.55, 6.0],
        [71.69, 8.554, 6.0],
        [71.69, 27.83, 9.036],
        [16.27, 27.83, 9.036], 
        [82.53, 27.83, 10.63],
        [7.831, 27.83, 10.63], 
        [7.831, 7.952, 10.63]
    ]


    stats := OnlineStatistics
    cases.do: |inputs|
        100.repeat:
            xtime := Duration.of:
                fuzzy.crisp-inputs inputs
                fuzzy.changed
                fuzzy.fuzzify
                fuzzy.defuzzify 0
            stats.update xtime.in-ms

    print "model runtime: $(%.1f stats.mean) ms"