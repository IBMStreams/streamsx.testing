# coding=utf-8
# Licensed Materials - Property of IBM
# Copyright IBM Corp. 2019
from streamsx.topology.tester import Tester
import streamsx.topology.schema as sch
from streamsx.topology.topology import Topology
import streamsx.spl.op as op

class FnTester(object):
    """SPL function tester.

    Creates a holder for an SPL function under test.

    Args:
        name: SPL namespace qualified name of the function.

    .. rubric:: Simple examples

    Example testing a function with a single parameter (``spl.math::abs``) with ``int32`` and ``float64`` values::

        import unittest
        from streamsx.testing import Tester, FnTester

        class TestStandardFunctions(unittest.TestCase):

            def setUp(self):
                # Sets self.test_ctxtype and self.test_config
                Tester.setup_standalone(self)

            def test_abs(self):
                # Declare the tester
                tester = FnTester('spl.math::abs')
        
                # Setup a series of int64 values for testing
                args = [1,2,-3,0,-5]
                tester.series(args, [abs(i) for i in args], name='abs_int64')

                # Setup a series of float64 values for testing
                args = [0.5, 0.0, -4.5]
                tester.series(args, [abs(i) for i in args], name='abs_float64')

                # Execute the test
                tester.test(self)

    .. note::
        The function under test and its series are tested using a 
        generated application run with :py:class:`Tester`.

    """
    def __init__(self, name):
        self._name = name
        self._topo = Topology()
        self._tester = Tester(self._topo)

    def series(self, args, expected, name=None):
        """ Declare a function test with a series of values.

        Each value in `args` is passed into the function under test
        and the result expected to be the corresponding value in `expected`.

        Each value in `args` is a simple value for
        functions that accept a single parameter. Otherwise
        each value is a ``tuple`` with the number of required parameters.

        Each value in `expected` is a simple value for
        functions that return an SPL type that is not an SPL tuple.  Otherwise each value is a ``tuple`` with the correct number 
        of values for the returned tuple schema.

        Multiple series may be created for a single instance of ``FnTester``,
        typically using different data types accepted by the function.

        The series tests are not executed until :py:ref:`FnTester.test` is called.

        The series `name` can aid with diagnostics when debugging tests or
        functions to clearly indicate which series is failing.
    
        Args:
            args(list): List of values to be passed into the function under test.
            expected(list): List of expected results.
            name(str): Name of series. Defaults to a generated name.
        """
        self._args = args
        self._expected = expected

        arg_schema = FnTester._schema(self._args, 'FnArgs', 'v')
        res_schema = FnTester._schema(self._expected, 'FnResult', 'r')

        if not name:
            sn = self._name.split('::')
            name = sn[len(sn)-1]

        s = self._topo.source(self._args, name='Args_'+name)
        s.category = 'Tester'

        if len(arg_schema._fields) == 1:
            s = s.map(lambda v : (v,), schema=arg_schema, name='SetSchema_'+name)
        else:
            s = s.map(schema=arg_schema, name='SetSchema_'+name)
        s.category = 'Tester'

        
        fn = op.Map('spl.relational::Functor', s,
            schema=[res_schema], name=name)
        fn.category = 'Tester'

        attr_args = ''
        for attr in arg_schema._fields:
            if attr_args:
                attr_args += ','
            attr_args += attr;
        fn_expr = self._name + '(' + attr_args + ')'

        fn.r0 = fn.output(fn_expr)

        r = fn.stream.map(lambda t : t[0], name='Results_'+name)
        r.category = 'Tester'

        self._tester.contents(r, self._expected)

    def test(self, test, assert_on_fail=True, always_collect_logs=False):
        """Test the function.

        Submits this function for testing and verifies all the series
        have the expected results.

        The submitted job containing the series tests is monitored and
        will be canceled when all the series are valid or at least one failed.

        The test passes if all series became valid.

        The test fails if the job is unhealthy or any series fails.

        In the event that the test fails the application logs are retrieved
        (when supported by the Streams instance)
        as a tar file and are saved to the current working directory. The filesystem path to the application logs is saved in the
        tester's result object under the `application_logs` key, i.e. `tester.result['application_logs']`

        The test case `test` must have been setup with on of
        :py:meth:`Tester.setup_standalone`,
        :py:meth:`Tester.setup_distributed` or
        :py:meth:`Tester.setup_streaming_analytics`.

        Args:
            test: Instance of ``unittest.TestCase`` running the function series.
            assert_on_fail(bool): True to raise an assertion if the test fails, False to return the passed status.
            always_collect_logs(bool): True to always collect the console log and PE trace files of the test.

        Returns:
            bool: `True` if test passed, `False` if test failed if `assert_on_fail` is `False`.

        """
        return self._tester.test(test.test_ctxtype, test.test_config,
            assert_on_fail=assert_on_fail, always_collect_logs=always_collect_logs)

    @staticmethod
    def _schema(values, name, ap):
        import typing
        v = values[0]
        if not isinstance(v, tuple):
            v = v,

        attrs = []
        for i in range(len(v)):
            name_type = ap + str(i), type(v[i])
            attrs.append(name_type)

        return typing.NamedTuple(name, attrs)
