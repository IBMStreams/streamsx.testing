#--variantCount=15
#--TTRO_caseStep:=myStep

declare -a durations=(30 20 22 44 30 60 30 30 33 34
                      55 66 88 11 30)
function myStep {
	useCpu ${durations[$TTRO_caseVariant]} $TTRO_caseVariant "false"
}