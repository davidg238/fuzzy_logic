// Copyright (c) 2021 Ekorau LLC

import btest show *
import fuzzy_logic show *

main:
  throw "Test to be revised"
/*
  set := null
  composition := Composition
  test_centroid := : | set pert answer |
    set.pertinence pert
    composition.clear
    composition.union set.truncated
    print "$pert / $composition / $answer / $composition.centroid_x"

  test_centroid.call (FuzzySet 0.0 10.0 10.0 20.0 "tri")  0.5 10.0
  test_centroid.call (FuzzySet 10.0 20.0 20.0 30.0 "tri") 0.5 20.0
  test_centroid.call (FuzzySet 0.0 0.0 0.0 21.0 "lra")    1.0 7.0
  test_centroid.call (FuzzySet 10.0 10.0 10.0 31.0 "lra") 1.0 17.0
  test_centroid.call (FuzzySet 0.0 21.0 21.0 21.0 "rra")  1.0 14.0
  test_centroid.call (FuzzySet 10.0 31.0 31.0 31.0 "rra")  1.0 24.0
  test_centroid.call (FuzzySet 0.0 21.0 21.0 21.0 "rra")  1.0 14.0
  test_centroid.call (FuzzySet 0.0 10.0 20.0 30.0 "trap") 0.5 15.0
  test_centroid.call (FuzzySet 10 10 10 31 "lra") 1.0 17.0
  test_centroid.call (FuzzySet 0.0 0.0 10.0 31.0 "ltrap") 1.0 11.146341463414634276

  tri1 := (FuzzySet 0.0 10.0 10.0 20.0 "tri1")
  tri1.pertinence 1.0

  tri2 := (FuzzySet 10.0 20.0 20.0 30.0 "tri2")
  tri1.pertinence 1.0

  composition.clear
        
  composition.union tri1
  composition.union tri2      


  test "Composition" "2 sets"  //todo, rebuild
*/
/*
    TEST "Composition" "build":
        composition := Composition

        composition.test_add_point 0.0 0.0
        composition.test_add_point 10.0 1.0
        composition.test_add_point 20.0 0.0
        
        composition.test_add_point 10.0 0.0
        composition.test_add_point 20.0 1.0
        composition.test_add_point 30.0 0.0

        ASSERT_RUNS: composition.build

        ASSERT_TRUE (composition.test_any_point 0.0 0.0)
        ASSERT_TRUE (composition.test_any_point 10.0 1.0)
        ASSERT_FALSE (composition.test_any_point 20.0 0.0)
        ASSERT_TRUE (composition.test_any_point 15.0 0.5)
        ASSERT_FALSE (composition.test_any_point 10.0 0.0)
        ASSERT_TRUE (composition.test_any_point 20.0 1.0)
        ASSERT_TRUE (composition.test_any_point 30.0 0.0)
*/        