# eFLL  (embedded Fuzzy Logic Library)

An adaption of the [Embedded Fuzzy Logic Library](https://github.com/zerokol/eFLL) to Toit.  

If curious, look at `test/test_fuzzy_lib.toit` for test cases; `test/test_lecture_1.toit`, `test/test_lecture_1.toit` and `test/test_casco.toit` for construction and usage of the models.

## Visualization of models
- open a monitor on the device, by `jag monitor -a`
- run the webserver in examples, by `jag run server.toit`
- look at the URL printed to the console, like: `Open a browser on: 192.168.0.240:8080`
- upon one of the 3 examples, with:
  - http://192.168.0.240:8080/driver
  - http://192.168.0.240:8080/driver_advanced
  - http://192.168.0.240:8080/casco
- move the sliders to change inputs, then click the 'outputs' link, to view the results


### ToDos
- resolve the result discrepancies (<1%) in the test suite, between the .cpp and .toit implementations
- rework test cases to current API
