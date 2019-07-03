# coding=utf-8
# Licensed Materials - Property of IBM
# Copyright IBM Corp. 2019
from streamsx.topology.tester import Tester
import streamsx.topology.schema as sch
from streamsx.topology.topology import Topology
import streamsx.spl.op as op

class _FnTester(object):
    def __init__(self, name):
        self._name = name
        self._topo = Topology()
        self._tester = Tester(self._topo)
    """SPL function tester.

    Creates a holder for an SPL function under test.

    Args:
        name: SPL namespace qualified name of the function.

    .. rubric:: Simple examples

    Example testing ``spl.math::abs`` with ``int32`` and ``float64`` values::

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
                tester.series(args, [abs(i) for i in args])

                # Setup a series of float64 values for testing
                args = [0.5, 0.0, -4.5]
                tester.series(args, [abs(i) for i in args])

                # Execute the test
                tester.test(self)

    """

    def series(self, args, expected, name=None):
        """ Test a series of values.

        Each value in `args` is passed into the function under test
        and the result expected to be the corresponding value in `expected`.

        Each value in `args` is a simple value for
        functions that accept a single parameter. Otherwise
        each value is a ``tuple`` with the number of required parameters.

        Each value in `expected` is a simple value for
        functions that return an SPL type that is not an SPL tuple.
        Otherwise each value is a ``tuple`` with the correct number 
        of values for the returned tuple schema.
        
        Args:
            args(list): List of values to be passed into the function under test.
            expected(list): List of expected results.
            name(str): Name of test.
        """
        self._args = args
        self._expected = expected

        arg_schema = _FnTester._schema(self._args, 'FnArgs', 'v')
        res_schema = _FnTester._schema(self._expected, 'FnResult', 'r')

        s = self._topo.source(self._args)

        if len(arg_schema._fields) == 1:
            s = s.map(lambda v : (v,), schema=arg_schema)
        else:
            s = s.map(schema=arg_schema)

        if name:
            oin = 'Fn'+name
        else:
            sn = self._name.split('::')
            oin = sn[len(sn)-1]
        
        fn = op.Map('spl.relational::Functor', s,
            schema=[res_schema], name=oin)

        attr_args = ''
        for attr in arg_schema._fields:
            if attr_args:
                attr_args += ','
            attr_args += attr;
        fn_expr = self._name + '(' + attr_args + ')'

        fn.r0 = fn.output(fn_expr)

        r = fn.stream.map(lambda t : t[0], name=name)

        self._tester.contents(r, self._expected)

    def test(self, test):
        self._tester.test(test.test_ctxtype, test.test_config)

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
