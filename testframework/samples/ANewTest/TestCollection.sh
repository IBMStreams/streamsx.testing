# Put here more fixed variables and properties
#--TTPN_myProperty2:=This is a sample property #2

#Global test collection preparation steps
#--TTRO_testPrep=mySpecialPreparation
#--TTRO_testFin=mySpecialFinalization

# Put here the global initialization steps
echo "********************************"
echo "global initialization steps"
echo "\$PATH=$PATH"
if isExisting STREAMS_INSTALL; then
	echo "Streams Environment is $STREAMS_INSTALL"
else
	echo "No Streams environment"
fi
echo "********************************"

#Function definitions for test collections
function mySpecialPreparation {
	echo "**** $FUNCNAME ****"
	echo "TTPN_myProperty= $TTPN_myProperty"
	echo "TTPN_myProperty2=$TTPN_myProperty2"
}

function mySpecialFinalization {
	echo "**** $FUNCNAME ****"
	echo "TTPN_myProperty=$TTPN_myProperty"
	echo "TTPN_myProperty2=$TTPN_myProperty2"
}