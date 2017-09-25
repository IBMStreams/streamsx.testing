#########################################################
# Initializatio section

TTRO_help_streamsutilsInitialization='
# Module initialization
#	check streams environment
#	set required properties and variables
#	this section is guarded with propertie TTP_streamsutilsInitialized'
if isNotExisting 'TTP_streamsutilsInitialized'; then
	setVar 'TTP_streamsutilsInitialized' 'true'
	isDebug && printDebug "streamsutilsInitialization"
	#environment check
	if ! declare -p STREAMS_INSTALL > /dev/null; then
		printErrorAndExit "Missing environment: STREAMS_INSTALL must be set" ${errEnv}
	fi
	#set props
	setVar 'TTP_splcFlags' '-a'
	setVar 'TTPN_splc' "${STREAMS_INSTALL}/bin/sc"
	setVar 'TTPN_st' "${STREAMS_INSTALL}/bin/streamtool"
	setVar 'TTPN_md' "${STREAMS_INSTALL}/bin/spl-make-doc"
	setVar 'TTPN_mt' "${STREAMS_INSTALL}/bin/spl-make-toolkit"
	setVar 'TTPN_swsPort' '8443'
	setVar 'TTPN_jmxPort' '9443'
	setVar TTPN_numresources 1

	if declare -p STREAMS_ZKCONNECT &> /dev/null && [[ -n $STREAMS_ZKCONNECT ]]; then
		setVar TTPN_streamsZkConnect "$STREAMS_ZKCONNECT"
	else
		setVar TTPN_streamsZkConnect ""
	fi
	echo "streamsutilsInitialization: TTPN_streamsZkConnect=$TTPN_streamsZkConnect"
	if declare -p STREAMS_DOMAIN_ID &> /dev/null && [[ -n $STREAMS_DOMAIN_ID ]]; then
		setVar TTPN_streamsDomainId "$STREAMS_DOMAIN_ID"
		echo "streamsutilsInitialization: TTPN_streamsDomainId=$TTPN_streamsDomainId"
	fi
	if declare -p STREAMS_INSTANCE_ID &> /dev/null && [[ -n $STREAMS_INSTANCE_ID ]]; then
		setVar TTPN_streamsInstanceId "$STREAMS_INSTANCE_ID"
		echo "streamsutilsInitialization: TTPN_streamsInstanceId=$TTPN_streamsInstanceId"
	fi
	# test var to check duplicate init
	setVar 'TTRO_ttt' '55'
	# variables required for functions
	setVar 'TT_mainComposite' 'Main'
	setVar 'TT_evaluationFile' './EVALUATION.log'
	setVar 'TT_sabFile' './output/Main.sab' 
	setVar 'TT_jobFile' './jobno.log'
fi
# the variable runtime dependent globals
# ...

#########################################################
# Functions section

TTRO_help_copyAndTransformSpl='
# Function copyAndTransformSpl
#	Copy all files from input directory to workdir and
#	Transform spl files'
function copyAndTransformSpl {
	copyAndTransform "$TTRO_inputDirCase" "$TTRO_workDirCase" "$TTRO_caseVariant" '*.spl'
}

TTRO_help_compile='
# Function compile
#	Compile spl application expect successful result
#	No treatment in case of compiler error'
function compile {
	echoAndExecute ${TTPN_splc} "$TTP_splcFlags" -M $TT_mainComposite -t "$TT_toolkitPath" -j $TTRO_treads
}

TTRO_help_compileAndFile='
# Function compileAndFile
#	Compile spl application expect successful result
#	compiler colsole & error output is stored into file
#	No treatment in case of compiler error'
function compileAndFile {
	echoAndExecute ${TTPN_splc} "$TTP_splcFlags" -M $TT_mainComposite -t "$TT_toolkitPath" -j $TTRO_treads 2>&1 | tee "$TT_evaluationFile"
}

TTRO_help_compileAndIntercept='
# Function compileAndIntercept
#	Compile spl application and intercept compile errors
#	compiler colsole & error output is stored into file
#	compiler result code is sored in result'
function compileAndIntercept {
	if echoAndExecute ${TTPN_splc} "$TTP_splcFlags" -M $TT_mainComposite -t "$TT_toolkitPath" -j $TTRO_treads 2>&1 | tee "$TT_evaluationFile"; then
		result=0
	else
		result=$?
	fi
	return 0
}

TTRO_help_makeZkParameter='
# Function makeZkParameter
#	makes the zk parameter from zk environment
#	$1 zk string
#	use global variable zkParam'
function makeZkParameter {
	zkParam="--embeddedzk"
	if [[ -n $1 ]]; then
		zkParam="--zkconnect $1"
	fi
}

TTRO_help_mkDomain='
# Function mkDomain
#	Make domain from global properties'
function mkDomain {
	mkDomainVariable "$TTPN_streamsZkConnect" "$TTPN_streamsDomainId" "$TTPN_swsPort" "$TTPN_jmxPort"
}

