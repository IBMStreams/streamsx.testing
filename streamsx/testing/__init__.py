# coding=utf-8
# Licensed Materials - Property of IBM
# Copyright IBM Corp. 2018
"""
IBM Streams application testing.

********
Overview
********

Testing of an application, sub-graph or operator is performed
by building a Python topology that invokes the element under test
in a standard Python unittest. The element under test can be
a SPL application, sub-graph, operator or a Python application,
sub-graph or single transformation. See :ref:`sxt-testing-overview`.

Testing of SPL functions is performed by declaring series of
input data and expected output. See :ref:`sxt-fn-testing-overview`.

Python is a natural choice for testing of SPL applications as
tests can be written simply and executed immediately without
a compilation step. By use of the standard Python unittest existing
tools such as ``nosetets`` can be used to run tests, produce reports
and integrate with continuous integration tools such as Jenkins.

.. _sxt-testing-overview:

****************
Testing overview
****************

Allows testing of a streaming application by creation conditions
on streams that are expected to become valid during the processing.
`Tester` is designed to be used with Python's `unittest` module.

A complete application may be tested or fragments of it, for example a sub-graph can be tested
in isolation that takes input data and scores it using a model.

Supports execution of the application on ``STREAMING_ANALYTICS_SERVICE``,
``DISTRIBUTED`` or ``STANDALONE``.

A :py:class:`Tester` instance is created and associated with the ``Topology`` to be tested.
Conditions are then created against streams, such as a stream must receive 10 tuples using
:py:meth:`~Tester.tuple_count`.

Here is a simple example that tests a filter correctly passes tuples with values greater than 5::

    import unittest
    from streamsx.testing import Tester
    from streamsx.topology.topology import Topology

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


A stream may have any number of conditions and any number of streams may be tested.

A :py:meth:`~Tester.local_check` is supported where a method of the
unittest class is executed once the job becomes healthy. This performs
checks from the context of the Python unittest class, such as
checking external effects of the application or using the REST api to
monitor the application.

A test fails-fast if any of the following occur:
    * Any condition fails. E.g. a tuple failing a :py:meth:`~Tester.tuple_check`.
    * The :py:meth:`~Tester.local_check` (if set) raises an error.
    * The job for the test:
        * Fails to become healthy.
        * Becomes unhealthy during the test run.
        * Any processing element (PE) within the job restarts.

A test timeouts if it does not fail but its conditions do not become valid.
The timeout is not fixed as an absolute test run time, but as a time since "progress"
was made. This can allow tests to pass when healthy runs are run in a constrained
environment that slows execution. For example with a tuple count condition of ten,
progress is indicated by tuples arriving on a stream, so that as long as gaps
between tuples are within the timeout period the test remains running until ten tuples appear.

.. note:: The test timeout value is not configurable.

.. note:: The submitted job (application under test) has additional elements (streams & operators) inserted to implement the conditions. These are visible through various APIs including the Streams console raw graph view. Such elements are put into the `Tester` category.

.. note:: :py:class:`Tester` is an import of `streamsx.topology.tester.Tester`.

.. _sxt-fn-testing-overview:

*****************************
SPL function testing overview
*****************************

SPL functions can tested using :py:class:`FnTester` by providing series
of input values and the expected function return values.
Functions under test may be SPL or SPL native functions
(implemented in Java or C++).


"""

__version__='0.3.1'

__all__ = ['Tester', 'FnTester']

from streamsx.topology.tester import Tester
from streamsx.testing._fn import FnTester
