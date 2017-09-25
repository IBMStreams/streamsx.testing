# Translation compile test for InetSource

#--TTRO_casePrep:=copyOnly
##--TTRO_caseStep:=TT_mainComposite='com.ibm.streamsx.inet.sample::GetWeather' compile submitJob mycheckJobFile
#--TTRO_caseStep:=compile submitJob myCheckJobFile

function myCheckJobFile {
	if [[ -e $TT_jobFile ]]; then
		echo -n "$FUNCNAME jobno is "
		cat "$TT_jobFile"
		return 0
	else
		return $errTestFail
	fi
}