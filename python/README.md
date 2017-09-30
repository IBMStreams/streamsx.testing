# Testing IBM Streams artifacts with Python.
## Overview
The Python package [streamsx](https://pypi.python.org/pypi/streamsx) contains a testing facility. The testing facility integrates with the standard Python [unittest](https://docs.python.org/3.5/library/unittest.html) package allowing full use of all its capabilities. Testing is supported against Streaming Analytics service, a Streams distributed instance or standalone.

An test application is built and conditions are placed against streams, e.g. this stream must contains 42 tuples or this stream must contain the tuples `A, B, C` in any order.

The test application can invoke Python callables and/or SPL operators. A test may be against a single operator, e.g. verify that the `MultipleBy` operator correctly multiplies by the supplied `factor` (ADD LINK), a sub-graph or a complete application. With a complete application affects of the application on external systems may need to be tested (e.g. was a database updated), in this case standard `unittest` approaches for that external system may be used to verify correct outcomes.

The testing facility requires Python 3.5 and Streaming Analytics service or IBM Streams 4.2.
## Quick example
Here is a simple example that tests a filter correctly only passes tuples with values greater than 5:

```
import unittest
from streamsx.topology.topology import Topology
from streamsx.topology.tester import Tester

class TestSimpleFilter(unittest.TestCase):

    def setUp(self):
        # Sets self.test_ctxtype and self.test_config
        Tester.setup_streaming_analytics(self)

    def test_filter(self):
        # Declare the application to be tested
        topology = Topology()
        s = topology.source([5, 7, 2, 4, 9, 3, 8])
        s = s.filter(lambda x : x > 5)

        # Create tester and assign conditions
        tester = Tester(topology)
        tester.contents(s, [7, 9, 8])

        # Submit the application for test
        # If it fails an AssertionError will be raised.
       tester.test(self.test_ctxtype, self.test_config)
```
A stream may have any number of conditions and any number of streams may be tested.

if this test was in the file `test_filter.py` then it could be run using:
```
python3 -u -m unittest test_filter.py
```
If the test module and/or class contains multiple tests (through multiple classes and/or methods) then a single test could be run as:
```
python3 -u -m unittest test_filter.TestSimpleFilter.test_filter
```

This test will run against the Streaming Analytics service, changing `setUp` or creating a sub-class with a different `setUp` would allow the test to be run against standalone or distributed.
## Reference
* [streamsx package](https://pypi.python.org/pypi/streamsx)
* [unittest package](https://docs.python.org/3.5/library/unittest.html) 
* [streamsx.topology.tester API reference](http://ibmstreams.github.io/streamsx.topology/doc/releases/latest/pythondoc/streamsx.topology.tester.html)
