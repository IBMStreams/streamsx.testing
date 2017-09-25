# Put here more fixed variables and properties for test suite
#--TTPN_myProperty:=This is a sample property set in suite
#--TTPN_mySuiteProperty:=This is a sample suite property

#Suite test collection preparation steps
#--TTRO_suitePrep=mySpecialSuitePreparation
#--TTRO_suiteFin=mySpecialSuiteFinalization

# Put here the suite initialization steps
echo "*********************************"
echo "global Suite initialization steps"
echo "*********************************"

#Function definitions for test collections
function mySpecialSuitePreparation {
	echo "**** $FUNCNAME ****"
	echo "TTPN_myProperty =$TTPN_myProperty"
	echo "TTPN_myProperty2=$TTPN_myProperty2"
	echo "TTPN_mySuiteProperty=$TTPN_mySuiteProperty"
}

function mySpecialSuiteFinalization {
	echo "**** $FUNCNAME ****"
	echo "TTPN_myProperty=$TTPN_myProperty"
	echo "TTPN_myProperty2=$TTPN_myProperty2"
	echo "TTPN_mySuiteProperty=$TTPN_mySuiteProperty"
}