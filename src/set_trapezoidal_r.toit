import .fuzzy_set show *
import .geometry show intersection Point2f

class RTrapezoidalSet extends FuzzySet:

    constructor a b c d name:
        super.with_points a b c d name

    stype: return "trap.r"

    truncated -> List: //Answer the point geometry, truncated to the current pertinence
        return pertinence_== 1.0?
            [ Point2f a_ 0.0, 
              Point2f b_ 1.0,
              Point2f 100.0 1.0  // geometries considered x range of 0-100 ? //todo
            ] :
            [ Point2f a_ 0.0, 
              intersection (Point2f a_ 0.0) (Point2f b_ 1.0) truncator_a truncator_b,
              Point2f 100.0 pertinence
            ]     