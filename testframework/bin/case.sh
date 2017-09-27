#!/bin/bash

######################################################
# Test case
# Testframework Test Case execution script
######################################################

#some setup to be save
IFS=$' \t\n'
#some recomended security settings
unset -f unalias
\unalias -a
unset -f command
#more setting to be save
set -o posix;
set -o errexit; set -o errtrace; set -o nounset; set -o pipefail
shopt -s globstar nullglob

# Shutdown and interrut vars and functions
declare interruptReceived=""
declare -r commandname="${0##*/}"

# Function errorExit
#	global error exit function - prints the caller stack
function errorExit {
	echo -e "\033[31mERROR: $FUNCNAME ***************"
	local -i i=0;
	while caller $i; do
		i=$((i+1))
	done
	echo -e "************************************************\033[0m"
}

trap errorExit ERR

#includes
source "${TTRO_scriptDir}/defs.sh"
source "${TTRO_scriptDir}/util.sh"

#usage and parameters
function usage {
	local command=${0##*/}
	cat <<-EOF
	
	#usage: ${command} scriptsPath suitePath casePath workdir variant;
	usage: ${command} casePath workdir variant;
	
	EOF
}
isDebug && echo "$0 $*"
if [[ $# -ne 3 ]]; then
	usage
	exit ${errInvocation}
fi
declare -r TTRO_inputDirCase="$1"; shift
declare -r TTRO_workDirCase="$1"; shift
declare -r TTRO_caseVariant="$1"

#more values to setup
declare -r suite="${TTRO_inputDirSuite##*/}"
declare -r TTRO_case="${TTRO_inputDirCase##*/}"
declare -i executedTestSteps=0
declare -i executedTestPrepSteps=0
declare -i executedTestFinSteps=0

isVerbose && echo "START: execution Suite $TTRO_suite variant '$TTRO_suiteVariant' Case $TTRO_case variant '$TTRO_caseVariant'"

#
# success exit / failure exit and error exit
#
function succex {
	isVerbose && echo "**** END Case case=${TTRO_case} variant='${TTRO_caseVariant}' SUCCESS *****"
	echo "SUCCESS" > "${TTRO_workDirCase}/RESULT"
	exit 0
}
function skipex {
	isVerbose && echo "**** END Case case=${TTRO_case} variant='${TTRO_caseVariant}' SKIP **********"
	echo "SKIP" > "${TTRO_workDirCase}/RESULT"
	exit 0
}
function failex {
	isVerbose && echo "**** END Case case=${TTRO_case} variant='${TTRO_caseVariant}' FAILURE ********" >&2
	echo "FAILURE" > "${TTRO_workDirCase}/RESULT"
	exit ${errTestFail}
}
function errex {
	isVerbose && echo "END Case case=${TTRO_case} variant='${TTRO_caseVariant}' ERROR ***************" >&2
	echo "ERROR" > "${TTRO_workDirCase}/RESULT"
	exit ${errTestError}
}

isVerbose && echo "**** START Case $TTRO_case variant $TTRO_caseVariant in workdir $TTRO_workDirCase ********************"

#-----------------------------------
#setup properties and vars
setProperties "${TTRO_inputDirCase}/${TEST_CASE_FILE}"
fixPropsVars

#-------------------------------------------------
#include global, suite and case custom definitions
tmp="$TTRO_inputDir/$TEST_COLLECTION_FILE"
if [[ -r $tmp ]]; then
	isVerbose && echo "Include global test tools $tmp"
	source "$tmp"
else
	printErrorAndExit "Can nor read test collection file ${tmp}" $errScript
fi
#for x in $TTRO_tools; do
#	isVerbose && echo "Source global tools file: $x"
#	source "$x"
#done
if [[ $TTRO_suite != '--' ]]; then
	tmp="${TTRO_inputDirSuite}/${TEST_SUITE_FILE}"
	if [[ -e $tmp ]]; then
		isVerbose && echo  "Source Suite test tools file $tmp"
		source "$tmp"
	else
		printErrorAndExit "No Suite test tools file $tmp" $errScript
	fi
fi
tmp="${TTRO_inputDirCase}/${TEST_CASE_FILE}"
if [[ -e $tmp ]]; then
	isVerbose && echo  "Source Case test tools file $tmp"
	source "$tmp"
else
	printErrorAndExit "No Case test tools file $tmp" $errScript
fi

#----------------------------------
# enter working dir
cd "$TTRO_workDirCase"

#------------------------------------------------
# diagnostics
isVerbose && printTestframeEnvironment
printTestframeEnvironment > "${TTRO_workDirCase}/${TEST_ENVIRONMET_LOG}"
export >> "${TTRO_workDirCase}/${TEST_ENVIRONMET_LOG}"

#check skip
declare skipcase=""
if [[ -e "${TTRO_inputDirCase}/SKIP" ]]; then
	skipcase="true"
fi
if declare -p TTPN_skip &> /dev/null; then
	if [[ -n $TTPN_skip ]]; then
		skipcase="true"
	fi
fi
if declare -p TTPN_skipIgnore &> /dev/null; then
	if [[ -n $TTPN_skipIgnore ]]; then
		skipcase=""
	fi
fi
if [[ -n $skipcase ]]; then
	isVerbose && echo "SKIP variable set; Skip execution case=$TTRO_case variant=$TTRO_caseVariant"
	skipex
fi

#test preparation
if isExisting 'TTRO_casePrep'; then
	declare result=0
	for x in $TTRO_casePrep; do
		isVerbose && echo "Execute Case Preparation: $x"
		executedTestPrepSteps=$((executedTestPrepSteps+1))
		if eval "${x}"; then result=0; else result=$?; fi
		if [[ $result -ne 0 ]]; then
			printError "Execution of Case Preparation: ${x} failed with return code=$result"
			errex
		fi
	done
fi
isVerbose && echo "$executedTestPrepSteps Case Test Preparation steps executed"

#test execution
declare errorOccurred=""
declare failureOccurred=''
if isExisting 'TTRO_caseStep'; then
	echo "TTRO_caseStep=$TTRO_caseStep"
	for x in $TTRO_caseStep; do
		echo "x=$x"
		isVerbose && echo "Execute Case Test Step: $x"
		executedTestSteps=$((executedTestSteps+1))
		#result=0
		#eval "${x}"
		if eval "${x}"; then result=0; else result=$?; fi
		if [[ $result -eq $errTestFail ]]; then
			printError "Execution of Case Test: ${x} failed with return code=$result"
			failureOccurred="true"
			break
		elif [[ $result -ne 0 ]]; then
			printError "Execution of Case Test: ${x} error with return code=$result"
			errorOccurred="true"
			break
		fi
	done
fi
if [[ $executedTestSteps -eq 0 ]]; then
	printError "No test Case step defined"
	errorOccurred="true"
else
	isVerbose && echo "$TTRO_case:$TTRO_caseVariant - $executedTestSteps Case test steps executed"
fi

#test finalization
if isExisting 'TTRO_caseFin'; then
	declare result=0
	for x in $TTRO_caseFin; do
		isVerbose && echo "Execute Case Finalization: $x"
		executedTestFinSteps=$((executedTestFinSteps+1))
		if eval "${x}"; then result=0; else result=$?; fi
		if [[ $result -ne 0 ]]; then
			printError "Execution of Case Preparation: ${x} failed with return code=$result"
		fi
	done
fi
isVerbose && echo "$executedTestFinSteps Case Test Finalization steps executed"

if [[ -n $errorOccurred ]]; then
	errex
elif [[ -n $failureOccurred ]]; then
	failex
else
	succex
fi

:
