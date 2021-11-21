import .fuzzy_set show *

class SingletonSet extends FuzzySet:

    constructor a b c d name:
        super.with_points a b c d name

    stype: return "sing"
