// Copyright (c) 2021 Ekorau LLC

import .antecedent show Antecedent
import .consequent show Consequent

class FuzzyRule:

    index/int
    fired := false
    antecedent_/Antecedent 
    consequent_/Consequent 

    constructor .index .antecedent_ .consequent_:

    evaluate -> bool:
        if (antecedent_!=null) and (consequent_!=null):
            antecedent_power := antecedent_.evaluate
            fired = antecedent_power > 0.0? true : false
            consequent_.evaluate antecedent_power
        return fired


