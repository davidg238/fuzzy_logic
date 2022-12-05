# eFLL  (embedded Fuzzy Logic Library)

An adaption of the [Embedded Fuzzy Logic Library](https://github.com/zerokol/eFLL) to Toit.  

If curious, look at `test/test_fuzzy_lib.toit` for test cases; `test/test_lecture_1.toit`, `test/test_lecture_1.toit` and `test/test_casco.toit` for construction and usage of the models.

ToDos
- resolve the result discrepancies (<1%) in the test suite, between the .cpp and .toit implementations



## Setup

In project root:  
```
david@MSI-7D43:~/workspaceToit/fuzzy_logic$ jag pkg init
david@MSI-7D43:~/workspaceToit/fuzzy_logic$ jag pkg install  --local .
Info: Package '.' installed with name 'fuzzy_logic'
```
a `package.yaml` file is created, like:  
```
dependencies:
  fuzzy_logic:
    path: .
```

In the src directory, for ease of use of your library, add a file named the same as your library, like `fuzzy_logic.toit`:  
```
import .antecedent
import .composition
import .consequent
import .fuzzy_input
import .fuzzy_model
import .fuzzy_output
import .fuzzy_rule
import .fuzzy_set
import .geometry
import .input_output
import .set_singleton
import .set_trapezoidal
import .set_trapezoidal_l
import .set_trapezoidal_r
import .set_triangular
import .set_triangular_lra
import .set_triangular_rra

export *   //  <-- Note, all files are exported to the `import fuzzy_logic` !
```

In tests directory:  
```
david@MSI-7D43:~/workspaceToit/fuzzy_logic/tests$ jag pkg init
david@MSI-7D43:~/workspaceToit/fuzzy_logic/tests$ jag pkg install --local ..
Info: Package '..' installed with name 'fuzzy_logic'
```
a `package.yaml` file is created, like:  
```
dependencies:
  fuzzy_logic:
    path: ..
```

## References
1. [Polybool](http://globec.whoi.edu/software/saga/polybool.m)