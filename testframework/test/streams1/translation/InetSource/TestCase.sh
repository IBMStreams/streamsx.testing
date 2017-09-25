# Translation compile test for InetSource
#--variantCount=2

#--TTRO_casePrep:=copyAndTransformSpl
#--TTRO_caseStep:=myCompile myEvaluate

function myCompile {
	local result
	if ${TTRO_splc} "$TTP_splcFlags" -M com.ibm.streamsx.inet.sample::GetWeather -t $TTPN_streamsInetToolkit -j $TTRO_treads 2>&1 | tee STDERROUT_myCompile.log; then
		result=$?
	else
		result=$?
	fi
	echo "######### myCompile result $result"
	if [[ $TTRO_caseVariant -eq 0 ]]; then
		if [[ $result -eq 0 ]]; then
			return 0
		else
			return $errTestFail
		fi
	else
		if [[ $result -eq 0 ]]; then
			return $errTestFail
		else
			return 0
		fi
	fi
}

function myEvaluate {
	if [[ $TTRO_caseVariant -eq 0 ]]; then
		return 0
	fi
	linewisePatternMatch './STDERROUT_myCompile.log' '' 'CDISP9164E ERROR: CDIST0200E: InetSource operator cannot be used inside a consistent region*'
}