TTRO_help_mkDomainVariable='
# Function mkDomainVariable
#	Make domain with variable parameters
#	$1 zk connect string
#	$2 domainname
#	$3 sws port
#	$4 jmx port'
function mkDomainVariable {
	isDebug && printDebug "$FUNCNAME $*"
	if [[ -n $TTRO_noStart ]]; then
		echo "$FUNCNAME : function supressed"
		return 0
	fi
	local zkParam
	makeZkParameter "$1"
	#local params="$zkstring --property SWS.Port=8443 --property JMX.Port=9443 --property domain.highAvailabilityCount=1 --property domain.checkpointRepository=fileSystem --property domain.checkpointRepositoryConfiguration= { \"Dir\" : \"/home/joergboe/Checkpoint\" } "
	if ! echoAndExecute $TTPN_st mkdomain "$zkParam" --domain-id "$2" --property "SWS.Port=$3" --property "JMX.Port=$4" --property domain.highAvailabilityCount=1; then
		printError "$FUNCNAME : Can not make domain $2"
		return $errTestFail
	fi
	if ! echoAndExecute $TTPN_st genkey "$zkParam"; then
		printError "$FUNCNAME : Can not genrate key $2"
		return $errTestFail
	fi
}

TTRO_help_startDomain='
# Function startDomain
#	Start domain from global properties'
function startDomain {
	startDomainVariable "$TTPN_streamsZkConnect" "$TTPN_streamsDomainId"
}

TTRO_help_startDomainVariable='
# Function startDomainVariable
#	Make domain with variable parameters
#	$1 zk connect string
#	$2 domainname'
function startDomainVariable {
	isDebug && printDebug "$FUNCNAME $*"
	if [[ -n $TTRO_noStart ]]; then
		echo "$FUNCNAME : function supressed"
		return 0
	fi
	local zkParam
	makeZkParameter "$1"
	if ! echoAndExecute $TTPN_st startdomain "$zkParam" --domain-id "$2"; then
		printError "$FUNCNAME : Can not start domain $2"
		return $errTestFail
	fi
}

TTRO_help_mkInst='
# Function mkInst
#	Make instance from global properties'
function mkInst {
	mkInstVariable "$TTPN_streamsZkConnect" "$TTPN_streamsInstanceId" "$TTPN_numresources"
}

TTRO_help_mkInstVariable='
# Function mkInstVariable
#	Make instance with variable parameters
#	$1 zk connect string
#	$2 instance name
#	$3 numresources'
function mkInstVariable {
	isDebug && printDebug "$FUNCNAME $*"
	if [[ -n $TTRO_noStart ]]; then
		echo "$FUNCNAME : function supressed"
		return 0
	fi
	local zkParam
	makeZkParameter "$1"
	if ! echoAndExecute $TTPN_st mkinst "$zkParam" --instance-id "$2" --numresources "$3"; then
		printError "$FUNCNAME : Can not make instance $2"
		return $errTestFail
	fi
}

TTRO_help_startInst='
# Function startInst
#	Start instance from global properties'
function startInst {
	startInstVariable "$TTPN_streamsZkConnect" "$TTPN_streamsInstanceId"
}

TTRO_help_startInstVariable='
# Function startInstVariable
#	Start instance with variable parameters
#	$1 zk connect string
#	$2 domainname'
function startInstVariable {
	isDebug && printDebug "$FUNCNAME $*"
	if [[ -n $TTRO_noStart ]]; then
		echo "$FUNCNAME : function supressed"
		return 0
	fi
	local zkParam
	makeZkParameter "$1"
	if ! echoAndExecute $TTPN_st startinst "$zkParam" --instance-id "$2"; then
		printError "$FUNCNAME : Can not start instance $2"
		return $errTestFail
	fi
}

TTRO_help_cleanUpInstAndDomainAtStart='
# Function cleanUpInstAndDomainAtStart
#	stop and clean instance and domain'
function cleanUpInstAndDomainAtStart {
	cleanUpInstAndDomainVariable "start" "$TTPN_streamsZkConnect" "$TTPN_streamsDomainId" "$TTPN_streamsInstanceId"
}

TTRO_help_cleanUpInstAndDomainAtStop='
# Function cleanUpInstAndDomainAtStop
#	stop and clean instance and domain'
function cleanUpInstAndDomainAtStop {
	cleanUpInstAndDomainVariable "stop" "$TTPN_streamsZkConnect" "$TTPN_streamsDomainId" "$TTPN_streamsInstanceId"
}

