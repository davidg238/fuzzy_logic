
import btest show *
import ..examples.models show get-model

import fuzzy-logic show *


// ##### Tests from real systems, received from eFLL users
// From miss Casco (Paraguay)

main:

    test-start
    test "Fuzzy" "testFromLibraryUsersSystemsCasco":

        fuzzy := get-model "casco"

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
        expect-near 6.3785270 (fuzzy.defuzzify 0) // 6.21 on original file

        // TEST 04
        fuzzy.crisp-input 0 71.69
        fuzzy.crisp-input 1  8.554
        fuzzy.crisp-input 2  6.0

        fuzzy.changed
        fuzzy.fuzzify
        expect-near 4.2322019 (fuzzy.defuzzify 0) // 4.12 on original file

        // TEST 05
        fuzzy.crisp-input 0 71.69
        fuzzy.crisp-input 1 27.83
        fuzzy.crisp-input 2  9.036

        fuzzy.changed
        fuzzy.fuzzify
        expect-near 15.4593845 (fuzzy.defuzzify 0) // 15.5 on original file

        // TEST 06
        fuzzy.crisp-input 0 16.27
        fuzzy.crisp-input 1 27.83
        fuzzy.crisp-input 2  9.036

        fuzzy.changed
        fuzzy.fuzzify
        expect-near 16.5812311  (fuzzy.defuzzify 0) // 16.6 on original file

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
        expect-near 5.0615942 (fuzzy.defuzzify 0) // 4.96 on original file

    test-end
    