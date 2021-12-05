// Copyright (c) 2021 Ekorau LLC
import math
import .fuzzy_set show FuzzySet

// possible logic operators
OP_AND ::= 1
OP_OR  ::= 2
// possible join associations modes
MODE_FS      ::= 1
MODE_FS_FS   ::= 2
MODE_FS_FRA  ::= 3
MODE_FRA_FRA ::= 4

class Antecedent:

  op_ := 0
  mode_ := 0
  fuzzy_set_1_ := null
  fuzzy_set_2_ := null
  antecedent_1_ := null
  antecedent_2_ := null

  constructor.join_set fuzzy_set/FuzzySet:
        mode_ = MODE_FS
        fuzzy_set_1_ = fuzzy_set

  constructor.join_sets_AND fuzzy_set_1/FuzzySet fuzzy_set_2/FuzzySet:
        op_ = OP_AND
        mode_ = MODE_FS_FS
        fuzzy_set_1_ = fuzzy_set_1
        fuzzy_set_2_ = fuzzy_set_2

  constructor.join_sets_OR fuzzy_set_1/FuzzySet fuzzy_set_2/FuzzySet:
        op_ = OP_OR
        mode_ = MODE_FS_FS
        fuzzy_set_1_ = fuzzy_set_1
        fuzzy_set_2_ = fuzzy_set_2

  constructor.join_set_ante_AND fuzzy_set/FuzzySet antecedent/Antecedent:
        op_ = OP_AND
        mode_ = MODE_FS_FRA
        fuzzy_set_1_ = fuzzy_set
        antecedent_1_ = antecedent

  constructor.join_ante_set_AND antecedent/Antecedent fuzzy_set/FuzzySet:
        op_ = OP_AND
        mode_ = MODE_FS_FRA
        fuzzy_set_1_ = fuzzy_set
        antecedent_1_ = antecedent

  constructor.join_set_ante_OR fuzzy_set/FuzzySet antecedent/Antecedent:
        op_ = OP_OR
        mode_ = MODE_FS_FRA
        fuzzy_set_1_ = fuzzy_set
        antecedent_1_ = antecedent

  constructor.join_ante_set_OR antecedent/Antecedent fuzzy_set/FuzzySet:
        op_ = OP_OR
        mode_ = MODE_FS_FRA
        fuzzy_set_1_ = fuzzy_set
        antecedent_1_ = antecedent

  constructor.join_ante_ante_AND antecedent_1/Antecedent antecedent_2/Antecedent:
        op_ = OP_AND;
        mode_ = MODE_FRA_FRA;
        antecedent_1_ = antecedent_1
        antecedent_2_ = antecedent_2

  constructor.join_ante_ante_OR antecedent_1/Antecedent  antecedent_2/Antecedent:
        op_ = OP_OR;
        mode_ = MODE_FRA_FRA;
        antecedent_1_ = antecedent_1
        antecedent_2_ = antecedent_2

  evaluate -> float:
    if mode_==MODE_FS:          // a single FuzzySet join, just return its pertinence
        return fuzzy_set_1_.pertinence
    else if mode_==MODE_FS_FS:  // a join of two FuzzySet, switch by the operator
        if op_== OP_AND:            // the operator is AND, check if both has pertinence bigger then 0.0
            if (fuzzy_set_1_.pertinence > 0.0) and (fuzzy_set_2_.pertinence > 0.0):
                return min fuzzy_set_1_.pertinence fuzzy_set_2_.pertinence
            else:
                return 0.0
        else if op_== OP_OR:        // the operator is OR, check if one has pertinence bigger then 0.0
            if (fuzzy_set_1_.pertinence > 0.0) or (fuzzy_set_2_.pertinence > 0.0):
                // in this case, return the one pertinence is bigger
                return max fuzzy_set_1_.pertinence fuzzy_set_2_.pertinence
            else:
                return 0.0
        else:
            return 0.0
    else if mode_== MODE_FS_FRA: // if a join of one FuzzySet and one FuzzyRuleAntecedent, switch by the operator
        val1 := antecedent_1_.evaluate
        if op_== OP_AND:            // the operator is AND, check if both has pertinence bigger then 0.0
            if (fuzzy_set_1_.pertinence > 0.0) and (val1 > 0.0):  // return the small pertinence between two FuzzySet
                val2 := fuzzy_set_1_.pertinence
                return min val1 val2
            else:
                return 0.0
        else if op_== OP_OR:        // the operator is OR, check if one has pertinence bigger then 0.0
            if (fuzzy_set_1_.pertinence > 0.0) or (val1 > 0.0):  // return the one pertinence is bigger
                val2 := fuzzy_set_1_.pertinence
                return (max val2 val1)
            else:
                return 0.0
        else:
            return 0.0
    else if mode_ == MODE_FRA_FRA: // a join of two FuzzyRuleAntecedent, switch by the operator
        if op_ == OP_AND:               // the operator is AND, check if both has pertinence bigger then 0.0
            val1 := antecedent_1_.evaluate
            val2 := antecedent_2_.evaluate
            if (val1 > 0.0) and (val2 > 0.0): // return the smallest pertinence of two FuzzySet
                return min val1 val2
            else:
                return 0.0
        else if op_ == OP_OR:           // the operator is OR, check if one has pertinence bigger then 0.0
            val1 := antecedent_1_.evaluate
            val2 := antecedent_2_.evaluate
            if (val1 > 0.0) or (val2 > 0.0):  // return the bigger pertinence
                return max val1 val2
            else:
                return 0.0
        else:
            return 0.0
    else:
        return 0.0

  stringify -> string:

    if mode_==MODE_FS:
        return fuzzy_set_1_.name
    else if mode_==MODE_FS_FS:
        if op_== OP_AND:      
            return "($fuzzy_set_1_.name and $fuzzy_set_2_.name)"
        else if op_== OP_OR:  
            return "($fuzzy_set_1_.name or $fuzzy_set_2_.name)"
    else if mode_== MODE_FS_FRA:
        if op_== OP_AND:        
            return "($fuzzy_set_1_.name and $antecedent_1_)"
        else if op_== OP_OR:    
            return "($fuzzy_set_1_.name or $antecedent_1_)"
    else if mode_ == MODE_FRA_FRA:
        if op_ == OP_AND:         
            return "($antecedent_1_ and $antecedent_2_)"
        else if op_ == OP_OR:     
            return "($antecedent_1_ or $antecedent_2_)"
    return "<error>"