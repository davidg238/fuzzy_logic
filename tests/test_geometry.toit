    // Copyright (c) 2021 Ekorau LLC

import .test_util show *

import fuzzy_model show FuzzyModel
import composition show Composition
import fuzzy_input show FuzzyInput
import fuzzy_output show FuzzyOutput
import fuzzy_set show FuzzySet
import fuzzy_rule show FuzzyRule
import antecedent show Antecedent
import consequent show Consequent

import expect show *

main:

    TEST_START

    
    TEST "Composition" "single sets":

        set := null
        composition := Composition
        test_centroid := : | set pert answer |
            set.pertinence pert
            composition.clear
            composition.union set
            print "$composition"
            ASSERT_FLOAT_EQ answer composition.calculate

        test_centroid.call (FuzzySet 0.0 10.0 10.0 20.0 "tri")  0.5 10.0
        test_centroid.call (FuzzySet 10.0 20.0 20.0 30.0 "tri") 0.5 20.0
        test_centroid.call (FuzzySet 0.0 0.0 0.0 21.0 "lra")    0.5 7.0
        test_centroid.call (FuzzySet 10.0 10.0 10.0 31.0 "lra") 0.5 17.0
        test_centroid.call (FuzzySet 0.0 21.0 21.0 21.0 "rra")  0.5 14.0
        test_centroid.call (FuzzySet 10.0 31.0 31.0 31.0 "rra")  0.5 24.0
        test_centroid.call (FuzzySet 0.0 21.0 21.0 21.0 "rra")  1.0 14.0
        test_centroid.call (FuzzySet 0.0 10.0 20.0 30.0 "trap") 0.5 15.0
        test_centroid.call (FuzzySet 10.0 10.0 10.0 31.0 "lra") 1.0 17.0
        test_centroid.call (FuzzySet 0.0 0.0 10.0 31.0 "ltrap") 1.0 11.146341463414634276

        tri1 := (FuzzySet 0.0 10.0 10.0 20.0 "tri1")
        tri1.pertinence 1.0

        tri2 := (FuzzySet 10.0 20.0 20.0 30.0 "tri2")
        tri1.pertinence 1.0

        composition.clear
        composition.union tri1
        


    TEST "Composition" "2 sets"

/*
    TEST "Composition" "build":
        composition := Composition

        composition.add_point 0.0 0.0
        composition.add_point 10.0 1.0
        composition.add_point 20.0 0.0
        
        composition.add_point 10.0 0.0
        composition.add_point 20.0 1.0
        composition.add_point 30.0 0.0

        ASSERT_RUNS: composition.build

        ASSERT_TRUE (composition.any_point 0.0 0.0)
        ASSERT_TRUE (composition.any_point 10.0 1.0)
        ASSERT_FALSE (composition.any_point 20.0 0.0)
        ASSERT_TRUE (composition.any_point 15.0 0.5)
        ASSERT_FALSE (composition.any_point 10.0 0.0)
        ASSERT_TRUE (composition.any_point 20.0 1.0)
        ASSERT_TRUE (composition.any_point 30.0 0.0)
*/        
    TEST_END