TTRO_help_cleanUpInstAndDomainVariable='
# Function cleanUpInstAndDomainVariable
#	stop and clean instance and domain from variable params
#	$1 start or stop determines the if TTRO_noStart or TTRO_noStop is evaluated
#	$2 zk string
#	$3 domain id
#	$4 instance id'
function cleanUpInstAndDomainVariable {
	isDebug && printDebug "$FUNCNAME $*"
	if [[ $1 == start ]]; then
		if [[ -n $TTRO_noStart ]]; then
			echo "$FUNCNAME : at start function supressed"
			return 0
		fi
	elif [[ $1 == stop ]]; then
		if [[ -n $TTRO_noStop ]]; then
			echo "$FUNCNAME : at stop function supressed"
			return 0
		fi
	else
		printErrorAndExit "wrong parameter 1 $1" $errRt
	fi

	local zkParam
	makeZkParameter "$2"
	
	echo "streamtool lsdomain $zkParam $3"
	local response
	if response=$(echoAndExecute $TTPN_st lsdomain "$zkParam" "$3"); then # domain exists
		if [[ $response =~ $3\ Started ]]; then # domain is running
			#Running domain found check instance
			if echoAndExecute $TTPN_st lsinst "$zkParam" --domain-id "$3" "$4"; then
				if echoAndExecute $TTPN_st lsinst "$zkParam" --started --domain-id "$3" "$4"; then
					#TODO: check whether the retun code is fine here
					echoAndExecute $TTPN_st stopinst "$zkParam" --force --domain-id "$3" --instance-id "$4"
				else
					isVerbose && echo "$FUNCNAME : no running instance $4 found in domain $3"
				fi
				echoAndExecute $TTPN_st rminst "$zkParam" --noprompt --domain-id "$3" --instance-id "$4"
			else
				isVerbose && echo "$FUNCNAME : no instance $4 found in domain $3"
			fi
			#End Running domain found check instance
			echoAndExecute $TTPN_st stopdomain "$zkParam" --force --domain-id "$3"
		else
			isVerbose && echo "$FUNCNAME : no running domain $3 found"
		fi
		echoAndExecute $TTPN_st rmdomain "$zkParam" --noprompt --domain-id "$3"
	else
		isVerbose && echo "$FUNCNAME : no domain $3 found"
	fi
	return 0
}

TTRO_help_submitJobOld='
# Function submitJobOld
#	$1 sab files
#	$2 output file name'
function submitJobOld {
	submitJobVariable "$TTPN_streamsZkConnect" "$TTPN_streamsDomainId" "$TTPN_streamsInstanceId" "$1" "$2"
}

TTRO_help_submitJob='
# Function submitJob
#	submits a job and provides the joboutput file'
function submitJob {
	submitJobVariable "$TTPN_streamsZkConnect" "$TTPN_streamsDomainId" "$TTPN_streamsInstanceId" "$TT_sabFile" "$TT_jobFile"
}

TTRO_help_submitJobAndFile='
# Function submitJobAndFile
#	submits a job and provides the joboutput file
#	provide stdout and stderror in file for evaluation'
function submitJobAndFile {
	submitJobVariable "$TTPN_streamsZkConnect" "$TTPN_streamsDomainId" "$TTPN_streamsInstanceId" "$TT_sabFile" "$TT_jobFile" 2>&1 | tee "$TT_evaluationFile"
}

TTRO_help_submitJobAndIntercept='
# Function submitJobAndIntercept
#	submits a job and provides the joboutput file
#	provide stdout and stderror in file for evaluation
#	provides return code of in variable result'
function submitJobAndIntercept {
	if submitJobVariable "$TTPN_streamsZkConnect" "$TTPN_streamsDomainId" "$TTPN_streamsInstanceId" "$TT_sabFile" "$TT_jobFile" 2>&1 | tee "$TT_evaluationFile"; then
		result=0
	else
		result=$?
	fi
	return 0
}

TTRO_help_submitJobVariable='
# Function submitJobVariable
#	$1 zk string
#	$2 domain id
#	$3 instance id
#	$4 sab files
#	$5 output file name
#	use global variable jobno for jobnumber'
function submitJobVariable {
	isDebug && printDebug "$FUNCNAME $*"
	local zkParam
	makeZkParameter "$1"
	if echoAndExecute $TTPN_st submitjob "$zkParam" --domain-id "$2" --instance-id "$3" --outfile "$5" "$4"; then
		if [[ -e $5 ]]; then
			jobno=$(<"$5")
			return 0
		else
			return $errTestFail
		fi
	else
		return $errTestFail
	fi
}
declare jobno=''

TTRO_help_cancelJob='
# Function cancelJob
#	$1 jobno'
function cancelJob {
	cancelJobVariable "$TTPN_streamsZkConnect" "$TTPN_streamsDomainId" "$TTPN_streamsInstanceId" "$1"
}

TTRO_help_cancelJobVariable='
# Function cancelJobVariable
#	$1 zk string
#	$2 domain id
#	$3 instance id
#	$4 jobno'
function cancelJobVariable {
	isDebug && printDebug "$FUNCNAME $*"
	local zkParam
	makeZkParameter "$1"
	if echoAndExecute $TTPN_st canceljob "$zkParam" --domain-id "$2" --instance-id "$3" "$4"; then
		return 0
	else
		return $errTestFail
	fi
}

:
