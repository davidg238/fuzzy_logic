import encoding.json
import .models

main:

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
  fuzzy := get_casco

  i := 1
  cases.do: |inputs|
    fuzzy.crisp_inputs inputs
    fuzzy.changed
    fuzzy.fuzzify
    print "test $i crisp = $(fuzzy.defuzzify 0)"
    i += 1