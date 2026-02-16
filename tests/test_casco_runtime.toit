import btest show *
import statistics show OnlineStatistics
import ..examples.models show get-model

import fuzzy-logic show *

// ##### Tests from real systems, received from eFLL users
// From miss Casco (Paraguay)

main:

    fuzzy := get-model "casco"
    
    // timing test
    fuzzy.crisp-input 0 12.65
    fuzzy.crisp-input 1  1.928
    fuzzy.crisp-input 2  6.0

    100.repeat:
        xtime := Duration.of:
            fuzzy.changed
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