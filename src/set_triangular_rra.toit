import .fuzzy_set show *

class RraTriangularSet extends FuzzySet:

    constructor a b c d name:
        super.with_points a b c d name

    stype: return "tri.rra"

    copy_points_to_ composition/Composition -> none:
        composition.add_point (FuzzyPoint a_ 0.0)
        composition.add_point (FuzzyPoint b_ pertinence_ )

    union composition/Composition -> none:

