# Translation compile test for InetSource

#--TTRO_casePrep:=copyOnly
#--TTRO_caseStep:=myCompile mySubmit mycheckJobFile

function myCompile {
	${TTRO_splc} "$TTP_splcFlags" -M com.ibm.streamsx.inet.sample::GetWeather -t $TTPN_streamsInetToolkit -j $TTRO_treads 2>&1 | tee STDERROUT_myCompile.log
}

function mySubmit {
	submitJob "output/com.ibm.streamsx.inet.sample.GetWeather.sab" "jobno.log"
}

function mycheckJobFile {
	if [[ -e jobno.log ]]; then
		return 0
	else
		return $errTestFail
	fi
}