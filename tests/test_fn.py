import unittest
from streamsx.testing import Tester, FnTester

class TestFunctions(unittest.TestCase):

    def setUp(self):
        # Sets self.test_ctxtype and self.test_config
        Tester.setup_standalone(self)

    def test_single_param_single_return(self):
        tester = FnTester('spl.math::abs')

        args = [1,2,-3,0,-5]
        tester.series(args, [abs(i) for i in args])

        args = [0.5, 0.0, -4.5]
        tester.series(args, [abs(i) for i in args])

        tester.test(self)

    def test_multiple_param_single_return(self):
        tester = FnTester('spl.string::concat')

        # Passing two rstring args
        args = [('A','B'), ('C','D')]
        tester.series(args, ['AB', 'CD'])

        tester.test(self)
