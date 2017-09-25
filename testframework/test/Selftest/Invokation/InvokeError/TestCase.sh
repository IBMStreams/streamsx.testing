
#--variantCount:=4
#--TTRO_caseStep:=executeCase myEvaluate

declare -ar prameterArray=("-zt" "--tools" "--link --no-start" "-Dbla=xx")

declare -ar outputValidation=("*ERROR: Invalid argument*" "*ERROR: Missing Option argument*" "*ERROR: Invalid argument \'--link\'*" "*ERROR: Invalid argument \'-Dbla=xx\'*")


function executeCase {
	local tmp="${prameterArray[$TTRO_caseVariant]}"
	if $TTPN_binDir/runTTF $tmp 2>&1 | tee STDERROUT1.log; then
		return $errTestFail
	else
		result=$?
		if [[ $result -ne $errInvocation ]]; then
			return $errTestFail
		else
			return 0
		fi
	fi
}

function myEvaluate {
	local tmp="${outputValidation[$TTRO_caseVariant]}"
	linewisePatternMatch './STDERROUT1.log' "" "$tmp"
}