import unittest

from streamsx.topology.topology import *
from streamsx.topology.tester import Tester
import streamsx.spl.op as op
import streamsx.spl.toolkit as tk
import numpy as np

# TestCustomStandalone class for driving the test in standalone mode
class TestCustomStandalone(unittest.TestCase):
    def setUp(self):
        ''' Set up to run test as Standalone'''
        Tester.setup_standalone(self)
    def _add_toolkits(self, topo):
        ''' Add required toolkits for test to run '''
        tk.add_toolkit(topo, '../com.ibm.streamsx.testing.app')
        tk.add_toolkit(topo, '../com.ibm.streamsx.testing.spl')
    def test_op(self):
        ''' Create topology to drive the test from com.ibm.streamsx.testing.spl '''
        topo = Topology()
        self._add_toolkits(topo)

        '''Set up parameter to call the test composite'''
        params = {'factor':3}

        ''' Call the test composite'''
        testStream = op.Source(topo, 'com.ibm.streamsx.testing.spl::TestMultiplyBy', 'tuple<int32 result>', params=params)

        ''' Convert the SPLStream to Python Stream so we can work with the data in the tester '''
        mapped = testStream.stream.map(lambda x: x['result'])

        ''' Set up Tester to validate the result of running the test composite'''
        tester = Tester(topo)

        ''' Example to check for tuple count'''
        tester.tuple_count(testStream.stream, 34)

        ''' Example to check content of hte stream with an expected list of data'''
        expected = list(np.arange(0, 100, 3))
        tester.contents(mapped, expected)

        ''' Example to check data tuple by tuple'''
        tester.tuple_check(testStream.stream, lambda  x:(x['result']%3)==0)

        tester.test(self.test_ctxtype, self.test_config)


# Example to run the same test in distributed mode
class TestCustomDistributed(TestCustomStandalone):
    def setUp(self):
        Tester.setup_distributed(self)


#class TestFTPCloud(TestFTP):
#    """ Test invocations of FTP operators with streaming analytics """
#    def setUp(self):
#        Tester.setup_streaming_analytics(self, force_remote_build=True)