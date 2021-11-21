import .fuzzy_set show *

class TrapezoidalSet extends FuzzySet:

    constructor a b c d name:
        super.with_points a b c d name

    stype: return "trap"

    copy_points_to_ composition/Composition -> none:
        composition.add_point (FuzzyPoint a_ 0.0)
        composition.add_point (FuzzyPoint b_ pertinence_)
        composition.add_point (FuzzyPoint c_ pertinence_)
        composition.add_point (FuzzyPoint d_ 0.0 )

    segments -> List:
        
    union composition/Composition -> none:
        comp_seg := composition.segments
        for seti:=0; seti<3; seti++: 
        c := composition.points[0]
