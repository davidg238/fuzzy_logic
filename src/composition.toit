// Copyright (c) 2021 Ekorau LLC

import .fuzzy_point show FuzzyPoint

class Composition:

    points_/List := []

    add_point point/FuzzyPoint -> none:
        points_.add point

    add_point point/float pertinence/float -> none:
        points_.add (FuzzyPoint point pertinence)


    any_point point/float pertinence/float:     /// was checkPoint, more Toit-like?
        return (points_.any: (it.point == point) and (it.pert == pertinence))

    build -> none:                              
        throw "-method unimplemented-"
    calculate -> float:                         
        throw "-method unimplemented-"

    check_point point/float pertinence/float:   /// deprecated, here only for eFLL folks
        return any_point point pertinence

    count_Points -> int:                        /// deprecated, here only for eFLL folks
        return size

    empty -> none:      //todo : is this just to enable compositions to be re-used in the test suite?
        points_ = []

    size -> int:                                /// was countPoints, more Toit-like?
        return points_.size



/*    
// Method to iterate over the pointsArray, detect possible intersections and sent these points for "correction"
bool FuzzyComposition::build()
{
    // auxiliary variable to handle the operation, instantiate with the first element from array
    pointsArray *aux = this->points;
    // while not in the end of the array, iterate
    while (aux != NULL)
    {
        // another auxiliary variable to handle the operation
        pointsArray *temp = aux;
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
    }
    return true;
}

// Calculate the center of the area of this FuzzyComposition
    calculate -> float:
{
    // auxiliary variable to handle the operation, instantiate with the first element from array
    pointsArray *aux = this->points;
    float numerator = 0.0;
    float denominator = 0.0;
    // while not in the end of the array, iterate
    while (aux != NULL && aux->next != NULL)
    {
        float area = 0.0;
        float middle = 0.0;
        // if it is a singleton
        if (aux->pertinence != aux->next->pertinence && aux->point == aux->next->point)
        {
            // enter in all points of singleton, but calculate only once
            if (aux->pertinence > 0.0)
            {
                area = aux->pertinence;
                middle = aux->point;
            }
        }
        // if a triangle (Not properly a membership function)
        else if (aux->pertinence == 0.0 || aux->next->pertinence == 0.0)
        {
            float pertinence;
            if (aux->pertinence > 0.0)
            {
                pertinence = aux->pertinence;
            }
            else
            {
                pertinence = aux->next->pertinence;
            }
            area = ((aux->next->point - aux->point) * pertinence) / 2.0;
            if (aux->pertinence < aux->next->pertinence)
            {
                middle = ((aux->next->point - aux->point) / 1.5) + aux->point;
            }
            else
            {
                middle = ((aux->next->point - aux->point) / 3.0) + aux->point;
            }
        }
        // else if a square (Not properly a membership function)
        else if ((aux->pertinence > 0.0 && aux->next->pertinence > 0.0) && aux->pertinence == aux->next->pertinence)
        {
            area = (aux->next->point - aux->point) * aux->pertinence;
            middle = ((aux->next->point - aux->point) / 2.0) + aux->point;
        }
        // else if a trapeze (Not properly a membership function)
        else if ((aux->pertinence > 0.0 && aux->next->pertinence > 0.0) && aux->pertinence != aux->next->pertinence)
        {
            area = ((aux->pertinence + aux->next->pertinence) / 2.0) * (aux->next->point - aux->point);
            middle = ((aux->next->point - aux->point) / 2.0) + aux->point;
        }
        numerator += middle * area;
        denominator += area;
        aux = aux->next;
    }
    // avoiding zero division
    if (denominator == 0.0)
    {
        return 0.0;
    }
    else
    {
        return numerator / denominator;
    }
}

// Method to search intersection between two segments, if found, create a new pointsArray (in found intersection) and remove not necessary ones
bool FuzzyComposition::rebuild(pointsArray *aSegmentBegin, pointsArray *aSegmentEnd, pointsArray *bSegmentBegin, pointsArray *bSegmentEnd)
{
    // create a reference for each point
    float x1 = aSegmentBegin->point;
    float y1 = aSegmentBegin->pertinence;
    float x2 = aSegmentEnd->point;
    float y2 = aSegmentEnd->pertinence;
    float x3 = bSegmentBegin->point;
    float y3 = bSegmentBegin->pertinence;
    float x4 = bSegmentEnd->point;
    float y4 = bSegmentEnd->pertinence;
    // calculate the denominator and numerator
    float denom = (y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1);
    float numera = (x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3);
    float numerb = (x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3);
    // if negative, convert to positive
    if (denom < 0.0)
    {
        denom *= -1.0;
    }
    // If the denominator is zero or close to it, it means that the lines are parallels, so return false for intersection
    if (denom < EPSILON_VALUE)
    {
        // return false for intersection
        return false;
    }
    // if negative, convert to positive
    if (numera < 0.0)
    {
        numera *= -1.0;
    }
    // if negative, convert to positive
    if (numerb < 0.0)
    {
        numerb *= -1.0;
    }
    // verify if has intersection between the segments
    float mua = numera / denom;
    float mub = numerb / denom;
    if (mua <= 0.0 || mua >= 1.0 || mub <= 0.0 || mub >= 1.0)
    {
        // return false for intersection
        return false;
    }
    else
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
    }
}
*/