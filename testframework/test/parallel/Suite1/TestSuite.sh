#--TTRO_suitePrep:=myFunc

source "$TTRO_scriptDir/testutils.sh"
TT_timeout=90
TT_extraTime=10

function myFunc {
	echo "$FUNCNAME : Test suite prep"
	useCpu 5 1 ""
}