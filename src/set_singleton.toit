import .fuzzy_set show *
import .geometry show Point2f
import math show *

class SingletonSet extends FuzzySet:

    constructor a b c d name:
        super.with_points a b c d name

    stype: return "sing"

    truncated -> List: //Answer the point geometry, truncated to the current pertinence
        return [(Point2f a_ 0.0), (Point2f b_ pertinence_)]