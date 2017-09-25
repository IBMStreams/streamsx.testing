#####################################################
# Utilities for the main propertiesgram
#####################################################

#
# usage description
#
function usage {
	local command=${0##*/}
	cat <<-EOF

	usage: ${command} [option ..] [case ..];

	OPTIONS:
	-h|--help                : display this help
	--man                    : display man page
	--ref                    : display function reference. This function requires a specified input directory.
	-w|--workdir  VALUE      : The working directory. Here are all work files and results are stored. Default is ./${DEFAULT_WORKDIR} .
	-f|--flat                : Use flat working directory - does not include the date/time string into the workdir path
	--noprompt               : Do not prompt berfore an existing working directory is removed.
	-i|--directory VALUE     : The input directory - the test collection directory. There is no default. This option must be entered.
	-p|--properties VALUE    : This specifies the file with the global property values. Default is file $TEST_PROPERTIES in input directory.
	                           If this path is an relative path, it is expanded relative to the input directory.
	-t|--tools VALUE         : Includes (source) files with test tool scripts. This option can be given more than one time. This overwrites then
	                           TTRO_tools environment.
	-n|--no-checks           : The script omits the checkes for the streams environment and does not attempt to start domain/instance. Saves time
	-s|--skip-ignore         : If this option is given the ignore attribute of the cases are ignored
	-j|--threads VALUE       : The number of parallel test executions. (you have ${noCpus} (virtual) cores this is default)
	                           If the value is set to 1 no parallel execution is performed
	-l|--link                : Content found in data directoy are linked to workspace not copied (Set TTPN_link=true)
	--no-start               : Supress the execution of the start sequence (Set TTPN_noStart)
	--no-stop                : Supress the execution of tear stop sequencd (Set TTPN_noStop)
	-D value                 : Set the specified TT_-, TTRO_-, TTP_- or TTPN_- variable value (Use one of varname=value)
	-v|--verbose             : Be verbose to stdout
	-V|--version             : Print the version string
	-d|--debug               : Print debug information. Debug implies verbose.
	--bashhelp               : Print some hints for the use of bash
	
	
	case                     : The list of the testcases to execute. Each pattern must be composed in the form Suite:Case.
	                           Where Suite and case are a pattern (like file glob)
	                           If the case list is omitted, all test suites/cases found in input directory (without
	                           a skipped property) are executed
	
	Return Status:
	0     : Test Success
	1     : fatal error ( failed command etc. )
	${errTestFail}    : at least one test fails ( \${errTestFail} )
	${errTestError}    : at least one test error ( \${errTestError} )
	${errVersion}    : Streams version is not supported ( \${errVersion} )
	${errInvocation}    : Invocation error ( \${errInvocation} )
	${errScript}    : Script error ( \${errScript} )
	${errRt}    : Runntime error ( \${errRt} )
	${errEnv}    : Invalid environment ( \${errEnv} )
	${errSigint}   : SIGINT received ( \${errSigint} )
	EOF
}

#
# helpers for get parameters
#
function missOptionArg {
	printError "Missing Option argument $1 \n\n"
	usage;
	exit ${errInvocation}
}
function duplicateOption {
	printError "Duplicate option $1 \n\n"
	usage
	exit ${errInvocation}
}
function fewArgs {
	printError "To few arguments!!!\n\n"
	usage;
	exit ${errInvocation}
}
function optionInParamSection {
	printError "Option argument $1 must be placed before cases section\n\n"
	usage;
	exit ${errInvocation}
}

#
# Search for test suites. Suites are directories with a suite definition file $TEST_SUITE_FILE
# Use global caseMap and noSuites
function searchSuites {
	local suite=""
	local myPath=""
	local x
	for x in ${directory}/**/$TEST_SUITE_FILE; do
		if [[ -f $x || -h $x ]]; then # recognize links to
			isDebug && printDebug "Found Suite properties file ${x}"
			suite=""; myPath="";
			myPath="${x%/$TEST_SUITE_FILE}"
			if [[ $x == *\ * ]]; then
				printErrorAndExit "Invald path : $x\nPathes must not contain spaces." ${errRt}
			fi
			suite="${myPath##*/}" # suite name is the last part of the path
			isDebug && printDebug "Found Suite ${suite}"
			#enter an empty value here
			caseMap["${myPath}"]="" #enter an empty value here
			noSuites=$(( noSuites+1 ))
		fi
	done
	return 0
}

#
# check nested suite and duplicate test suite names. This is considered an error
# Use global caseMap
function checkSuiteList {
	local n1 n2 i j
	for i in ${!caseMap[@]}; do
		for j in ${!caseMap[@]}; do
			#skip same entries
			if [ $i != $j ]; then
				#check for nested suites
				if [[ ${i} == ${j} ]]; then
					printErrorAndExit "Nested suites found\n$i\n$j\nSuites must not be nested" ${errRt}
				fi
				#check for equal names
				n1="${i##*/}"; n2="${j##*/}"
				if [ ${n1} == ${n2} ]; then
					printErrorAndExit "Same suite name found in \n$i\n$j" ${errRt}
				fi
			fi
		done
	done
	return 0
}

#
#search test cases. Cases are sub directories in suites with a case definition file $TEST_CASE_FILE
#cases are entered as value into the caseMap as space separated list 
#Check for duplicates and nested elements
# Use global caseMap
function searchCases {
	local case="" casePath=""
	local -i noCases=0
	local myPath x tmp n1 n2 i j
	for myPath in ${!caseMap[@]}; do
		noCases=0
		for x in ${myPath}/**/$TEST_CASE_FILE; do
			if [[ -f $x || -h $x ]]; then # recognize also links to
				isDebug && printDebug "Found test case properprintDebugties file ${x}"
				case=""; casePath="";
				casePath="${x%/$TEST_CASE_FILE}"
				case="${casePath##*/}"
				isDebug && printDebug "Found case $case"
				if [[ $x == *\ * ]]; then
					"Invald path : $x\nPathes must not contain spaces." ${errRt}
				fi
				#put case into caseMap
				tmp="${caseMap["$myPath"]} ${casePath}"
				caseMap["$myPath"]="${tmp}"
				noCases=$(( noCases+1 ))
			fi
		done
		isDebug && printDebug "$noCases test cases found in $myPath"

		# check nested case and duplicate test case names
		for i in ${caseMap["$myPath"]}; do
			for j in ${caseMap["$myPath"]}; do
				#skip same entries
				if [ "$i" != "$j" ]; then
					#check for nested cases
					if [[ ${i} == ${j} ]]; then
						printErrorAndExit "Nested case found\n$i\n$j\nTest cases must not be nested" ${errRt}
					fi
					#check for same names
					n1="${i##*/}"; n2="${j##*/}"
					if [ "${n1}" == "${n2}" ]; then
						printErrorAndExit "Same test case name found in \n$i\n$j" ${errRt}
					fi
				fi
			done
		done
	done
	return 0
}

#
# Sort cases alphabetical
# Use global sortedSuites
# Use global executionList
# Use global noCases
function sortCases {
	local myPath suite x casePath case tmpx tmp
	local -i i
	for ((i=0; i<${#sortedSuites[@]}; i++)); do
		myPath="${sortedSuites[$i]}"
		isDebug && printDebug "***********\ntake suite=${myPath}"
		suite=${myPath##*/}
		executionList["$myPath"]=""
		shadowList["$myPath"]=""
		declare -a sortedCases=$( { for x in ${caseMap["$myPath"]}; do echo "$x"; done } | sort )
		isDebug && printDebug "sortedCases=\n$sortedCases\n**********"
		for casePath in ${sortedCases}; do
			case=${casePath##*/}
			isDebug && printDebug "take case=${case}"
			if [[ -n "$takeAllCases" ]]; then
				isDebug && printDebug "direct insert case=${case} into execution list"
				executionList["$myPath"]+=" ${casePath}"
				shadowList["$myPath"]+=" ${casePath}"
				noCases=$((noCases+1))
			else
				# lookup if cases are in input list
				tmpx="${!cases[@]}"
				for x in ${tmpx}; do
					tmp="${suite}:${case}"
					isDebug && printDebug "tmp='$tmp'"
					isDebug && printDebug "case='${cases[$x]}'"
					shadowList["$myPath"]+=" ${casePath}"
					if [[ $tmp == ${cases[$x]} ]]; then
						isDebug && printDebug "conditional insert case=${case} into execution list"
						executionList["$myPath"]+=" ${casePath}"
						noCases=$((noCases+1))
						isDebug && printDebug "unset cases[$x]"
						#unset cases[$x]  unset does not work here ??
						cases["$x"]=""
					fi
				done
			fi
		done
	done
	return 0
}

#
# function to execute the varians of suites
# $1 is the variant
# $2 is the suite variant workdir
# $3 execute empty suites
function exeSuite {
	if [[ ${executionList[$suitePath]} == "" && -z $3 ]]; then
		isDebug && printDebug "$FUNCNAME: skip empty suite $suitePath: variant='$1'"
		return 0
	fi
	suiteVariants=$((suiteVariants+1))
	echo "**** START Suite: ${suite} variant='$1' in ${suitePath} *****************"
	#make and cleanup suite work dir
	local sworkdir="$2"
	if [[ -e $sworkdir ]]; then
		rm -rf "$sworkdir"
	fi
	mkdir -p "$sworkdir"

	#execute suite variant
	local result=0
	if "${TTRO_scriptDir}/suite.sh" "${suitePath}" "${sworkdir}" "$1" ${executionList[$suitePath]} 2>&1 | tee -i "${sworkdir}/${TEST_LOG}"; then
		result=0;
	else
		result=$?
		if [[ ( $result -eq $errTestFail ) || ( $result -eq $errTestError ) ]]; then
			printWarning "Execution of suite ${suitePath} ended with result=$result"
		elif [[ $result -eq $errSigint ]]; then
			printWarning "Set sigint Execution of suite ${suitePath} ended with result=$result"
			interruptReceived="true"
		else
			printErrorAndExit "Execution of suite ${suitePath} ended with result=$result" $errRt
		fi
	fi
	
	#read result lists
	local x
	for x in VARIANT SUCCESS SKIP FAILURE ERROR; do
		local inputFileName="${sworkdir}/${x}_LIST"
		local outputFileName="${TTRO_workDir}/${x}_LIST"
		if [[ -e ${inputFileName} ]]; then
			{ while read; do
				echo "${suite}:$REPLY" >> "$outputFileName"
			done } < "${inputFileName}"
		else
			printError "No result list $inputFileName in suite $sworkdir"
		fi
	done

	echo "**** END Suite: ${suite} variant='$1' in ${suitePath} *******************"
	return 0
} #/exeSuite

#
# print command line parameters
#
function printParams {
	if isDebug; then
		printDebug "** Commandline parameters **"
		printDebug "TTRO_scriptDir=${TTRO_scriptDir}"
		local x
		for x in ${!singleOptions[@]}; do
			printDebug "${x}=${!x}"
		done
		for x in ${!valueOptions[@]}; do
			printDebug "${x}=${!x}"
		done
		printDebug "toolsFiles=$toolsFiles"
		local -i i
		for ((i=0; i<${#varNamesToSet[@]}; i++)); do
			printDebug "-D ${varNamesToSet[$i]}=${varValuesToSet[$i]}"
		done
		if (( ${#cases[*]} > 0 )); then
			printDebug "cases=${cases[*]}"
		else
			printDebug "cases()"
		fi
		echo "************"
	fi
}

:
