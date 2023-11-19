// Copyright (c) 2021 Ekorau LLC

import btest show *

import fuzzy-logic show *

main:
  fuzzy := FuzzyModel
  // FuzzyInput
  temperature := FuzzyInput "temperature"
  veryLow :=  FuzzySet -5 -5 0 15
  low := FuzzySet 10 20 20 30
  high := FuzzySet 25 30 30 35
  veryHigh := FuzzySet 30 45 50 50
  temperature.add-all-sets [veryLow, low, high, veryHigh]
  fuzzy.add-input temperature

  humidity := FuzzyInput "humidity"
  dry := FuzzySet -5 -5 0 30
  comfortable := FuzzySet 20 35 35 50
  humid := FuzzySet 40 55 55 70
  sticky := FuzzySet 60 100 105 105
  humidity.add-all-sets [dry, comfortable, humid, sticky]
  fuzzy.add-input humidity

  speed := FuzzyOutput "speed"
  off := FuzzySet 0 0 0 0
  lowHumidity := FuzzySet 30 45 45 60
  medium := FuzzySet 50 65 65 80
  fast := FuzzySet 70 90 95 95
  speed.add-all-sets [off, lowHumidity, medium, fast]
  fuzzy.add-output speed
  
  fuzzy.add-rule (FuzzyRule (Antecedent.AND-sets veryLow dry)          (Consequent.output off))
  fuzzy.add-rule (FuzzyRule (Antecedent.AND-sets veryLow comfortable)  (Consequent.output off))
  fuzzy.add-rule (FuzzyRule (Antecedent.AND-sets veryLow humid)        (Consequent.output off))
  fuzzy.add-rule (FuzzyRule (Antecedent.AND-sets veryLow sticky)       (Consequent.output lowHumidity))
  fuzzy.add-rule (FuzzyRule (Antecedent.AND-sets low dry)              (Consequent.output off))
  fuzzy.add-rule (FuzzyRule (Antecedent.AND-sets low comfortable)      (Consequent.output off))
  fuzzy.add-rule (FuzzyRule (Antecedent.AND-sets low humid)            (Consequent.output lowHumidity))
  fuzzy.add-rule (FuzzyRule (Antecedent.AND-sets low sticky)           (Consequent.output medium))
  fuzzy.add-rule (FuzzyRule (Antecedent.AND-sets high dry)             (Consequent.output lowHumidity))
  fuzzy.add-rule (FuzzyRule (Antecedent.AND-sets high comfortable)     (Consequent.output medium))
  fuzzy.add-rule (FuzzyRule (Antecedent.AND-sets high humid)           (Consequent.output fast))
  fuzzy.add-rule (FuzzyRule (Antecedent.AND-sets high sticky)          (Consequent.output fast))
  fuzzy.add-rule (FuzzyRule (Antecedent.AND-sets veryHigh dry)         (Consequent.output medium))
  fuzzy.add-rule (FuzzyRule (Antecedent.AND-sets veryHigh comfortable) (Consequent.output fast))
  fuzzy.add-rule (FuzzyRule (Antecedent.AND-sets veryHigh humid)       (Consequent.output fast))
  fuzzy.add-rule (FuzzyRule (Antecedent.AND-sets veryHigh sticky)      (Consequent.output fast))


  result := 0.0
  for t := 0; t <= 15; t += 5:  // 0 to 45 degrees
    for h := 0; h <= 20; h+= 10: // 0 to 100% humidity
      fuzzy.crisp-input 0 t
      fuzzy.crisp-input 1 h

      fuzzy.changed
      fuzzy.fuzzify

      result = fuzzy.defuzzify 0

      print "Running with: Temperature->$t, Humidity->$h. Result: $(%.1f result)"
  