// Copyright (c) 2025 Ekorau LLC
// Integration tests with real-world fuzzy logic scenarios

import btest show *
import fuzzy-logic show *

main:
  test "Integration" "temperature control system":
    // Simulate a temperature control system
    fuzzy := FuzzyModel "temperature_controller"
    
    // Temperature input (current temperature)
    temperature := FuzzyInput "temperature"
    cold := FuzzySet -10.0 -10.0 5.0 15.0 "cold"
    cool := FuzzySet 10.0 18.0 22.0 25.0 "cool"
    warm := FuzzySet 22.0 25.0 28.0 32.0 "warm"
    hot := FuzzySet 28.0 35.0 45.0 45.0 "hot"
    temperature.add-all-sets [cold, cool, warm, hot]
    fuzzy.add_input temperature
    
    // Temperature change rate input
    rate := FuzzyInput "rate"
    falling_fast := FuzzySet -5.0 -5.0 -2.0 -1.0 "falling_fast"
    falling := FuzzySet -2.0 -1.0 -0.5  0.0 "falling"
    stable := FuzzySet -0.5 0.0 0.0 0.5 "stable"
    rising := FuzzySet 0.0 0.5 1.0 2.0 "rising"
    rising_fast := FuzzySet 1.0 2.0 5.0 5.0 "rising_fast"
    rate.add-all-sets [falling_fast, falling, stable, rising, rising_fast]
    fuzzy.add_input rate
    
    // Heater output
    heater := FuzzyOutput "heater"
    off := FuzzySet 0.0 0.0 0.0 0.0 "off"
    low := FuzzySet 0.0 10.0 20.0 30.0 "low"
    medium := FuzzySet 20.0 40.0 60.0 80.0 "medium"
    high := FuzzySet 70.0 90.0 100.0 100.0 "high"
    heater.add-all-sets [off, low, medium, high]
    fuzzy.add_output heater
    
    // Rules for temperature control
    rules := [
      // Cold conditions - need heating
      FuzzyRule.fl-if (Antecedent-And cold falling_fast) --fl-then=(Consequent.output high),
      FuzzyRule.fl-if (Antecedent-And cold falling) --fl-then=(Consequent.output high),
      FuzzyRule.fl-if (Antecedent-And cold stable) --fl-then=(Consequent.output medium),
      FuzzyRule.fl-if (Antecedent-And cold rising) --fl-then=(Consequent.output low),
      FuzzyRule.fl-if (Antecedent-And cold rising_fast) --fl-then=(Consequent.output off),
      
      // Cool conditions
      FuzzyRule.fl-if (Antecedent-And cool falling) --fl-then=(Consequent.output medium),
      FuzzyRule.fl-if (Antecedent-And cool stable) --fl-then=(Consequent.output low),
      FuzzyRule.fl-if (Antecedent-And cool rising) --fl-then=(Consequent.output off),
      
      // Warm conditions
      FuzzyRule.fl-if (Antecedent-And warm falling) --fl-then=(Consequent.output low),
      FuzzyRule.fl-if (Antecedent-And warm stable) --fl-then=(Consequent.output off),
      FuzzyRule.fl-if (Antecedent-And warm rising) --fl-then=(Consequent.output off),
      
      // Hot conditions - no heating needed
      FuzzyRule.fl-if (Antecedent-And hot falling_fast) --fl-then=(Consequent.output off),
      FuzzyRule.fl-if (Antecedent-And hot falling) --fl-then=(Consequent.output off),
      FuzzyRule.fl-if (Antecedent-And hot stable) --fl-then=(Consequent.output off),
      FuzzyRule.fl-if (Antecedent-And hot rising) --fl-then=(Consequent.output off),
    ]
    
    rules.do: | rule | fuzzy.add_rule rule
    
    // Test scenarios
    test_scenarios := [
      {"temp": 5.0, "rate": -1.0, "expected_range": [60.0, 100.0]},  // Cold and falling - high heat
      {"temp": 20.0, "rate": 0.0, "expected_range": [0.0, 30.0]},    // Cool and stable - low heat
      {"temp": 26.0, "rate": 0.5, "expected_range": [0.0, 10.0]},    // Warm and rising - minimal heat
      {"temp": 35.0, "rate": 1.0, "expected_range": [0.0, 5.0]},     // Hot and rising - no heat
    ]
    
    test_scenarios.do: | scenario |
      fuzzy.crisp_input 0 scenario["temp"]
      fuzzy.crisp_input 1 scenario["rate"]
      fuzzy.fuzzify
      result := fuzzy.defuzzify 0
      
      min_expected := scenario["expected_range"][0]
      max_expected := scenario["expected_range"][1]
      
      print "Temp: $(scenario["temp"])°C, Rate: $(scenario["rate"])°C/min -> Heater: $(%.1f result)%"
      expect_true result >= min_expected
      expect_true result <= max_expected

  test "Integration" "investment risk assessment":
    // Simulate an investment risk assessment system
    fuzzy := FuzzyModel "risk_assessment"
    
    // Market volatility input
    volatility := FuzzyInput "volatility"
    very_low := FuzzySet 0.0 0.0 5.0 15.0 "very_low"
    low := FuzzySet 10.0 20.0 25.0 35.0 "low"
    moderate := FuzzySet 30.0 40.0 50.0 60.0 "moderate"
    high := FuzzySet 55.0 65.0 75.0 85.0 "high"
    very_high := FuzzySet 80.0 90.0 100.0 100.0 "very_high"
    volatility.add-all-sets [very_low, low, moderate, high, very_high]
    fuzzy.add_input volatility
    
    // Company size input (market cap in billions)
    company_size := FuzzyInput "company_size"
    small := FuzzySet 0.0 0.0 1.0 5.0 "small"
    medium := FuzzySet 2.0 10.0 20.0 50.0 "medium"
    large := FuzzySet 30.0 75.0 200.0 500.0 "large"
    mega := FuzzySet 200.0 500.0 1000.0 1000.0 "mega"
    company_size.add-all-sets [small, medium, large, mega]
    fuzzy.add_input company_size
    
    // Investment recommendation output
    recommendation := FuzzyOutput "recommendation"
    avoid := FuzzySet 0.0 0.0 10.0 20.0 "avoid"
    conservative := FuzzySet 15.0 25.0 35.0 45.0 "conservative"
    balanced := FuzzySet 40.0 50.0 60.0 70.0 "balanced"
    aggressive := FuzzySet 65.0 75.0 85.0 95.0 "aggressive"
    max_invest := FuzzySet 90.0 95.0 100.0 100.0 "max_invest"
    recommendation.add-all-sets [avoid, conservative, balanced, aggressive, max_invest]
    fuzzy.add_output recommendation
    
    // Investment rules
    investment_rules := [
      // High volatility scenarios
      FuzzyRule.fl-if (Antecedent-And very_high small) --fl-then=(Consequent.output avoid),
      FuzzyRule.fl-if (Antecedent-And very_high medium) --fl-then=(Consequent.output avoid),
      FuzzyRule.fl-if (Antecedent-And very_high large) --fl-then=(Consequent.output conservative),
      FuzzyRule.fl-if (Antecedent-And very_high mega) --fl-then=(Consequent.output conservative),
      
      // High volatility
      FuzzyRule.fl-if (Antecedent-And high small) --fl-then=(Consequent.output avoid),
      FuzzyRule.fl-if (Antecedent-And high medium) --fl-then=(Consequent.output conservative),
      FuzzyRule.fl-if (Antecedent-And high large) --fl-then=(Consequent.output balanced),
      FuzzyRule.fl-if (Antecedent-And high mega) --fl-then=(Consequent.output balanced),
      
      // Moderate volatility
      FuzzyRule.fl-if (Antecedent-And moderate small) --fl-then=(Consequent.output conservative),
      FuzzyRule.fl-if (Antecedent-And moderate medium) --fl-then=(Consequent.output balanced),
      FuzzyRule.fl-if (Antecedent-And moderate large) --fl-then=(Consequent.output aggressive),
      FuzzyRule.fl-if (Antecedent-And moderate mega) --fl-then=(Consequent.output aggressive),
      
      // Low volatility
      FuzzyRule.fl-if (Antecedent-And low small) --fl-then=(Consequent.output balanced),
      FuzzyRule.fl-if (Antecedent-And low medium) --fl-then=(Consequent.output aggressive),
      FuzzyRule.fl-if (Antecedent-And low large) --fl-then=(Consequent.output max_invest),
      FuzzyRule.fl-if (Antecedent-And low mega) --fl-then=(Consequent.output max_invest),
      
      // Very low volatility
      FuzzyRule.fl-if (Antecedent-And very_low small) --fl-then=(Consequent.output aggressive),
      FuzzyRule.fl-if (Antecedent-And very_low medium) --fl-then=(Consequent.output max_invest),
      FuzzyRule.fl-if (Antecedent-And very_low large) --fl-then=(Consequent.output max_invest),
      FuzzyRule.fl-if (Antecedent-And very_low mega) --fl-then=(Consequent.output max_invest),
    ]
    
    investment_rules.do: | rule | fuzzy.add_rule rule
    
    // Test investment scenarios
    investment_scenarios := [
      {"volatility": 95.0, "size": 0.5, "description": "High volatility, small cap"},
      {"volatility": 70.0, "size": 15.0, "description": "High volatility, medium cap"},
      {"volatility": 45.0, "size": 100.0, "description": "Moderate volatility, large cap"},
      {"volatility": 15.0, "size": 300.0, "description": "Low volatility, mega cap"},
      {"volatility": 5.0, "size": 8.0, "description": "Very low volatility, medium cap"},
    ]
    
    investment_scenarios.do: | scenario |
      fuzzy.crisp_input 0 scenario["volatility"]
      fuzzy.crisp_input 1 scenario["size"]
      fuzzy.fuzzify
      result := fuzzy.defuzzify 0
      
      print "$(scenario["description"]): Recommendation score $(%.1f result)/100"
      expect_true result >= 0.0
      expect_true result <= 100.0

  test "Integration" "traffic light optimization":
    // Traffic light timing optimization based on traffic flow
    fuzzy := FuzzyModel "traffic_light"
    
    // Main road traffic density
    main_traffic := FuzzyInput "main_traffic"
    none := FuzzySet 0.0 0.0 5.0 15.0 "none"
    light := FuzzySet 10.0 20.0 30.0 40.0 "light"
    moderate := FuzzySet 35.0 45.0 55.0 65.0 "moderate"
    heavy := FuzzySet 60.0 70.0 80.0 90.0 "heavy"
    jam := FuzzySet 85.0 95.0 100.0 100.0 "jam"
    main_traffic.add-all-sets [none, light, moderate, heavy, jam]
    fuzzy.add_input main_traffic
    
    // Side road traffic density
    side_traffic := FuzzyInput "side_traffic"
    side_none := FuzzySet 0.0 0.0 5.0 15.0 "side_none"
    side_light := FuzzySet 10.0 20.0 30.0 40.0 "side_light"
    side_moderate := FuzzySet 35.0 45.0 55.0 65.0 "side_moderate"
    side_heavy := FuzzySet 60.0 75.0 85.0 95.0 "side_heavy"
    side_traffic.add-all-sets [side_none, side_light, side_moderate, side_heavy]
    fuzzy.add_input side_traffic
    
    // Green light duration for main road (in seconds)
    green_duration := FuzzyOutput "green_duration"
    very_short := FuzzySet 10.0 10.0 15.0 25.0 "very_short"
    short := FuzzySet 20.0 30.0 40.0 50.0 "short"
    normal := FuzzySet 45.0 55.0 65.0 75.0 "normal"
    long := FuzzySet 70.0 80.0 90.0 100.0 "long"
    very_long := FuzzySet 95.0 105.0 120.0 120.0 "very_long"
    green_duration.add-all-sets [very_short, short, normal, long, very_long]
    fuzzy.add_output green_duration
    
    // Traffic light timing rules
    traffic_rules := [
      // Main road jam - prioritize main road
      FuzzyRule.fl-if (Antecedent-And jam side_none) --fl-then=(Consequent.output very_long),
      FuzzyRule.fl-if (Antecedent-And jam side_light) --fl-then=(Consequent.output very_long),
      FuzzyRule.fl-if (Antecedent-And jam side_moderate) --fl-then=(Consequent.output long),
      FuzzyRule.fl-if (Antecedent-And jam side_heavy) --fl-then=(Consequent.output long),
      
      // Main road heavy traffic
      FuzzyRule.fl-if (Antecedent-And heavy side_none) --fl-then=(Consequent.output long),
      FuzzyRule.fl-if (Antecedent-And heavy side_light) --fl-then=(Consequent.output long),
      FuzzyRule.fl-if (Antecedent-And heavy side_moderate) --fl-then=(Consequent.output normal),
      FuzzyRule.fl-if (Antecedent-And heavy side_heavy) --fl-then=(Consequent.output normal),
      
      // Main road moderate traffic
      FuzzyRule.fl-if (Antecedent-And moderate side_none) --fl-then=(Consequent.output normal),
      FuzzyRule.fl-if (Antecedent-And moderate side_light) --fl-then=(Consequent.output normal),
      FuzzyRule.fl-if (Antecedent-And moderate side_moderate) --fl-then=(Consequent.output short),
      FuzzyRule.fl-if (Antecedent-And moderate side_heavy) --fl-then=(Consequent.output short),
      
      // Main road light traffic
      FuzzyRule.fl-if (Antecedent-And light side_none) --fl-then=(Consequent.output short),
      FuzzyRule.fl-if (Antecedent-And light side_light) --fl-then=(Consequent.output short),
      FuzzyRule.fl-if (Antecedent-And light side_moderate) --fl-then=(Consequent.output very_short),
      FuzzyRule.fl-if (Antecedent-And light side_heavy) --fl-then=(Consequent.output very_short),
      
      // Main road no traffic
      FuzzyRule.fl-if (Antecedent-And none side_none) --fl-then=(Consequent.output very_short),
      FuzzyRule.fl-if (Antecedent-And none side_light) --fl-then=(Consequent.output very_short),
      FuzzyRule.fl-if (Antecedent-And none side_moderate) --fl-then=(Consequent.output very_short),
      FuzzyRule.fl-if (Antecedent-And none side_heavy) --fl-then=(Consequent.output very_short),
    ]
    
    traffic_rules.do: | rule | fuzzy.add_rule rule
    
    // Test traffic scenarios
    traffic_scenarios := [
      {"main": 95.0, "side": 5.0, "description": "Rush hour - main road jammed"},
      {"main": 75.0, "side": 60.0, "description": "Heavy traffic both roads"},
      {"main": 50.0, "side": 25.0, "description": "Moderate main, light side"},
      {"main": 25.0, "side": 70.0, "description": "Light main, heavy side"},
      {"main": 5.0, "side": 5.0, "description": "Off-peak hours"},
    ]
    
    traffic_scenarios.do: | scenario |
      fuzzy.crisp_input 0 scenario["main"]
      fuzzy.crisp_input 1 scenario["side"]
      fuzzy.fuzzify
      result := fuzzy.defuzzify 0
      
      print "$(scenario["description"]): Green light $(%.0f result) seconds"
      expect_true result >= 10.0
      expect_true result <= 120.0

  test-end