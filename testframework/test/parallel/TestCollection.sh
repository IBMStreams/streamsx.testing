#--TTRO_testPrep:="testPreparation"
#--TTRO_testFin:=testFinalization

source "$TTRO_scriptDir/testutils.sh"

function testPreparation {
	echo "$FUNCNAME : Running global test preparation"
	useCpu 4 1 ""
}
function testFinalization {
	echo "$FUNCNAME : Running test shut down"
	useCpu 4 1 ""
}
