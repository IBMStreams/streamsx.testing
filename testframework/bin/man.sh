function manpage () {
	local command=${0##*/}
	less <<-EOF

	The $command script is a framework for the control of test case execution.
	The execution of test case/suite variants and the parallel execution is inherently supported.
	
	Test Cases, Test Suites and Test Collections
	============================================
	A test case is comprised of a directory with the main test case file with name: '$TEST_CASE_FILE' and other necessary artifacts
	which are necessary for the test execution.
	The name of a test case is the last component of the path-name of the main test case file.
	
	A test suite is a collection of test cases which are organized in a test suite directory. The directory sub tree
	of the test suite may have an arbitrary depth.
	A test suite is defined through a directory with the main suite file with name: '$TEST_SUITE_FILE'
	The name of a test suite is the last component of the path-name of the main test suite file.
	
	One or more test suites or test cases form a Test Collection. A test collection is defined through a directory with the 
	test collection file with name: '$TEST_COLLECTION_FILE'.
	A test collection may have at the test properties file $TEST_PROPERTIES and at least one test
	Suite directory or a test Case directory. The name of the test properties file may be changed by a comman line parameter (--properties).
	
	Test suites must not be nested in other test suites or test cases.
	Test cases must not be nested in other test case directoreis.
	All path names of test cases and suites must not contain any white space characters. A test Suite must not have the name '--'.

	Execution Environment
	======================
	The test framework starts with the analysis of the input directory (option -i|--directory). If no cases list is given as
	command line parameter, all found test cases which are not marked with a 'skipped' property are executed.
	If a cases list is given from the command line, all test cases with match the cases list are executed (pattern match)
	
	All generated artifacts are stored in a sub-directory of the workdir (option -w|--workdir) for further analysis.
	The sub-directory name is composed of the actual date and time when the test case execution starts.
	
	A meanigfull summary is printed after test case execution.

	Test Property File $TEST_PROPERTIES
	===================================
	This file may contain global proprty and variable definitions. This file must no contain script code.
	
	
	Test Case File '$TEST_CASE_FILE' and Test Suite File '$TEST_SUITE_FILE'
	=======================================================================
	These files define the variants of a case/suite and the files may contain more test case properties.
	The file must have either no variant variable, a variantCount or a variantList.
	
	These files define the variants of a case/suite. The file must have either no variant variable, a variantCount or a variantList.
	The Test Case file may have additionally the type variable.
	
	The variantCount must be in the form:
	#--variantCount=<number>
	#--variantCount:=<number>
	
	The variantList must be a space separated list of identifiers or numbers or a mixture of identifieres and numbers:
	#--variantList=<list>
	#--variantList:=<list>
	
	These files may contain comment lines (# ...).
	
	Propertis are defined in the form:
	
	#--TT_<name>=<value><NL>
	#--TT_<name>:=<value><NL>
	#--TTRO_<name>=<value><NL>
	#--TTRO_<name>:=<value><NL>
	#--TTP_<name>=<value><NL>
	#--TTP_<name>:=<value><NL>
	#--TTPN_<name>=<value><NL>
	#--TTPN_<name>:=<value><NL>
	
	No spaces are allowed between #-- and the property name and between the name and the sign = :=
	If the := is used the value is literally taken into variable. If the = is used, the value is expanded (e.g. $STREAMS_INSTALL is expanded to 
	the real value)
	
	The value must fit ito one line.
	
	The test case and test suite file may contain script code for the test case execution.
	
	Test tools files
	================
	If your test collection requires special functions, you can sourced the aproppriate modules from the test collection file. 

	Property Variables
	==================
	Property variables are not changed once they have been defined. The definition of property 
	variables must be placed in a properies file. A re-definition in suites or cases propertie file will be ignored. 
	An assignement to a property in a test case script will cause a script failure. 
	The name of a property must be prefixed with TTP_ or TTPN_
	
	Empy values are considered a defined value for properties with prefix TTP_ and can not be overwritten.
	Empy values are considered a undefined value for properties with prefix TTPN_ and can be overwritten.

	In scripts properties can be defined with:
	declare -rx <name>=<value
	
	Simple Global Variables and Global Readonly Variables
	=====================================================
	Variables may be defined in Propertie files or in scripts. Simple variables and can be re-written in suite- or test-case-script. 
	Readonly variables can not be re-written in suite- or in test-case-script. 
	But the suite can re-write the test-run-global values and the test case can re-write the test-case-global 
	values and suite-values.
	
	The names of simple variables must be prefixed with TT_. The names of readonly variables must be prefixed 
	with TTRO_
	Define simple variables in propertie-file in the form:
	<name>=<value><NL>
	
	Define simple variables in a script in the form:
	export <name>=<value>
		or
	declare -x <name>=<value>

	Trueness and Falseness
	======================
	Logical variables with the semantics of an boolean are considered 'true' if these variables are set to somethig different than 
	the empty value (null). An empty (null) variable or an unset variable is considered 'false'.

	Accepted Environment
	====================

	Debug and Verbose
	=================
	The testframe may print verbose information and debug information or both. The verbosity may be enabled with command line options.
	Additionally the verbosity can be controlled with propertie values:
	TTPN_debug           - enables debug
	TTPN_debugDisable   - disables debug (overrides TTPN_debug)
	TTPN_verbose         - enables verbosity
	TTPN_verboseDisable - disables verbosity (overrides TTPN_verbose)

	Variables Used
	==============
	TTPN_skip             - Skips the test case execution
	TTPN_skipIgnore       - If set 

	TTRO_caseStep         - This variable is designed to store the list of test commands. If one command returns an failure (return code != 0), the test execution is stopped
	                         and the test is considered a failure. When the execution of all test commands return success the test case is
	                         considered a success.
	TTRO_casePrep         - This variable is designed to store the list of test case preparation commands. If one command returns an failure (return code != 0), the test execution is stopped
	                         and the test is considered an error.
	TTRO_caseFin          - This variable is designed to store the list of test case finalization commands. If one command returns an failure (return code != 0), the error is logged and the execution
	                         is continued
	                         and the test is considered an error.
	TTRO_suitePrep        - This variable stores the list of test suite preparation commands. If one command returns an failure (return code != 0), the test execution is stopped.
	TTRO_suiteFin         - This variables stores the list of test suite finalization commands. If one command returns an failure (return code != 0), the error is logged and the execution
	                        is continued
	TTRO_testPrep         - This variable stores the list of global test preparation commands. If one command returns an failure (return code != 0), the test execution is stopped.
	TTRO_testFin          - This variable stores the list of global test finalization commands. If one command returns an failure (return code != 0), the error is logged and the execution
	                        is continued
	                         
	TT_timeout            - The test case timeout in seconds. default is 120 sec.
	TT_extraTime          - The extra wait time after the test case time out. If the test case does not end after this time a SIGKILL is issued and the test case is stopped. The default is 30 sec.


	Variables Provided
	==================
	TTRO_workDir         - The output directory
	TTRO_workDirSuite    - The output directory of the suite
	TTRO_workDirCase     - The output directory of the case
	TTRO_inputDir        - The input directory
	TTRO_inputDirSuite   - The input directory of the suite
	TTRO_inputDirCase    - The input directory of the case
	TTRO_suite           - The suite name
	TTRO_case            - The case name
	TTRO_suiteVariant    - The variant of the suite
	TTRO_caseVariant     - The variant of the case
	TTRO_scriptDir       - The scripts path
	
	TTRO_noCpus          - The number of detected cores
	TTRO_noParallelCases - The max number of parallel executed cases. If set to 1 all cases are executed back-to-back
	TTRO_treads          - The number of threads to be used during test case execution. Is set to 1 if parallel test case
	                       execution is enabled. Is set to \$TTRO_noCpus if back-to-back test case execution is enabled.
	TTRO_reference       - The reference will be printet
	TTPN_noStart         - This property is provided with value "true" if the --no-start command line option is used. It is empty otherwise
	TTPN_noStop          - This  property is provided with value "true" if the --no-stop command line option is used. It is empty otherwise
	TTPN_link            - This  property is provided with value "true" if the --link command line option is used. It is empty otherwise
	
	
	EOF
}