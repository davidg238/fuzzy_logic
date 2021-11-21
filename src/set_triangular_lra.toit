import .fuzzy_set show *

class LraTriangularSet extends FuzzySet:

    constructor a b c d name:
        super.with_points a b c d name

    stype: return "tri.lra"

    copy_points_to_ composition/Composition -> none:
        composition.add_point (FuzzyPoint c_ pertinence_)
        composition.add_point (FuzzyPoint d_ 0.0 )

    union composition/Composition -> none: