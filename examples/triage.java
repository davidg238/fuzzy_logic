package com.project.triage;

import net.sourceforge.jFuzzyLogic.FIS;

/**
 * Test parsing an FCL file
 * @author pcingola@users.sourceforge.net
 */
public class FuzzyChestPain {
    double waitingTime;
    public FuzzyChestPain(boolean aw, int oxy, 
            int sweat, int col, int hr, int bp, int cl,
            int pain, boolean cardiac_pain, 
            boolean shortness_of_breath, 
            boolean irregular_rhythm, boolean pleuritic_pain,
            int history_of_cardiac, int onset_of_symptoms,
            int onset, int vomiting_no_blood) {
        // Load from 'FCL' file
        String fileName = "chest_pain.fcl";
        FIS fis = FIS.load(fileName,true);
        // Error while loading?
        if( fis == null ) { 
            System.err.println("Can't load file: '" 
                                   + fileName + "'");
            return;
        }

        // Show 
        //fis.chart();

        // Set inputs
        fis.setVariable("airway", convertBoolean(!aw));
        fis.setVariable("oxygenation", oxy);
        fis.setVariable("sweating", sweat);
        fis.setVariable("color", col);
        fis.setVariable("heart_rate", hr);
        fis.setVariable("blood_pressure", bp);
        fis.setVariable("conscious_level", cl);
        fis.setVariable("pain", pain);
        fis.setVariable("cardiac_pain", convertBoolean(cardiac_pain));
        fis.setVariable("shortness_of_breath", convertBoolean(shortness_of_breath));
        fis.setVariable("irregular_rhythm", convertBoolean(irregular_rhythm));
        fis.setVariable("pleuritic_pain", convertBoolean(pleuritic_pain));
        fis.setVariable("history_of_cardiac", history_of_cardiac);
        fis.setVariable("onset_of_symptoms", onset_of_symptoms);
        fis.setVariable("onset", onset);
        fis.setVariable("vomiting_no_blood", vomiting_no_blood);

       // Evaluate
        fis.evaluate();

        // Show output variable's chart 
        fis.getVariable("situation").chartDefuzzifier(true);
        //System.out.println("Patient should wait no longer than " + fis.getVariable("situation").getLatestDefuzzifiedValue());
        // Print ruleSet
        //System.out.println(fis);
        setWaitingTime(fis.getVariable("situation").getLatestDefuzzifiedValue());
    }

    private void setWaitingTime(double time) {
        waitingTime = time;
    }

    public double getWaitingTime() {
        return waitingTime;
    }



    //Convert boolean variables into 1s and 0s
    public int convertBoolean(boolean myVar) {
        if (myVar == true) {
            return 1;
        }
        else {
            return 0;
        }
    }
}