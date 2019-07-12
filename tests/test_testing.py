from unittest import TestCase

from streamsx.testing import Tester
from streamsx.topology.topology import Topology

class TestRunTests(TestCase):

    def setUp(self):
        Tester.setup_standalone(self)
     
    def test_simple_app(self):
        # Basically testing the direct import of Tester works.
        topo = Topology()
        s = topo.source([1,2,3,4])
        s = s.filter(lambda x : x != 3)
        tester = Tester(topo)
        tester.contents(s, [1,2,4])
        tester.tuple_count(s, 3)
        tester.test(self.test_ctxtype, self.test_config)
