// Copyright (c) 2021 Ekorau LLC

import .fuzzy_set show *
import .geometry show intersection Point2f

class RraTriangularSet extends FuzzySet:

    constructor a b c d name:
        super.with_points a b c d name

    stype: return "tri.rra"

    truncated -> List: //Answer the point geometry, truncated to the current pertinence
        return pertinence_== 1.0?
            [ Point2f a_ 0.0, 
              Point2f d_ 1.0,
              Point2f d_ 0.0
            ] :
            [ Point2f a_ 0.0, 
              intersection (Point2f a_ 0.0) (Point2f d_ 1.0) truncator_a truncator_b,
              intersection (Point2f d_ 1.0) (Point2f d_ 0.0) truncator_a truncator_b,
              Point2f d_ 0.0
            ]

