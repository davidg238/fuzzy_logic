// Copyright (c) 2021 Ekorau LLC

import .fuzzy_point show FuzzyPoint

/*
A composition looks more like a traditional function plot of values than the sets.
The original eFLL used duplicate points to indicate the type of set.
*/

class Composition:

    points/List := []

    seed set/FuzzySet -> none:
        set.seed this

    add_point point/FuzzyPoint -> none:
        print "... add $point"
        points.add point

    add_point point/float pertinence/float -> none:
        add_point (FuzzyPoint point pertinence)

    build -> none:

    any_point point/float pertinence/float:     /// was checkPoint, to resemble set operator
        return (points.any: (it.point == point) and (it.pert == pertinence))

    empty -> none:      //todo : is this just to enable compositions to be re-used in the test suite?
        points = []

    size -> int:                                /// was countPoints, more Toit-like
        return points.size

    segments -> int:
        return points.size - 1

    segment index -> List:
        

    stringify -> string:
        txt := "$(points.size): "
        points.do:
            txt = txt + "$it , "
        return txt
/*
// Method to iterate over the pointsArray, detect possible intersections and sent these points for "correction"
    build -> none:
        temp := points[0]
        for i:=0; i < points.size; i++:
             // another auxiliary variable to handle the operation
            temp = aux;
            // while not in the beginning of the array, iterate
            while (temp->previous != NULL)
            {
                // if the previous point is greater then the current
                if (aux->point < temp->point)
                {
                    // if yes, break an use this point
                    break;
                }
                temp = temp->previous;
            }
            // iterate over the previous pointsArray
            while (temp->previous != NULL)
            {
                // if previous of previous point is not NULL, and some intersection was fixed by rebuild
                if (this->rebuild(aux, aux->next, temp, temp->previous) == true)
                {
                    // move the first auxiliary to beginning of the array for a new validation, and breaks
                    aux = this->points;
                    break;
                }
                temp = temp->previous;
            }
            aux = aux->next;
  */      
// Calculate the center of the area of this FuzzyComposition
    calculate -> float:
        numerator := 0.0
        denominator := 0.0
        area := 0.0
        middle := 0.0
        a_pert := 0.0

        for i:=0; i < points.size - 1; i++:
            area = 0.0;
            middle = 0.0;
            // if it is a singleton
            if (points[i].pert != points[i + 1].pert) and (points[i].point == points[i + 1].point):
                // enter in all points of singleton, but calculate only once
                if (points[i].pert > 0.0):
                    area = points[i].pert
                    middle = points[i].point
            // if a triangle (Not properly a membership function)
            else if (points[i].pert == 0.0) or (points[i+1].pert == 0.0):
                if (points[i].pert > 0.0):
                    a_pert = points[i].pert
                else:
                    a_pert = points[i+1].pert
                area = ((points[i+1].point - points[i].point) * a_pert) / 2.0;
                if (points[i].pert < points[i+1].pert):
                    middle = ((points[i+1].point - points[i].point) / 1.5) + points[i].point
                else:
                    middle = ((points[i+1].point - points[i].point) / 3.0) + points[i].point
            // else if a square (Not properly a membership function)
            else if (((points[i].pert > 0.0) and (points[i+1].pert > 0.0)) and (points[i].pert == points[i+1].pert)):
                area = (points[i+1].point - points[i].point) * points[i].pert
                middle = ((points[i+1].point - points[i].point) / 2.0) + points[i].point
            // else if a trapeze (Not properly a membership function)
            else if (((points[i].pert > 0.0) and (points[i+1].pert > 0.0)) and (points[i].pert != points[i+1].pert)):
                area = ((points[i].pert + points[i+1].pert) / 2.0) * (points[i+1].point - points[i].point)
                middle = ((points[i+1].point - points[i].point) / 2.0) + points[i].point
            numerator += middle * area;
            denominator += area;
        return (denominator == 0.0)? 0.0 : (numerator / denominator)
        
/*
// Method to search intersection between two segments, if found, create a new pointsArray (in found intersection) and remove not necessary ones
    rebuild aSegmentBegin/FuzzyPoint aSegmentEnd/FuzzyPoint bSegmentBegin/FuzzyPoint bSegmentEnd/FuzzyPoint -> bool:
        // create a reference for each point
        x1 := aSegmentBegin.point
        y1 := aSegmentBegin.pert
        x2 := aSegmentEnd.point
        y2 := aSegmentEnd.pert
        x3 := bSegmentBegin.point
        y3 := bSegmentBegin.pert
        x4 := bSegmentEnd.point
        y4 := bSegmentEnd.pert
        // calculate the denominator and numerator
        denom := (y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1);
        numera := (x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3);
        numerb := (x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3);
        // if negative, convert to positive
        if (denom < 0.0): denom *= -1.0
        // If the denominator is zero or close to it, it means that the lines are parallels, so return false for intersection
        if (denom < 0.001): return false
        // if negative, convert to positive
        if (numera < 0.0): numera *= -1.0
        // if negative, convert to positive
        if (numerb < 0.0): numerb *= -1.0

        // verify if has intersection between the segments
        mua := numera / denom;
        mub := numerb / denom;
        if ((mua <= 0.0) or (mua >= 1.0) or (mub <= 0.0) or (mub >= 1.0)): 
            return false // no intersection
        else:
        {
            // we found an intersection
            // auxiliary variable to handle the operation
            pointsArray *aux;
            // allocating in memory
            if ((aux = (pointsArray *)malloc(sizeof(pointsArray))) == NULL)
            {
                // return false if in out of memory
                return false;
            }
            // calculate the point (y) and its pertinence (y) for the new element (pointsArray)
            aux->previous = bSegmentEnd;
            aux->point = x1 + mua * (x2 - x1);
            aux->pertinence = y1 + mua * (y2 - y1);
            aux->next = aSegmentEnd;
            // changing pointsArray to accomplish with new state
            aSegmentBegin->next = aux;
            aSegmentEnd->previous = aux;
            bSegmentBegin->previous = aux;
            bSegmentEnd->next = aux;
            // initiate a proccess of remotion of not needed pointsArray
            // some variables to help in this proccess, the start pointsArray
            pointsArray *temp = bSegmentBegin;
            // do, while
            do
            {
                // hold next
                pointsArray *excl = temp->next;
                // remove it from array
                this->rmvPoint(temp);
                // set new current
                temp = excl;
                // check if it is the stop pointsArray
                if (temp != NULL && temp->point == aux->point && temp->pertinence == aux->pertinence)
                {
                    // if true, stop the deletions
                    break;
                }
            } while (temp != NULL);
            return true;
        */
// --------------------------------------------------------------------------------------
    check_point point/float pertinence/float:   /// deprecated, here only for eFLL folks
        return any_point point pertinence

    count_Points -> int:                        /// deprecated, here only for eFLL folks
        return size