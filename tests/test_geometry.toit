// Copyright (c) 2021 Ekorau LLC

import btest show *
import fuzzy-logic show FuzzyOutput FuzzySet

main:
  
  test-start
  test "Centroid calculation FuzzySet types" "testFrom":

    result := 0.0
    fout := FuzzyOutput
    test-centroid := : | set pert answer |
      fout.add-set set
      fout.clear
      set.max pert
      result = fout.defuzzify
      expect-near answer result
      fout.clear

    test-centroid.call (FuzzySet 0.0 10.0 10.0 20.0 "tri")  0.5 10.0
    test-centroid.call (FuzzySet 10.0 20.0 20.0 30.0 "tri") 0.5 20.0
    test-centroid.call (FuzzySet 0.0 0.0 0.0 21.0 "lra")    1.0 7.0
    test-centroid.call (FuzzySet 10.0 10.0 10.0 31.0 "lra") 1.0 17.0
    test-centroid.call (FuzzySet 0.0 21.0 21.0 21.0 "rra")  1.0 14.0
    test-centroid.call (FuzzySet 10.0 31.0 31.0 31.0 "rra")  1.0 24.0
    test-centroid.call (FuzzySet 0.0 21.0 21.0 21.0 "rra")  1.0 14.0
    test-centroid.call (FuzzySet 0.0 10.0 20.0 30.0 "trap") 0.5 15.0
    test-centroid.call (FuzzySet 10 10 10 31 "lra") 1.0 17.0
    test-centroid.call (FuzzySet 0.0 0.0 10.0 31.0 "ltrap") 1.0 11.146341463414634276


  test-end