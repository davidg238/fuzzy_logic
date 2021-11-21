// Copyright (c) 2021 Ekorau LLC

import .antecedent show Antecedent
import .consequent show Consequent

class FuzzyRule:

    index/int
    fired := false
    antecedent_/Antecedent 
    consequent_/Consequent 
    name/string

    constructor .index .antecedent_ .consequent_ .name="":

    evaluate -> bool:
        if (antecedent_!=null) and (consequent_!=null):
            antecedent_power := antecedent_.evaluate
            fired = antecedent_power > 0.0? true : false
            consequent_.evaluate antecedent_power
        return fired

    stringify -> string: return "    $index: if $antecedent_ then $consequent_"

