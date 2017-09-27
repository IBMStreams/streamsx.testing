# Examples for Testing SPL Operator

This example demonstrates using an SPL test composite to test an SPL operator. The SPL operator under test in this case is an SPL composite with a single SPL Custom, but could be SPL composite containing a sub-graph or an SPL primitive operator (implemented in C++, Java, or Python). 

## Toolkit Under Test

com.ibm.streamsx.testing.examples.operators.app is the toolkit under test.  The toolkit contains two composite operators:

* com.ibm.streamsx.testing.examples.operators::MultipyBy - This is the SPL composite under test.  This composite contains a single Custom operator.  The goal of the example is to test that the logic of this Custom operator.  
* com.ibm.streamsx.testing.examples.operators.app::Main - This is the main composite that uses the MultiplyBy composite operator.  


The SPL test composite invokes the operator under test (in this case connecting it to a Beacon as a source) and then the Java or Python test apis are used to invoke the test composite and verify the correct data is produced.

In this example, we have the following projects:

* com.ibm.streamsx.testing.examples.composites.app - This contains the SPL composite under test as well as the main composite for an application.
* com.ibm.streamsx.testing.examples.composites.spl - This contains the SPL composite for testing
* com.ibm.streamsx.testing.examples.composites.java - This project demonstrates how clients can test SPL composites using Java Application API and the JUnit framework
* com.ibm.streamsx.testing.examples.composites.python - This project demonstrates how clients can test SPL composites using the Python Application API and the Python unittest framework
