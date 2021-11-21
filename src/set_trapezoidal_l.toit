import .fuzzy_set show *

class LTrapezoidalSet extends FuzzySet:

    constructor a b c d name:
        super.with_points a b c d name

    stype: return "trap.l"

    copy_points_to_ composition/Composition -> none:
        composition.add_point (FuzzyPoint a_ pertinence_)
        composition.add_point (FuzzyPoint c_ pertinence_)
        composition.add_point (FuzzyPoint d_ 0.0 )