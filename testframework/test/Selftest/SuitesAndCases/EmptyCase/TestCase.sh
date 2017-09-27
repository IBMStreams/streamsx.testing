#--variantCount=4
#--TTRO_casePrep:=copyAndModifyTestCollection
#--TTRO_caseStep:=echo TT_runOptions='"${options\[${TTRO_caseVariant}\]}"' TT_expectResult=$errTestError runRunTTF myEvaluate
##--TTRO_caseStep:=echo runRunTTF myEvaluate

declare -a options=( '' '-j 1' '-j 1 -v' '-j 1 -v -d' )
#TT_runOptions="${options[${TTRO_caseVariant}]}"
#TT_expectResult=$errTestError

#function getOptions {
#	TT_runOptions="${options[$TTRO_caseVariant]}"
#}

function myEvaluate {
	linewisePatternMatch './STDERROUT1.log' 'true' '*\*\*\*\*\* case variants=1 skipped=0 failures=0 errors=1' '*\*\*\*\*\* suite variants=1'
}
