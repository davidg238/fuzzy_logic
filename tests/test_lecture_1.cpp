// ##### Tests from explanation Fuzzy System

// From: https://www.massey.ac.nz/~nhreyes/MASSEY/159741/Lectures/Lec2012-3-159741-FuzzyLogic-v.2.pdf
TEST(Fuzzy, testFromLectureSystemsOne)
{
    Fuzzy *fuzzy = new Fuzzy();

    // FuzzyInput
    FuzzyInput *size = new FuzzyInput(1);

    FuzzySet *smallSize = new FuzzySet(0, 0, 0, 10);
    size->addFuzzySet(smallSize);
    FuzzySet *largeSize = new FuzzySet(0, 10, 10, 10);
    size->addFuzzySet(largeSize);

    fuzzy->addFuzzyInput(size);

    // FuzzyInput
    FuzzyInput *weight = new FuzzyInput(2);

    FuzzySet *smallWeight = new FuzzySet(0, 0, 0, 100);
    weight->addFuzzySet(smallWeight);
    FuzzySet *largeWeight = new FuzzySet(0, 100, 100, 100);
    weight->addFuzzySet(largeWeight);

    fuzzy->addFuzzyInput(weight);

    // FuzzyOutput
    FuzzyOutput *quality = new FuzzyOutput(1);

    FuzzySet *bad = new FuzzySet(0, 0, 0, 0.5);
    quality->addFuzzySet(bad);
    FuzzySet *medium = new FuzzySet(0, 0.5, 0.5, 1.0);
    quality->addFuzzySet(medium);
    FuzzySet *good = new FuzzySet(0.5, 1.0, 1.0, 1.0);
    quality->addFuzzySet(good);

    fuzzy->addFuzzyOutput(quality);

    // Building FuzzyRule
    FuzzyRuleAntecedent *ifSizeSmallAndWeightSmall = new FuzzyRuleAntecedent();
    ifSizeSmallAndWeightSmall->joinWithAND(smallSize, smallWeight);
    FuzzyRuleConsequent *thenQualityBad = new FuzzyRuleConsequent();
    thenQualityBad->addOutput(bad);
    FuzzyRule *fuzzyRule1 = new FuzzyRule(1, ifSizeSmallAndWeightSmall, thenQualityBad);
    fuzzy->addFuzzyRule(fuzzyRule1);

    // Building FuzzyRule
    FuzzyRuleAntecedent *ifSizeSmallAndWeightLarge = new FuzzyRuleAntecedent();
    ifSizeSmallAndWeightLarge->joinWithAND(smallSize, largeWeight);
    FuzzyRuleConsequent *thenQualityMedium1 = new FuzzyRuleConsequent();
    thenQualityMedium1->addOutput(medium);
    FuzzyRule *fuzzyRule2 = new FuzzyRule(2, ifSizeSmallAndWeightLarge, thenQualityMedium1);
    fuzzy->addFuzzyRule(fuzzyRule2);

    // Building FuzzyRule
    FuzzyRuleAntecedent *ifSizeLargeAndWeightSmall = new FuzzyRuleAntecedent();
    ifSizeLargeAndWeightSmall->joinWithAND(largeSize, smallWeight);
    FuzzyRuleConsequent *thenQualityMedium2 = new FuzzyRuleConsequent();
    thenQualityMedium2->addOutput(medium);
    FuzzyRule *fuzzyRule3 = new FuzzyRule(3, ifSizeLargeAndWeightSmall, thenQualityMedium2);
    fuzzy->addFuzzyRule(fuzzyRule3);

    // Building FuzzyRule
    FuzzyRuleAntecedent *ifSizeLargeAndWeightLarge = new FuzzyRuleAntecedent();
    ifSizeLargeAndWeightLarge->joinWithAND(largeSize, largeWeight);
    FuzzyRuleConsequent *thenQualityGood = new FuzzyRuleConsequent();
    thenQualityGood->addOutput(good);
    FuzzyRule *fuzzyRule4 = new FuzzyRule(4, ifSizeLargeAndWeightLarge, thenQualityGood);
    fuzzy->addFuzzyRule(fuzzyRule4);

    // run it
    fuzzy->setInput(1, 2);
    fuzzy->setInput(2, 25);
    fuzzy->fuzzify();

    ASSERT_FLOAT_EQ(0.75, ifSizeSmallAndWeightSmall->evaluate());
    ASSERT_FLOAT_EQ(0.25, ifSizeSmallAndWeightLarge->evaluate());
    ASSERT_FLOAT_EQ(0.2, ifSizeLargeAndWeightSmall->evaluate());
    ASSERT_FLOAT_EQ(0.2, ifSizeLargeAndWeightLarge->evaluate());

    ASSERT_FLOAT_EQ(0.37692466, fuzzy->defuzzify(1)); // 0.3698 on the paper
}

