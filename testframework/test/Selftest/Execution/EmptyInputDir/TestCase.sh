
#--TTRO_caseStep:=executeCase myEvaluate

function executeCase {
	echo $TTRO_inputDirCase
	if $TTPN_binDir/runTTF --directory "$TTRO_inputDirCase" 2>&1 | tee STDERROUT1.log; then
		return 0
	else
		return $errTestFail
	fi
}

function myEvaluate {
	linewisePatternMatch './STDERROUT1.log' 'true' '*\*\*\*\*\* case variants=0 skipped=0 failures=0 errors=0' '*\*\*\*\*\* suite variants=0*' '*\*\*\*\*\* suite variants=0*'
}