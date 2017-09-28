# Examples for Testing SPL Operator

This example demonstrates using an SPL test composite to test an SPL operator. The SPL operator under test in this case is an SPL composite with a single SPL Custom, but could be SPL composite containing a sub-graph or an SPL primitive operator (implemented in C++, Java, or Python). 

## Toolkit Under Test

com.ibm.streamsx.testing.examples.operators.app is the toolkit under test.  The toolkit contains two operators:

* com.ibm.streamsx.testing.examples.operators::MultiplyBy - This is the SPL composite under test.  This composite contains a single Custom operator.  The goal of the example is to test the logic of MultipliBy composite operator.  
* com.ibm.streamsx.testing.examples.operators.app::Main - This is the main composite that uses the MultiplyBy composite operator.  

## SPL Test Composite

To test the `MultiplyBy` operator, we need a SPL Test Composite.  A test composite is responsible for the following:

* Generate test data to the operator under test
* Invoke the operator under test
* Output data from the test

The advantages of having this SPL Test composite are:
 
* It is easier to generate test data using Beacon and sending the data to the operator under test.  An alternative is to generate the test data in Java and Python.  But this makes the set up a bit more complicated as you have to cross language boundary.  It is easier to have data generation and the invocation of the operator in a single language.
* The SPL Test Composite outputs the data from the test run, allowing us to use the Java Application API or Python Application API to access the data to verify the correct data is produced.

In this example, the SPL test composite is stored in **com.ibm.streamsx.testing.examples.operator.spl** project.  

## Running the Test Composite

To test the operator, we need to invoke the SPL Test composite.  Invocation of the SPL Test composite means the following:

* Use Java / Python application to create a topology 
* In this topology, invoke the SPL Test Composite
* Get ther resulting stream from the SPL Test Composite
* Validate that the resulting stream contains the right data
* Submit the topology as standlone or distributed

This example demonstrates how you can do this in both Java and Python:

* com.ibm.streamsx.testing.examples.operators.java - This project shows how you can use the Java Application API and JUnit to automate testing of an SPL operator.
* com.ibm.streamsx.testing.examples.operators.python - This project shows how you can use the Python Application API and the unittest framework to automate testing of an SPL operator.