// From: http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.486.1238&rep=rep1&type=pdf
TEST(Fuzzy, testFromLectureSystemsTwo)
{
    Fuzzy *fuzzy = new Fuzzy();

    // FuzzyInput
    FuzzyInput *temperature = new FuzzyInput(1);

    FuzzySet *veryLow = new FuzzySet(-5, -5, -5, 15);
    temperature->addFuzzySet(veryLow);
    FuzzySet *low = new FuzzySet(10, 20, 20, 30);
    temperature->addFuzzySet(low);
    FuzzySet *high = new FuzzySet(25, 30, 30, 35);
    temperature->addFuzzySet(high);
    FuzzySet *veryHigh = new FuzzySet(30, 50, 50, 50);
    temperature->addFuzzySet(veryHigh);

    fuzzy->addFuzzyInput(temperature);

    // FuzzyInput
    FuzzyInput *humidity = new FuzzyInput(2);

    FuzzySet *dry = new FuzzySet(-5, -5, -5, 30);
    humidity->addFuzzySet(dry);
    FuzzySet *comfortable = new FuzzySet(20, 35, 35, 50);
    humidity->addFuzzySet(comfortable);
    FuzzySet *humid = new FuzzySet(40, 55, 55, 70);
    humidity->addFuzzySet(humid);
    FuzzySet *sticky = new FuzzySet(60, 100, 100, 100);
    humidity->addFuzzySet(sticky);

    fuzzy->addFuzzyInput(humidity);

    // FuzzyOutput
    FuzzyOutput *speed = new FuzzyOutput(1);

    FuzzySet *off = new FuzzySet(0, 0, 0, 0);
    speed->addFuzzySet(off);
    FuzzySet *lowHumidity = new FuzzySet(30, 45, 45, 60);
    speed->addFuzzySet(lowHumidity);
    FuzzySet *medium = new FuzzySet(50, 65, 65, 80);
    speed->addFuzzySet(medium);
    FuzzySet *fast = new FuzzySet(70, 90, 95, 95);
    speed->addFuzzySet(fast);

    fuzzy->addFuzzyOutput(speed);

    // Building FuzzyRule
    FuzzyRuleAntecedent *ifVeryLowAndDry = new FuzzyRuleAntecedent();
    ifVeryLowAndDry->joinWithAND(veryLow, dry);
    FuzzyRuleConsequent *thenOff1 = new FuzzyRuleConsequent();
    thenOff1->addOutput(off);
    FuzzyRule *fuzzyRule1 = new FuzzyRule(1, ifVeryLowAndDry, thenOff1);
    fuzzy->addFuzzyRule(fuzzyRule1);

    // Building FuzzyRule
    FuzzyRuleAntecedent *ifVeryLowAndComfortable = new FuzzyRuleAntecedent();
    ifVeryLowAndComfortable->joinWithAND(veryLow, comfortable);
    FuzzyRuleConsequent *thenOff2 = new FuzzyRuleConsequent();
    thenOff2->addOutput(off);
    FuzzyRule *fuzzyRule2 = new FuzzyRule(2, ifVeryLowAndComfortable, thenOff2);
    fuzzy->addFuzzyRule(fuzzyRule2);

    // Building FuzzyRule
    FuzzyRuleAntecedent *ifVeryLowAndHumid = new FuzzyRuleAntecedent();
    ifVeryLowAndHumid->joinWithAND(veryLow, humid);
    FuzzyRuleConsequent *thenOff3 = new FuzzyRuleConsequent();
    thenOff3->addOutput(off);
    FuzzyRule *fuzzyRule3 = new FuzzyRule(3, ifVeryLowAndHumid, thenOff3);
    fuzzy->addFuzzyRule(fuzzyRule3);

    // Building FuzzyRule
    FuzzyRuleAntecedent *ifVeryLowAndSticky = new FuzzyRuleAntecedent();
    ifVeryLowAndSticky->joinWithAND(veryLow, sticky);
    FuzzyRuleConsequent *thenLow1 = new FuzzyRuleConsequent();
    thenLow1->addOutput(lowHumidity);
    FuzzyRule *fuzzyRule4 = new FuzzyRule(4, ifVeryLowAndSticky, thenLow1);
    fuzzy->addFuzzyRule(fuzzyRule4);

    // Building FuzzyRule
    FuzzyRuleAntecedent *ifLowAndDry = new FuzzyRuleAntecedent();
    ifLowAndDry->joinWithAND(low, dry);
    FuzzyRuleConsequent *thenOff4 = new FuzzyRuleConsequent();
    thenOff4->addOutput(off);
    FuzzyRule *fuzzyRule5 = new FuzzyRule(5, ifLowAndDry, thenOff4);
    fuzzy->addFuzzyRule(fuzzyRule5);

    // Building FuzzyRule
    FuzzyRuleAntecedent *ifLowAndComfortable = new FuzzyRuleAntecedent();
    ifLowAndComfortable->joinWithAND(low, comfortable);
    FuzzyRuleConsequent *thenOff5 = new FuzzyRuleConsequent();
    thenOff5->addOutput(off);
    FuzzyRule *fuzzyRule6 = new FuzzyRule(6, ifLowAndComfortable, thenOff5);
    fuzzy->addFuzzyRule(fuzzyRule6);

    // Building FuzzyRule
    FuzzyRuleAntecedent *ifLowAndHumid = new FuzzyRuleAntecedent();
    ifLowAndHumid->joinWithAND(low, humid);
    FuzzyRuleConsequent *thenLow2 = new FuzzyRuleConsequent();
    thenLow2->addOutput(lowHumidity);
    FuzzyRule *fuzzyRule7 = new FuzzyRule(7, ifLowAndHumid, thenLow2);
    fuzzy->addFuzzyRule(fuzzyRule7);

    // Building FuzzyRule
    FuzzyRuleAntecedent *ifLowAndSticky = new FuzzyRuleAntecedent();
    ifLowAndSticky->joinWithAND(low, sticky);
    FuzzyRuleConsequent *thenMedium1 = new FuzzyRuleConsequent();
    thenMedium1->addOutput(medium);
    FuzzyRule *fuzzyRule8 = new FuzzyRule(8, ifLowAndSticky, thenMedium1);
    fuzzy->addFuzzyRule(fuzzyRule8);

    // Building FuzzyRule
    FuzzyRuleAntecedent *ifHighAndDry = new FuzzyRuleAntecedent();
    ifHighAndDry->joinWithAND(high, dry);
    FuzzyRuleConsequent *thenLow3 = new FuzzyRuleConsequent();
    thenLow3->addOutput(lowHumidity);
    FuzzyRule *fuzzyRule9 = new FuzzyRule(9, ifHighAndDry, thenLow3);
    fuzzy->addFuzzyRule(fuzzyRule9);

    // Building FuzzyRule
    FuzzyRuleAntecedent *ifHighAndComfortable = new FuzzyRuleAntecedent();
    ifHighAndComfortable->joinWithAND(high, comfortable);
    FuzzyRuleConsequent *thenMedium2 = new FuzzyRuleConsequent();
    thenMedium2->addOutput(medium);
    FuzzyRule *fuzzyRule10 = new FuzzyRule(10, ifHighAndComfortable, thenMedium2);
    fuzzy->addFuzzyRule(fuzzyRule10);

    // Building FuzzyRule
    FuzzyRuleAntecedent *ifHighAndHumid = new FuzzyRuleAntecedent();
    ifHighAndHumid->joinWithAND(high, humid);
    FuzzyRuleConsequent *thenFast1 = new FuzzyRuleConsequent();
    thenFast1->addOutput(fast);
    FuzzyRule *fuzzyRule11 = new FuzzyRule(11, ifHighAndHumid, thenFast1);
    fuzzy->addFuzzyRule(fuzzyRule11);

    // Building FuzzyRule
    FuzzyRuleAntecedent *ifHighAndSticky = new FuzzyRuleAntecedent();
    ifHighAndSticky->joinWithAND(high, sticky);
    FuzzyRuleConsequent *thenFast2 = new FuzzyRuleConsequent();
    thenFast2->addOutput(fast);
    FuzzyRule *fuzzyRule12 = new FuzzyRule(12, ifHighAndSticky, thenFast2);
    fuzzy->addFuzzyRule(fuzzyRule12);

    // Building FuzzyRule
    FuzzyRuleAntecedent *ifVeryHighAndDry = new FuzzyRuleAntecedent();
    ifVeryHighAndDry->joinWithAND(veryHigh, dry);
    FuzzyRuleConsequent *thenMedium3 = new FuzzyRuleConsequent();
    thenMedium3->addOutput(medium);
    FuzzyRule *fuzzyRule13 = new FuzzyRule(13, ifVeryHighAndDry, thenMedium3);
    fuzzy->addFuzzyRule(fuzzyRule13);

    // Building FuzzyRule
    FuzzyRuleAntecedent *ifVeryHighAndComfortable = new FuzzyRuleAntecedent();
    ifVeryHighAndComfortable->joinWithAND(veryHigh, comfortable);
    FuzzyRuleConsequent *thenFast3 = new FuzzyRuleConsequent();
    thenFast3->addOutput(fast);
    FuzzyRule *fuzzyRule14 = new FuzzyRule(14, ifVeryHighAndComfortable, thenFast3);
    fuzzy->addFuzzyRule(fuzzyRule14);

    // Building FuzzyRule
    FuzzyRuleAntecedent *ifVeryHighAndHumid = new FuzzyRuleAntecedent();
    ifVeryHighAndHumid->joinWithAND(veryHigh, humid);
    FuzzyRuleConsequent *thenFast4 = new FuzzyRuleConsequent();
    thenFast4->addOutput(fast);
    FuzzyRule *fuzzyRule15 = new FuzzyRule(15, ifVeryHighAndHumid, thenFast4);
    fuzzy->addFuzzyRule(fuzzyRule15);

    // Building FuzzyRule
    FuzzyRuleAntecedent *ifVeryHighAndSticky = new FuzzyRuleAntecedent();
    ifVeryHighAndSticky->joinWithAND(veryHigh, sticky);
    FuzzyRuleConsequent *thenFast5 = new FuzzyRuleConsequent();
    thenFast5->addOutput(fast);
    FuzzyRule *fuzzyRule16 = new FuzzyRule(16, ifVeryHighAndSticky, thenFast5);
    fuzzy->addFuzzyRule(fuzzyRule16);

    // run it
    fuzzy->setInput(1, 20);
    fuzzy->setInput(2, 65);
    fuzzy->fuzzify();

    ASSERT_FLOAT_EQ(50.568535, fuzzy->defuzzify(1)); // This value was not extracted from the paper
}