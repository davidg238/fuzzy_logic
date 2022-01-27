# TeFLL  (Toit embedded Fuzzy Logic Library)

A transcode of the [Embedded Fuzzy Logi Library](https://github.com/zerokol/eFLL) to Toit.  
Currently -not- ready for use in production, as there are known issues and several of the test cases fail.  
The goal is to fully develop the library.    
It is currently published as a demonstration of porting a significant codebase from C++ to Toit and some indication of application performance.  

If curious, look at `test/test_fuzzy_lib.toit` for test cases; `test/test_lecture_1.toit`, `test/test_lecture_1.toit` and `test/test_casco.toit` for construction and usage of the models.

ToDos
- fix the float comparisons, in ~~test~~ and geometry !
- calculation of the concave hull for the composition points (is it expensive?)
- check handling of colinear points, see floats
- resolve the discrepancies in the test suite, between the .cpp and .toit implementations
- further leverage OO patterns, rather than simple transcoding
- write new test cases, specifically for set combinations to test composition simplification
- ~~write a test suite for the test utility `test_util.toit`~~ 