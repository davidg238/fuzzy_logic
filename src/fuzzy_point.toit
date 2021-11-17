// Copyright (c) 2021 Ekorau LLC

class FuzzyPoint:

    point/float 
    pert/float

    constructor .point .pert:

class NoPoint extends FuzzyPoint:

    constructor:
        super float.NAN float.NAN
