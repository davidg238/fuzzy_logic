import .test_util show *

import fuzzy_model show FuzzyModel
import composition show Composition
import fuzzy_input show FuzzyInput
import fuzzy_output show FuzzyOutput
import fuzzy_set show FuzzySet
import fuzzy_rule show FuzzyRule
import antecedent show Antecedent
import consequent show Consequent

import set_triangular show TriangularSet
import set_trapezoidal show TrapezoidalSet
import set_trapezoidal_l show LTrapezoidalSet
import set_trapezoidal_r show RTrapezoidalSet

main:

  throw "Test to be revised"  //TODO

/*
TEST(Fuzzy, setInputAndFuzzifyAndDefuzzify09)
{
    // Instantiating an object of library
    Fuzzy *fuzzy = new Fuzzy();

    FuzzyInput *shift;
    FuzzyInput *distance;

    FuzzyOutput *steeringangle;
    FuzzyOutput *runningspeed;

    FuzzyRuleAntecedent *ifShiftS_4AndDistanceD_0;
    FuzzyRuleConsequent *thenSteeringangleAng_4AndRunningspeedSpeed_2;
    FuzzyRule *fuzzyRule1;

    FuzzyRuleAntecedent *ifShiftS_4AndDistanceD_1;
    FuzzyRuleConsequent *thenSteeringangleAng_4AndRunningspeedSpeed_1;
    FuzzyRule *fuzzyRule2;

    FuzzyRuleAntecedent *ifShiftS_4AndDistanceD_2;
    FuzzyRule *fuzzyRule3;

    FuzzyRuleAntecedent *ifShiftS_4AndDistanceD_3;
    FuzzyRuleConsequent *thenSteeringangleAng_4AndRunningspeedSpeed_0;
    FuzzyRule *fuzzyRule4;

    FuzzyRuleAntecedent *ifShiftS_4AndDistanceD_4;
    FuzzyRule *fuzzyRule5;

    FuzzyRuleAntecedent *ifShiftS_3AndDistanceD_0;
    FuzzyRuleConsequent *thenSteeringangleAng_3AndRunningspeedSpeed_3;
    FuzzyRule *fuzzyRule6;

    FuzzyRuleAntecedent *ifShiftS_3AndDistanceD_1;
    FuzzyRuleConsequent *thenSteeringangleAng_3AndRunningspeedSpeed_2;
    FuzzyRule *fuzzyRule7;

    FuzzyRuleAntecedent *ifShiftS_3AndDistanceD_2;
    FuzzyRuleConsequent *thenSteeringangleAng_3AndRunningspeedSpeed_1;
    FuzzyRule *fuzzyRule8;

    FuzzyRuleAntecedent *ifShiftS_3AndDistanceD_3;
    FuzzyRule *fuzzyRule9;

    FuzzyRuleAntecedent *ifShiftS_3AndDistanceD_4;
    FuzzyRuleConsequent *thenSteeringangleAng_3AndRunningspeedSpeed_0;
    FuzzyRule *fuzzyRule10;

    FuzzyRuleAntecedent *ifShiftS_2;
    FuzzyRuleConsequent *thenSteeringangleAng_2AndRunningspeedSpeed_4;
    FuzzyRule *fuzzyRule11;

    FuzzyRuleAntecedent *ifShiftS_1AndDistanceD_0;
    FuzzyRuleConsequent *thenSteeringangleAng_1AndRunningspeedSpeed_3;
    FuzzyRule *fuzzyRule12;

    FuzzyRuleAntecedent *ifShiftS_1AndDistanceD_1;
    FuzzyRuleConsequent *thenSteeringangleAng_1AndRunningspeedSpeed_2;
    FuzzyRule *fuzzyRule13;

    FuzzyRuleAntecedent *ifShiftS_1AndDistanceD_2;
    FuzzyRuleConsequent *thenSteeringangleAng_1AndRunningspeedSpeed_1;
    FuzzyRule *fuzzyRule14;

    FuzzyRuleAntecedent *ifShiftS_1AndDistanceD_3;
    FuzzyRule *fuzzyRule15;

    FuzzyRuleAntecedent *ifShiftS_1AndDistanceD_4;
    FuzzyRuleConsequent *thenSteeringangleAng_1AndRunningspeedSpeed_0;
    FuzzyRule *fuzzyRule16;

    FuzzyRuleAntecedent *ifShiftS_0AndDistanceD_0;
    FuzzyRuleConsequent *thenSteeringangleAng_0AndRunningspeedSpeed_2;
    FuzzyRule *fuzzyRule17;

    FuzzyRuleAntecedent *ifShiftS_0AndDistanceD_1;
    FuzzyRuleConsequent *thenSteeringangleAng_0AndRunningspeedSpeed_1;
    FuzzyRule *fuzzyRule18;

    FuzzyRuleAntecedent *ifShiftS_0AndDistanceD_2;
    FuzzyRule *fuzzyRule19;

    FuzzyRuleAntecedent *ifShiftS_0AndDistanceD_3;
    FuzzyRuleConsequent *thenSteeringangleAng_0AndRunningspeedSpeed_0;
    FuzzyRule *fuzzyRule20;

    FuzzyRuleAntecedent *ifShiftS_0AndDistanceD_4;
    FuzzyRule *fuzzyRule21;

    // Fuzzy set
    FuzzySet *s_0 = new FuzzySet(9, 21, 21, 33);      //veri left
    FuzzySet *s_1 = new FuzzySet(24, 31.5, 31.5, 39); //medium left
    FuzzySet *s_2 = new FuzzySet(35, 39, 39, 43);     //zero
    FuzzySet *s_3 = new FuzzySet(39, 46.5, 46.5, 54); //medium right
    FuzzySet *s_4 = new FuzzySet(45, 57, 57, 69);     //very right

    FuzzySet *d_0 = new FuzzySet(0, 5, 5, 10);    //farthest
    FuzzySet *d_1 = new FuzzySet(5, 10, 10, 15);  //far
    FuzzySet *d_2 = new FuzzySet(10, 15, 15, 20); //middle
    FuzzySet *d_3 = new FuzzySet(15, 25, 25, 35); //near
    FuzzySet *d_4 = new FuzzySet(25, 42, 42, 59); //nearest

    FuzzySet *ang_0 = new FuzzySet(60, 70, 70, 80);     //leftmost
    FuzzySet *ang_1 = new FuzzySet(69, 79, 79, 89);     //left
    FuzzySet *ang_2 = new FuzzySet(88, 90, 90, 92);     //middle
    FuzzySet *ang_3 = new FuzzySet(91, 101, 101, 111);  //right
    FuzzySet *ang_4 = new FuzzySet(100, 110, 110, 120); // rightmost

    FuzzySet *speed_0 = new FuzzySet(50, 75, 75, 100);    //very slow
    FuzzySet *speed_1 = new FuzzySet(75, 110, 110, 145);  //slow
    FuzzySet *speed_2 = new FuzzySet(120, 150, 150, 180); //middle
    FuzzySet *speed_3 = new FuzzySet(155, 190, 190, 225); //fast
    FuzzySet *speed_4 = new FuzzySet(200, 225, 225, 250); //veryfast

    // Fuzzy input
    shift = new FuzzyInput(1);
    shift->addFuzzySet(s_0);
    shift->addFuzzySet(s_1);
    shift->addFuzzySet(s_2);
    shift->addFuzzySet(s_3);
    shift->addFuzzySet(s_4);
    fuzzy->addFuzzyInput(shift);

    distance = new FuzzyInput(2);
    distance->addFuzzySet(d_0);
    distance->addFuzzySet(d_1);
    distance->addFuzzySet(d_2);
    distance->addFuzzySet(d_3);
    distance->addFuzzySet(d_4);
    fuzzy->addFuzzyInput(distance);

    // Fuzzy output
    steeringangle = new FuzzyOutput(1);
    steeringangle->addFuzzySet(ang_0);
    steeringangle->addFuzzySet(ang_1);
    steeringangle->addFuzzySet(ang_2);
    steeringangle->addFuzzySet(ang_3);
    steeringangle->addFuzzySet(ang_4);
    fuzzy->addFuzzyOutput(steeringangle);

    runningspeed = new FuzzyOutput(2);
    runningspeed->addFuzzySet(speed_0);
    runningspeed->addFuzzySet(speed_1);
    runningspeed->addFuzzySet(speed_2);
    runningspeed->addFuzzySet(speed_3);
    fuzzy->addFuzzyOutput(runningspeed);

    // Fuzzy rule
    ifShiftS_4AndDistanceD_0 = new FuzzyRuleAntecedent();
    ifShiftS_4AndDistanceD_0->joinWithAND(s_4, d_0);
    thenSteeringangleAng_4AndRunningspeedSpeed_2 = new FuzzyRuleConsequent();
    thenSteeringangleAng_4AndRunningspeedSpeed_2->addOutput(ang_4);
    thenSteeringangleAng_4AndRunningspeedSpeed_2->addOutput(speed_2);
    fuzzyRule1 = new FuzzyRule(1, ifShiftS_4AndDistanceD_0, thenSteeringangleAng_4AndRunningspeedSpeed_2);
    fuzzy->addFuzzyRule(fuzzyRule1);

    ifShiftS_4AndDistanceD_1 = new FuzzyRuleAntecedent();
    ifShiftS_4AndDistanceD_1->joinWithAND(s_4, d_1);
    thenSteeringangleAng_4AndRunningspeedSpeed_1 = new FuzzyRuleConsequent();
    thenSteeringangleAng_4AndRunningspeedSpeed_1->addOutput(ang_4);
    thenSteeringangleAng_4AndRunningspeedSpeed_1->addOutput(speed_1);
    fuzzyRule2 = new FuzzyRule(2, ifShiftS_4AndDistanceD_1, thenSteeringangleAng_4AndRunningspeedSpeed_1);
    fuzzy->addFuzzyRule(fuzzyRule2);

    ifShiftS_4AndDistanceD_2 = new FuzzyRuleAntecedent();
    ifShiftS_4AndDistanceD_2->joinWithAND(s_4, d_2);
    // FuzzyRuleConsequent* thenSteeringangleAng_4AndRunningspeedSpeed_1 = new FuzzyRuleConsequent();
    // thenSteeringangleAng_4AndRunningspeedSpeed_1->addOutput(ang_4);
    // thenSteeringangleAng_4AndRunningspeedSpeed_1->addOutput(speed_1);
    fuzzyRule3 = new FuzzyRule(3, ifShiftS_4AndDistanceD_2, thenSteeringangleAng_4AndRunningspeedSpeed_1);
    fuzzy->addFuzzyRule(fuzzyRule3);

    ifShiftS_4AndDistanceD_3 = new FuzzyRuleAntecedent();
    ifShiftS_4AndDistanceD_3->joinWithAND(s_4, d_3);
    thenSteeringangleAng_4AndRunningspeedSpeed_0 = new FuzzyRuleConsequent();
    thenSteeringangleAng_4AndRunningspeedSpeed_0->addOutput(ang_4);
    thenSteeringangleAng_4AndRunningspeedSpeed_0->addOutput(speed_0);
    fuzzyRule4 = new FuzzyRule(4, ifShiftS_4AndDistanceD_3, thenSteeringangleAng_4AndRunningspeedSpeed_0);
    fuzzy->addFuzzyRule(fuzzyRule4);

    ifShiftS_4AndDistanceD_4 = new FuzzyRuleAntecedent();
    ifShiftS_4AndDistanceD_4->joinWithAND(s_4, d_4);
    // FuzzyRuleConsequent* thenSteeringangleAng_4AndRunningspeedSpeed_0 = new FuzzyRuleConsequent();
    // thenSteeringangleAng_4AndRunningspeedSpeed_0->addOutput(ang_4);
    // thenSteeringangleAng_4AndRunningspeedSpeed_0->addOutput(speed_0);
    fuzzyRule5 = new FuzzyRule(5, ifShiftS_4AndDistanceD_4, thenSteeringangleAng_4AndRunningspeedSpeed_0);
    fuzzy->addFuzzyRule(fuzzyRule5);

    ifShiftS_3AndDistanceD_0 = new FuzzyRuleAntecedent();
    ifShiftS_3AndDistanceD_0->joinWithAND(s_3, d_0);
    thenSteeringangleAng_3AndRunningspeedSpeed_3 = new FuzzyRuleConsequent();
    thenSteeringangleAng_3AndRunningspeedSpeed_3->addOutput(ang_3);
    thenSteeringangleAng_3AndRunningspeedSpeed_3->addOutput(speed_3);
    fuzzyRule6 = new FuzzyRule(6, ifShiftS_3AndDistanceD_0, thenSteeringangleAng_3AndRunningspeedSpeed_3);
    fuzzy->addFuzzyRule(fuzzyRule6);

    ifShiftS_3AndDistanceD_1 = new FuzzyRuleAntecedent();
    ifShiftS_3AndDistanceD_1->joinWithAND(s_3, d_1);
    thenSteeringangleAng_3AndRunningspeedSpeed_2 = new FuzzyRuleConsequent();
    thenSteeringangleAng_3AndRunningspeedSpeed_2->addOutput(ang_3);
    thenSteeringangleAng_3AndRunningspeedSpeed_2->addOutput(speed_2);
    fuzzyRule7 = new FuzzyRule(7, ifShiftS_3AndDistanceD_1, thenSteeringangleAng_3AndRunningspeedSpeed_2);
    fuzzy->addFuzzyRule(fuzzyRule7);

    ifShiftS_3AndDistanceD_2 = new FuzzyRuleAntecedent();
    ifShiftS_3AndDistanceD_2->joinWithAND(s_3, d_2);
    thenSteeringangleAng_3AndRunningspeedSpeed_1 = new FuzzyRuleConsequent();
    thenSteeringangleAng_3AndRunningspeedSpeed_1->addOutput(ang_3);
    thenSteeringangleAng_3AndRunningspeedSpeed_1->addOutput(speed_1);
    fuzzyRule8 = new FuzzyRule(8, ifShiftS_3AndDistanceD_2, thenSteeringangleAng_3AndRunningspeedSpeed_1);
    fuzzy->addFuzzyRule(fuzzyRule8);

    ifShiftS_3AndDistanceD_3 = new FuzzyRuleAntecedent();
    ifShiftS_3AndDistanceD_3->joinWithAND(s_3, d_3);
    // FuzzyRuleConsequent* thenSteeringangleAng_3AndRunningspeedSpeed_1 = new FuzzyRuleConsequent();
    // thenSteeringangleAng_3AndRunningspeedSpeed_1->addOutput(ang_3);
    // thenSteeringangleAng_3AndRunningspeedSpeed_1->addOutput(speed_1);
    fuzzyRule9 = new FuzzyRule(9, ifShiftS_3AndDistanceD_3, thenSteeringangleAng_3AndRunningspeedSpeed_1);
    fuzzy->addFuzzyRule(fuzzyRule9);

    ifShiftS_3AndDistanceD_4 = new FuzzyRuleAntecedent();
    ifShiftS_3AndDistanceD_4->joinWithAND(s_3, d_4);
    thenSteeringangleAng_3AndRunningspeedSpeed_0 = new FuzzyRuleConsequent();
    thenSteeringangleAng_3AndRunningspeedSpeed_0->addOutput(ang_3);
    thenSteeringangleAng_3AndRunningspeedSpeed_0->addOutput(speed_0);
    fuzzyRule10 = new FuzzyRule(10, ifShiftS_3AndDistanceD_4, thenSteeringangleAng_3AndRunningspeedSpeed_0);
    fuzzy->addFuzzyRule(fuzzyRule10);

    ifShiftS_2 = new FuzzyRuleAntecedent();
    ifShiftS_2->joinSingle(s_2);
    thenSteeringangleAng_2AndRunningspeedSpeed_4 = new FuzzyRuleConsequent();
    thenSteeringangleAng_2AndRunningspeedSpeed_4->addOutput(ang_2);
    thenSteeringangleAng_2AndRunningspeedSpeed_4->addOutput(speed_4);
    fuzzyRule11 = new FuzzyRule(11, ifShiftS_2, thenSteeringangleAng_2AndRunningspeedSpeed_4);
    fuzzy->addFuzzyRule(fuzzyRule11);

    ifShiftS_1AndDistanceD_0 = new FuzzyRuleAntecedent();
    ifShiftS_1AndDistanceD_0->joinWithAND(s_1, d_0);
    thenSteeringangleAng_1AndRunningspeedSpeed_3 = new FuzzyRuleConsequent();
    thenSteeringangleAng_1AndRunningspeedSpeed_3->addOutput(ang_1);
    thenSteeringangleAng_1AndRunningspeedSpeed_3->addOutput(speed_3);
    fuzzyRule12 = new FuzzyRule(12, ifShiftS_1AndDistanceD_0, thenSteeringangleAng_1AndRunningspeedSpeed_3);
    fuzzy->addFuzzyRule(fuzzyRule12);

    ifShiftS_1AndDistanceD_1 = new FuzzyRuleAntecedent();
    ifShiftS_1AndDistanceD_1->joinWithAND(s_1, d_1);
    thenSteeringangleAng_1AndRunningspeedSpeed_2 = new FuzzyRuleConsequent();
    thenSteeringangleAng_1AndRunningspeedSpeed_2->addOutput(ang_1);
    thenSteeringangleAng_1AndRunningspeedSpeed_2->addOutput(speed_2);
    fuzzyRule13 = new FuzzyRule(13, ifShiftS_1AndDistanceD_1, thenSteeringangleAng_1AndRunningspeedSpeed_2);
    fuzzy->addFuzzyRule(fuzzyRule13);

    ifShiftS_1AndDistanceD_2 = new FuzzyRuleAntecedent();
    ifShiftS_1AndDistanceD_2->joinWithAND(s_1, d_2);
    thenSteeringangleAng_1AndRunningspeedSpeed_1 = new FuzzyRuleConsequent();
    thenSteeringangleAng_1AndRunningspeedSpeed_1->addOutput(ang_1);
    thenSteeringangleAng_1AndRunningspeedSpeed_1->addOutput(speed_1);
    fuzzyRule14 = new FuzzyRule(14, ifShiftS_1AndDistanceD_2, thenSteeringangleAng_1AndRunningspeedSpeed_1);
    fuzzy->addFuzzyRule(fuzzyRule14);

    ifShiftS_1AndDistanceD_3 = new FuzzyRuleAntecedent();
    ifShiftS_1AndDistanceD_3->joinWithAND(s_1, d_3);
    // FuzzyRuleConsequent* thenSteeringangleAng_1AndRunningspeedSpeed_1 = new FuzzyRuleConsequent();
    // thenSteeringangleAng_1AndRunningspeedSpeed_1->addOutput(ang_1);
    // thenSteeringangleAng_1AndRunningspeedSpeed_1->addOutput(speed_1);
    fuzzyRule15 = new FuzzyRule(15, ifShiftS_1AndDistanceD_3, thenSteeringangleAng_1AndRunningspeedSpeed_1);
    fuzzy->addFuzzyRule(fuzzyRule15);

    ifShiftS_1AndDistanceD_4 = new FuzzyRuleAntecedent();
    ifShiftS_1AndDistanceD_4->joinWithAND(s_1, d_4);
    thenSteeringangleAng_1AndRunningspeedSpeed_0 = new FuzzyRuleConsequent();
    thenSteeringangleAng_1AndRunningspeedSpeed_0->addOutput(ang_1);
    thenSteeringangleAng_1AndRunningspeedSpeed_0->addOutput(speed_0);
    fuzzyRule16 = new FuzzyRule(16, ifShiftS_1AndDistanceD_4, thenSteeringangleAng_1AndRunningspeedSpeed_0);
    fuzzy->addFuzzyRule(fuzzyRule16);

    ifShiftS_0AndDistanceD_0 = new FuzzyRuleAntecedent();
    ifShiftS_0AndDistanceD_0->joinWithAND(s_0, d_0);
    thenSteeringangleAng_0AndRunningspeedSpeed_2 = new FuzzyRuleConsequent();
    thenSteeringangleAng_0AndRunningspeedSpeed_2->addOutput(ang_0);
    thenSteeringangleAng_0AndRunningspeedSpeed_2->addOutput(speed_2);
    fuzzyRule17 = new FuzzyRule(17, ifShiftS_0AndDistanceD_0, thenSteeringangleAng_0AndRunningspeedSpeed_2);
    fuzzy->addFuzzyRule(fuzzyRule17);

    ifShiftS_0AndDistanceD_1 = new FuzzyRuleAntecedent();
    ifShiftS_0AndDistanceD_1->joinWithAND(s_0, d_1);
    thenSteeringangleAng_0AndRunningspeedSpeed_1 = new FuzzyRuleConsequent();
    thenSteeringangleAng_0AndRunningspeedSpeed_1->addOutput(ang_0);
    thenSteeringangleAng_0AndRunningspeedSpeed_1->addOutput(speed_1);
    fuzzyRule18 = new FuzzyRule(18, ifShiftS_0AndDistanceD_1, thenSteeringangleAng_0AndRunningspeedSpeed_1);
    fuzzy->addFuzzyRule(fuzzyRule18);

    ifShiftS_0AndDistanceD_2 = new FuzzyRuleAntecedent();
    ifShiftS_0AndDistanceD_2->joinWithAND(s_0, d_2);
    // FuzzyRuleConsequent* thenSteeringangleAng_0AndRunningspeedSpeed_1 = new FuzzyRuleConsequent();
    // thenSteeringangleAng_0AndRunningspeedSpeed_1->addOutput(ang_0);
    // thenSteeringangleAng_0AndRunningspeedSpeed_1->addOutput(speed_1);
    fuzzyRule19 = new FuzzyRule(19, ifShiftS_0AndDistanceD_2, thenSteeringangleAng_0AndRunningspeedSpeed_1);
    fuzzy->addFuzzyRule(fuzzyRule19);

    ifShiftS_0AndDistanceD_3 = new FuzzyRuleAntecedent();
    ifShiftS_0AndDistanceD_3->joinWithAND(s_0, d_3);
    thenSteeringangleAng_0AndRunningspeedSpeed_0 = new FuzzyRuleConsequent();
    thenSteeringangleAng_0AndRunningspeedSpeed_0->addOutput(ang_0);
    thenSteeringangleAng_0AndRunningspeedSpeed_0->addOutput(speed_0);
    fuzzyRule20 = new FuzzyRule(20, ifShiftS_0AndDistanceD_3, thenSteeringangleAng_0AndRunningspeedSpeed_0);
    fuzzy->addFuzzyRule(fuzzyRule20);

    ifShiftS_0AndDistanceD_4 = new FuzzyRuleAntecedent();
    ifShiftS_0AndDistanceD_4->joinWithAND(s_0, d_4);
    // FuzzyRuleConsequent* thenSteeringangleAng_0AndRunningspeedSpeed_0 = new FuzzyRuleConsequent();
    // thenSteeringangleAng_0AndRunningspeedSpeed_0->addOutput(ang_0);
    // thenSteeringangleAng_0AndRunningspeedSpeed_0->addOutput(speed_0);
    fuzzyRule21 = new FuzzyRule(21, ifShiftS_0AndDistanceD_4, thenSteeringangleAng_0AndRunningspeedSpeed_0);
    fuzzy->addFuzzyRule(fuzzyRule21);

    float target_x = 21.88; //    key in the digital value
    float target_y = 32;

    // target_x and target_y are the inputs
    fuzzy->setInput(1, target_x); // shift
    fuzzy->setInput(2, target_y); // deistance

    fuzzy->fuzzify(); // Executing the fuzzification

    float output1 = fuzzy->defuzzify(1); // steering angle
    float output2 = fuzzy->defuzzify(2); // running speed

    ASSERT_NEAR(70.0, output1, 0.01);
    ASSERT_NEAR(75.0, output2, 0.01);
}
*/