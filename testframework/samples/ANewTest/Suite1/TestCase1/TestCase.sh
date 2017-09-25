#--variantCount=3
#--TTRO_caseStep:=myTestStep

function myTestStep {
	if [[ $TTRO_caseVariant -eq 0 ]]; then
		return 0
	elif [[ $TTRO_caseVariant -eq 1 ]]; then
		return 1
	else
		return $errTestFail
	fi
}

