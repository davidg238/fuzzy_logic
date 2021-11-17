// Copyright (c) 2021 Ekorau LLC

class FuzzySet:

    a_/float 
    b_/float
    c_/float
    d_/float
    pertinence_/float := 0.0

    constructor .a_ .b_ .c_ .d_:

    calculate_pertinence crispVal/float -> bool:

        // check if this FuzzySet represents "everything small is true"
        if (crispVal < a_):
            pertinence_ = (a_==b_) and (b_!=c_) and (c_!=d_)? 1.0 : 0.0
        // check if the crispValue is between A and B
        else if (crispVal >= a_) and (crispVal < b_):
            slope := 1.0 / (b_-a_)
            pertinence_ = slope * (crispVal - b_) + 1.0
        // check if the pertinence is between B and C
        else if (crispVal >= b_) and (crispVal <= c_):
            pertinence_ = 1.0;
        // check if the pertinence is between C and D
        else if (crispVal > c_) and (crispVal <= d_):
            slope := 1.0 / (c_ - d_)
            pertinence_ = slope * (crispVal - c_) + 1.0
        // check the crispValue is bigger then D
        else if (crispVal > d_):
            // check if this FuzzySet represents "everithing bigger is true"
            pertinence_ = (c_ == d_) and (c_ != b_) and (b_ != a_)? 1.0 : 0.0

        return true

    a -> float: return a_
    b -> float: return b_
    c -> float: return c_
    d -> float: return d_


    pertinence -> float:
        return pertinence_
    
    pertinence val/float -> none:
        if (pertinence_ < val): pertinence_ = val

    reset -> none:
        pertinence_ = 0.0