package com.ibm.streamsx.testing.examples.operators.java;

import java.io.File;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import org.junit.Assert;
import org.junit.Test;

import com.ibm.streams.operator.StreamSchema;
import com.ibm.streams.operator.Type;
import com.ibm.streamsx.topology.TStream;
import com.ibm.streamsx.topology.Topology;
import com.ibm.streamsx.topology.context.StreamsContextFactory;
import com.ibm.streamsx.topology.spl.SPL;
import com.ibm.streamsx.topology.spl.SPLStream;
import com.ibm.streamsx.topology.tester.Condition;
import com.ibm.streamsx.topology.tester.Tester;


/*
 * This class hows how one can test a SPL composite operator using JUnit
 * and the Streams Java Application API.
 */
public class TestMultiplyBy {
	
	/*
	 * Method to create the topology, submit the application based on 
	 * the specified context and validate data
	 */
	private void doTestMultiplyBy(String context) throws Exception {
		
		// Create topology to drvie the test
		Topology topo = new Topology("TestMultiplyBy");
				
		// Add the toolkit under test to the toolkit path
		SPL.addToolkit(topo, new File("../com.ibm.streamsx.testing.examples.operators.spl"));
		SPL.addToolkit(topo, new File("../com.ibm.streamsx.testing.examples.operators.app"));
		
		// Get SPL Schema for test result
		StreamSchema schema = Type.Factory.getStreamSchema("tuple<int32 result>");
		
		// Set up parameters for the composite operator
		Map<String, Object> params = new HashMap<String, Object>();
		params.put("factor", 3);
		
		// Invoke the test composite
		SPLStream resultStream = SPL.invokeSource(topo, "com.ibm.streamsx.testing.examples.operators.spl::TestMultiplyBy", params, schema);
		
		// Convert the SPL Stream to TStream so we can work with it with the tester
		TStream<Integer> tStream = resultStream.convert(t->{
			return t.getInt("result");
		});
				
		// Set up tester to validate test result
		Tester tester = topo.getTester();
		Condition tupleCnt = tester.tupleCount(tStream, 34);
		
		// Submit the test.  Test will run and timeout in 10 seconds
		tester.complete(StreamsContextFactory.getStreamsContext(context), tupleCnt, 10, TimeUnit.SECONDS);
		
		// Validate that the test generate correct tuple count
		Assert.assertTrue(tupleCnt.valid());	
	}
	
	
	/*
	 * Test in standalone mode
	 */
	@Test
	public void testStandalone() throws Exception {		
		doTestMultiplyBy("STANDALONE_TESTER");
		
	}
	
	/*
	 * Test in distributed mode
	 */
	@Test
	public void testDistributed() throws Exception {
		 doTestMultiplyBy("DISTRIBUTED_TESTER");
	}

}
