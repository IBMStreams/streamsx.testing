#--variantCount=4
#--TTRO_casePrep:=copyAndModifyTestCollection
#--TTRO_caseStep:=executeCase myEvaluate

declare -a options=( '' '-j 1' '-j 1 -v' '-j 1 -v -d' )

function executeCase {
	echo $TTRO_inputDirCase
	if echoAndExecute $TTPN_binDir/runTTF --directory "$TTRO_inputDirCase/testCollection" ${options[$TTRO_caseVariant]} 2>&1 | tee STDERROUT1.log; then
		return $errTestFail
	else
		return 0
	fi
}

function myEvaluate {
	#linewisePatternMatch './STDERROUT1.log' 'true' '*\*\*\*\*\* case variants=0 skipped=0 failures=0 errors=0' '*\*\*\*\*\* suite variants=0*' '*\*\*\*\*\* suite variants=0*'
	linewisePatternMatch './STDERROUT1.log' '' '*ERROR: No test collection file *TestCollection.sh found*'
}