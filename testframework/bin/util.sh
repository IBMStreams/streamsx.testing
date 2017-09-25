######################################################
# Utilities for testframework
#
######################################################

TTRO_help_printErrorAndExit="
# Function printErrorAndExit
# 	prints an error message and exits
#	\$1 the error message to print
#	\$2 the exit code"
function printErrorAndExit {
	printError "$1"
	exit $2
}

TTRO_help_printError="
# Function printError
#	prints an error message
#	\$1 the error message to print"
function printError {
	echo -e "\033[31mERROR: $1\033[0m" >&2
	local -i depth=${#FUNCNAME[@]}
	local -i i
	for ((i=depth-2; i>=0; i--)); do
		caller $i
	done
}

TTRO_help_printWarning="
# Function printWarning
#	prints an warning message
#	\$1 the warning to print"
function printWarning {
	echo -e "\033[33mWARNING: $1\033[0m" >&2
}

TTRO_help_printDebug="
# Function printDebug
#	prints debug info
#	\$1 the debug info to print"
function printDebug {
	local -i i
	local stackInfo=''
	local dd=$(date "+%T %N")
	for ((i=${#FUNCNAME[@]}-1; i>0; i--)); do
		stackInfo="$stackInfo ${FUNCNAME[$i]}"
	done
	echo -e "\033[32m$dd DEBUG: ${commandname}${stackInfo}: ${1}\033[0m"
}

TTRO_help_printDebugn="
# Function printDebugn
#	prints debug info without newline
#	\$1 the debug info to print"
function printDebugn {
	local -i i
	local stackInfo=''
	local dd=$(date "+%T %N")
	for ((i=${#FUNCNAME[@]}-1; i>0; i--)); do
		stackInfo="$stackInfo ${FUNCNAME[$i]}"
	done
	echo -en "\033[32m$dd DEBUG:${commandname}${stackInfo}: ${1}\033[0m"
}

TTRO_help_isDebug="
# Function isDebug
# 	returns true if debug is enabled"
function isDebug {
	if [[ -n $TTPN_debug && -z $TTPN_debugDisable ]]; then
		return 0	# 0 is true in bash
	else
		return 1
	fi
}

TTRO_help_isVerbose="
# Function isVerbose
#	returns true if verbose is enabled"
function isVerbose {
	if [[ ( -n $TTPN_verbose && -z $TTPN_verboseDisable ) || (-n $TTPN_debug && -z $TTPN_debugDisable) ]]; then
		return 0
	else
		return 1
	fi
}

TTRO_help_printTestframeEnvironment="
# Function printTestframeEnvironment
# print special testrame environment"
function printTestframeEnvironment {
	echo "**** Testframe Environment ****"
	local x
	for x in "${!TT_@}"; do
		echo "${x}='${!x}'"
	done
	for x in "${!TTRO_@}"; do
		if [[ $x != TTRO_help* ]]; then
			echo "${x}='${!x}'"
		fi
	done
	for x in "${!TTP_@}"; do
		echo "${x}='${!x}'"
	done
	for x in "${!TTPN_@}"; do
		echo "${x}='${!x}'"
	done
	echo "PWD=$PWD"
	echo "*******************************"
}

TTRO_help_splitVarValue='
# Function splitVarValue
#	Split an line #*#varname=value into the components
#	and           #*#varname:=value
#
#	Ignore all other lines
#	ignore empty lines and lines with only spaces
#	varname must not be empty and must not contain any blank characters
#	$1 the input line (only one line without nl)
#	returns varname
#		 value
#        splitter
# returns true in case of success false otherwise'
function splitVarValue {
	isDebug && printDebug "$FUNCNAME \$1='$1'"
	if [[ $1 == \#--* ]]; then
		local tmp=${1#*#--}
		if [[ -n $tmp && (${tmp//[[:blank:]]/} != "" ) ]]; then
			local value1=${tmp#*:=}
			local name1=${tmp%%:=*}
			#echo "name1=$name1 value1=$value1"
			if [[ $value1 != $tmp && $name1 != $tmp ]]; then #there was something removed -> there was a =
				splitter=':='
			else
				value1=${tmp#*=}
				name1=${tmp%%=*}
				if [[ $value1 != $tmp && $name1 != $tmp ]]; then #there was something removed -> there was a :=
					splitter='='
				else
					printError "$FUNCNAME: No '=' in special comment line '$1' Ignored"
					return 1
				fi
			fi
			#if [[ $tmp =~ (.*)=(.*) ]]; then problem if more tah one = in line
			#	local name1=${BASH_REMATCH[1]}
			#	local value1=${BASH_REMATCH[2]}
			if [[ -n $name1 && ! ( $name1 =~ [[:blank:]] ) ]] ; then
				varname="$name1"
				value="$value1"
				return 0
			else
				printError "$FUNCNAME: Varname contains blanks in special comment line '$1' Ignored"
				return 1
			fi
		else
			return 1
		fi
	else
		return 1
	fi
}

#
# Read a test case or a test suite file and extracts the variables
# variantCount and variantList and conditional the type; ignore the rest
# $1 is the filename to read
# return 0 in success case
# exits with ${errRt} if an invalid line was read;
# results are returned in global variables variantCount; variantList
function readVariantFile {
	isDebug && printDebug "$FUNCNAME $1"
	if [[ ! -r $1 ]]; then
		printErrorAndExit "${FUNCNAME} : Can not open file=$1 for read" ${errRt}
	fi
	variantCount=""; variantList=""; splitter=""
	declare -i lineno=1
	{
		local varname=
		local value=
		local result=0
		while [[ result -eq 0 ]]; do
			if ! read -r; then result=1; fi
			if [[ ( result -eq 0 ) || ( ${#REPLY} -gt 0 ) ]]; then #do not eval the last and empty line
				if splitVarValue "$REPLY"; then
					if [[ -n $varname ]] ; then
						isDebug && printDebug "$FUNCNAME prepare for variant encoding varname=$varname value=$value"
						case $varname in
							variantCount )
								if ! variantCount="${value}"; then
									printErrorAndExit "${FUNCNAME} : Invalid value in file=$1 line=$lineno '$REPLY'" ${errRt}
								fi
								isVerbose && echo "variantCount='${variantCount}'"
							;;
							variantList )
								if ! variantList="${value}"; then
									printErrorAndExit "${FUNCNAME} : Invalid value in file=$1 line=$lineno '$REPLY'" ${errRt}
								fi
								isVerbose && echo "variantList='${variantList}'"
							;;
							TT_timeout )
								if ! TT_timeout="${value}"; then
									printErrorAndExit "${FUNCNAME} : Invalid value in file=$1 line=$lineno '$REPLY'" ${errRt}
								fi
								isVerbose && echo "TT_timeout='${TT_timeout}'"
							;;
							TT_extraTime )
								if ! TT_extraTime="${value}"; then
									printErrorAndExit "${FUNCNAME} : Invalid value in file=$1 line=$lineno '$REPLY'" ${errRt}
								fi
								isVerbose && echo "TT_extraTime='${TT_extraTime}'"
							;;
							* )
								#other property or variable
								isDebug && printDebug "${FUNCNAME} : Ignore varname='$varname' in file $1 line=$lineno"
							;;
						esac
					else
						printErrorAndExit "${FUNCNAME} : Invalid line or property name in case or suitefile file=$1 line=$lineno '$REPLY'" ${errRt}
					fi
				else
					isDebug && printDebug "Ignore line file=$1 line=$lineno '$REPLY'"
				fi
				lineno=$((lineno+1))
			fi
		done
	} < "$1"
	return 0
}

# prepares the properties and readonly properties for the export and sets all variables
# read from the testcase/suite file
# expects that fixPropsVars is called afer
# outputs the variables
# input $1 : must be the filename
function setProperties {
	isDebug && printDebug "$FUNCNAME $1"
	if [[ ! -r $1 ]]; then
		printErrorAndExit "${FUNCNAME} : Can not open file=$1 for read" ${errRt}
	fi
	declare -i lineno=1
	{
		local varname="" value="" splitter=""
		local result=0 internalResult=0
		while [[ result -eq 0 ]]; do
			if ! read -r; then result=1; fi
			if [[ ( result -eq 0 ) || ( ${#REPLY} -gt 0 ) ]]; then #do not eval the last and empty line
				if splitVarValue "$REPLY"; then
					if [[ -n $varname ]] ; then
						isDebug && printDebug "$FUNCNAME prepare for export varname=$varname value=$value splitter=$splitter"
						case $varname in
							TTPN_* )
								#set property only if it is unset or null
								if ! declare -p ${varname} &> /dev/null || [[ -z ${!varname} ]]; then
									if [[ $splitter == ":=" ]]; then
										if eval export \'${varname}\'='"${value}"'; then internalResult=0; else internalResult=1; fi
									else
										if eval export \'${varname}\'="${value}"; then internalResult=0; else internalResult=1; fi
									fi
									if [[ $internalResult -ne 0 ]]; then
										printErrorAndExit "${FUNCNAME} : Invalid expansion in case- or suit-efile file=$1 line=$lineno varname=${varname} value=${value} '$REPLY'" ${errRt}
									else
										isVerbose && echo "${varname}='${!varname}'"
									fi
								else
									isVerbose && echo "$FUNCNAME ignore value for ${varname} in file=$1 line=$lineno"
								fi
							;;
							TTP_* )
								#set property only if it is unset
								if ! declare -p "${varname}" &> /dev/null; then
									if [[ $splitter == ":=" ]]; then
										if eval export \'${varname}\'='"${value}"'; then internalResult=0; else internalResult=1; fi
									else
										if eval export \'${varname}\'="${value}"; then internalResult=0; else internalResult=1; fi
									fi
									if [[ $internalResult -ne 0 ]]; then
										printErrorAndExit "${FUNCNAME} : Invalid expansion in case- or suite-file file=$1 line=$lineno varname=${varname} value=${value} '$REPLY' file=$1" ${errRt}
									else
										isVerbose && echo "${varname}='${!varname}'"
									fi
								else
									isVerbose && echo "$FUNCNAME ignore value for ${varname} in file=$1 line=$lineno"
								fi
							;;
							TTRO_* )
								#set a global readonly variable
								if [[ $splitter == ":=" ]]; then
									if eval export \'${varname}\'='"${value}"'; then internalResult=0; else internalResult=1; fi
								else
									if eval export \'${varname}\'="${value}"; then internalResult=0; else internalResult=1; fi
								fi
								if [[ $internalResult -ne 0 ]]; then
									printErrorAndExit "${FUNCNAME} : Invalid expansion in case- or suite-file file=$1 line=$lineno varname=${varname} value=${value} '$REPLY' file=$1" ${errRt}
								else
									isVerbose && echo "${varname}='${!varname}'"
								fi
							;;
							TT_* )
								#set a global variable
								if [[ $splitter == ":=" ]]; then
									if eval export \'${varname}\'='"${value}"'; then internalResult=0; else internalResult=1; fi
								else
									if eval export \'${varname}\'="${value}"; then internalResult=0; else internalResult=1; fi
								fi
								if [[ $internalResult -ne 0 ]]; then
									printErrorAndExit "${FUNCNAME} : Invalid expansion in case- or suite-file file=$1 line=$lineno varname=${varname} value=${value} '$REPLY' file=$1" ${errRt}
								else
									isVerbose && echo "${varname}='${!varname}'"
								fi
							;;
							variantCount|variantList )
								#ignore test variant variables
								isDebug && printDebug "Ignore $varname in file=$1 line=$lineno"
							;;
							* )
								#other variables
								printErrorAndExit "${FUNCNAME} : Invalid property or variable in case- or suite-file file=$1 line=$lineno varname=${varname} value=${value} '$REPLY' file=$1" ${errRt}
							;;
						esac
					else
						printErrorAndExit "${FUNCNAME} : Invalid line or property name in case- or suite-file file=$1 line=$lineno '$REPLY'" ${errRt}
					fi
				else
					isDebug && printDebug "Ignore line file=$1 line=$lineno '$REPLY'"
				fi
				lineno=$((lineno+1))
			fi
		done
	} < "$1"
}

TTRO_help_fixPropsVars='
# Function fixPropsVars
#	This function fixes all ro-variables and propertie variables after process start
#	Property and variables setting is a two step action:
#	Unset hep variables if no reference is printed
#	$1:  setProperties <filename>
#	$2: fixPropsVars'
function fixPropsVars {
	local var=""
	if [[ -z $TTRO_reference ]]; then
		for var in "${!TTRO_help@}"; do
			unset "$var"
		done
	fi
	for var in "${!TT_@}"; do
		isDebug && printDebug "${FUNCNAME} : TT_   $var=${!var}"
		export "${var}"
	done
	for var in "${!TTRO_@}"; do
		isDebug && printDebug "${FUNCNAME} : TTRO_ $var=${!var}"
		readonly "${var}"
		export "${var}"
	done
	for var in "${!TTP_@}"; do
		isDebug && printDebug "${FUNCNAME} : TTP_  $var=${!var}"
		readonly "${var}"
		export "${var}"
	done
	for var in "${!TTPN_@}"; do
		isDebug && printDebug "${FUNCNAME} : TTPN_ $var=${!var}"
		readonly "${var}"
		export "${var}"
	done
}

TTRO_help_setVar='
# Function setVar
#	Set framework variable at runtime
#	$1 - the name of the variable to set
#	$2 - the value'
function setVar {
	if [[ $# -ne 2 ]]; then printErrorAndExit "$FUNCNAME missing params. Number of Params is $#" $errRt; fi
	isDebug && printDebug "$FUNCNAME $1 $2"
	case $1 in
		TTPN_* )
			#set property only if it is unset or null an make it readonly
			if ! declare -p ${1} &> /dev/null || [[ -z ${!1} ]]; then
				if ! eval export \'${1}\'='"${2}"'; then
					printErrorAndExit "${FUNCNAME} : Invalid expansion in varname=${1} value=${2}" ${errRt}
				else
					isVerbose && echo "${FUNCNAME} : ${1}='${!1}'"
				fi
				readonly ${1}
			else
				isVerbose && echo "$FUNCNAME ignore value for ${1}"
			fi
		;;
		TTP_* )
			#set property only if it is unset an make it readonly
			if ! declare -p "${1}" &> /dev/null; then
				if ! eval export \'${1}\'='"${2}"'; then
					printErrorAndExit "${FUNCNAME} : Invalid expansion varname=${1} value=${2}" ${errRt}
				else
					isVerbose && echo "${FUNCNAME} : ${1}='${!1}'"
				fi
				readonly ${1}
			else
				isVerbose && echo "$FUNCNAME ignore value for ${1} in file=$1 line=$lineno"
			fi
		;;
		TTRO_* )
			#set a global readonly variable
			if ! eval export \'${1}\'='"${2}"'; then
				printErrorAndExit "${FUNCNAME} : Invalid expansion varname=${1} value=${2}" ${errRt}
			else
				isVerbose && echo "${FUNCNAME} : ${1}='${!1}'"
			fi
			readonly ${1}
		;;
		TT_* )
			#set a global variable
			if ! eval export \'${1}\'='"${2}"'; then
				printErrorAndExit "${FUNCNAME} : Invalid expansion varname=${1} value=${2}" ${errRt}
			else
				isVerbose && echo "${FUNCNAME} : ${1}='${!1}'"
			fi
		;;
		* )
			#other variables
			printErrorAndExit "${FUNCNAME} : Invalid property or variable varname=${1} value=${2}" ${errRt}
		;;
	esac
	:
}

TTRO_help_isExisting='
# Function isExisting
#	check if variable exists
#	$1 var name to be checked'
function isExisting {
	if declare -p "${1}" &> /dev/null; then
		isDebug && printDebug "$FUNCNAME $1 return 0"
		return 0
	else
		isDebug && printDebug "$FUNCNAME $1 return 1"
		return 1
	fi
}

TTRO_help_isNotExisting='
# Function isNotExisting
#	check if variable not exists
#	$1 var name to be checked'
function isNotExisting {
	if declare -p "${1}" ; then
		isDebug && printDebug "$FUNCNAME $1 return 1"
		return 1
	else
		isDebug && printDebug "$FUNCNAME $1 return 0"
		return 0
	fi
}

TTRO_help_copyAndTransform='
# Function copyAndTransform
#	Copy and change all files from input dirextory into workdir
#	Filenames that match one of the transformation pattern are transformed. All other files are copied.
#	In case of transformation the pattern //_<varid> is removed if varid equals $3
#	In case of transformation the pattern //!<varid> is removed if varid is different than $3
#	If the variant identifier is empty, the pattern list sould be also empty and the function is a pure copy function
#	If $3 is empty and $4 .. do not exist, this function is a pure copy
#	$1 - input dir
#	$2 - output dir
#	$3 - the variant identifier
#	$4 ... pattern for file names to be transformed'
function copyAndTransform {	
	if [[ $# -lt 3 ]]; then printErrorAndExit "$FUNCNAME missing params. Number of Params is $#" $errRt; fi
	isDebug && printDebug "$FUNCNAME $*"
	if [[ -z $3 && ( $# -gt 3 ) ]]; then
		printWarning "$FUNCNAME: Empty variant identifier but there are pattern for file transformation"
	fi
	local -a transformPattern=()
	local -i max=$(($#+1))
	local -i j=0
	local -i i
	for ((i=4; i<max; i++)); do
		transformPattern[$j]="${!i}"
		j=$((j+1))
	done
	if isDebug; then
		local display=$(declare -p transformPattern);
		printDebug "$display"
	fi
	local dest=""
	for x in $1/**; do #first create dir structure
		isDebug && printDebug "$FUNCNAME item to process step1: $x"
		if [[ -d $x ]]; then
			dest="${x#$1}"
			dest="$2/$dest"
			echo $dest
			if isVerbose; then 
				mkdir -pv "$dest"
			else
				mkdir -p "$dest"
			fi
		fi
	done
	local match=0
	local x
	for x in $1/**; do
		isDebug && printDebug "$FUNCNAME item to process step2: $x"
		if [[ ! -d $x ]]; then
			for ((i=0; i<${#transformPattern[@]}; i++)); do
				isDebug && printDebug "$FUNCNAME: check transformPattern[$i]=${transformPattern[$i]}"
				match=0
				if [[ $x == ${transformPattern[$i]} ]]; then
					isDebug && printDebug "$FUNCNAME: check transformPattern[$i]=${transformPattern[$i]} Match found"
					match=1
				fi
			done
			dest="${x#$1}"
			dest="$2/$dest"
			if [[ match -eq 1 ]]; then
				isVerbose && echo "transform $x to $dest"
				#if ! sed -e "s/\/\/*_${3}//g" "$x" > "$dest"; then
				#	printErrorAndExit "$FUNCNAME Can not transform input=$x dest=$dest variant=$4" $errRt
				#fi
				{
					local readResult=0
					local outline part1 part2 partx
					while [[ $readResult -eq 0 ]]; do
						if ! read -r; then readResult=1; fi
						part1="${REPLY%%//_$3_*}"
						if [[ $part1 != $REPLY ]]; then
							#isDebug && printDebug "$FUNCNAME: match line='$REPLY'"
							part2="${REPLY#*//_$3_}"
							#isDebug && printDebug "$FUNCNAME: part1='$part1'"
							#isDebug && printDebug "$FUNCNAME: part2='$part2'"
							outline="${part1}${part2}"
						else
							part1="${REPLY%%//\!*_*}"
							if [[ $part1 != $REPLY ]]; then
								#isDebug && printDebug "$FUNCNAME: 2nd match line='$REPLY'"
								partx="${REPLY%%//\!$3_*}"
								if [[ $partx != $REPLY ]]; then
									#isDebug && printDebug "$FUNCNAME: negative match line='$REPLY' '$partx'"
									outline="$REPLY"
								else
									part2="${REPLY#*//\!*_}"
									#isDebug && printDebug "$FUNCNAME: part1='$part1'"
									#isDebug && printDebug "$FUNCNAME: part2='$part2'"
									outline="${part1}${part2}"
								fi
							else
								#isDebug && printDebug "$FUNCNAME: no match line='$REPLY'"
								outline="$REPLY"
							fi
						fi
						if [[ $readResult -eq 0 ]]; then
							echo "$outline" >> "$dest"
						else
							echo -n "$outline" >> "$dest"
						fi
					done
				} < "$x"
			else
				if isVerbose; then
					cp -pv "$x" "$dest"
				else
					cp -p "$x" "$dest"
				fi
			fi
		fi
	done
	return 0
}

TTRO_help_copyOnly='
# Function copyOnly
#	Copy all files from input directory to workdir'
function copyOnly {
	copyAndTransform "$TTRO_inputDirCase" "$TTRO_workDirCase" "$TTRO_caseVariant"
}

TTRO_help_linewisePatternMatch='
# Function linewisePatternMatch
#	Line pattern validator
#	$1 - the input file
#	$2 - if set to "true" all pattern must generate a match
#	$3 .. - the pattern to match all pattern are or
#	return true if file exist and one or all patten matches
#	return false if no complete pattern match was found or the file not exists'
declare -a patternList=()
function linewisePatternMatch {
	if [[ $# -lt 3 ]]; then printErrorAndExit "$FUNCNAME missing params. Number of Params is $#" $errRt; fi
	isDebug && printDebug "$FUNCNAME $*"
	local -i max=$#
	local -i i
	local -i noPattern=0
	for ((i=3; i<=max; i++)); do
		patternList[$noPattern]="${!i}"
		noPattern=$((noPattern+1))
	done
	if linewisePatternMatchArray "$1" "$2"; then
		return 0
	else
		return $?
	fi
}

TTRO_help_linewisePatternMatchArray='
# Function linewisePatternMatchArray
#	Line pattern validator with array input variable
#	$1 - the input file
#	$2 - if set to "true" all pattern must generate a match
#	the pattern to match as array 0..n are expected to be in patternList array variable
#	return true if file exist and one or all patten matches
#	return false if no complete pattern match was found or the file not exists'
function linewisePatternMatchArray {
	if [[ $# -ne 2 ]]; then printErrorAndExit "$FUNCNAME invalid no of params. Number of Params is $#" $errRt; fi
	isDebug && printDebug "$FUNCNAME $*"
	local -i i
	local -i noPattern=${#patternList[@]}
	local -a patternMatched=()
	for ((i=0; i<$noPattern; i++)); do
		patternMatched[$i]=0
	done
	if isDebug; then
		local display=$(declare -p patternList);
		printDebug "$display"
	fi
	if [[ -f $1 ]]; then
		local -i matches=0
		local -i line=0
		{
			local result=0;
			line=0
			while [[ result -eq 0 ]]; do
				if ! read -r; then result=1; fi
				if [[ ( result -eq 0 ) || ( ${#REPLY} -gt 0 ) ]]; then
					line=$((line+1))
					isDebug && printDebug "$REPLY"
					for ((i=0; i<$noPattern; i++)); do
						if [[ patternMatched[$i] -eq 0 && $REPLY == ${patternList[$i]} ]]; then
							patternMatched[$i]=1
							matches=$((matches+1))
							echo "$FUNCNAME : Pattern='${patternList[$i]}' matches line=$line in file=$1"
							if [[ -z $2 ]]; then
								break 2
							fi
						fi
						if [[ $matches -eq $noPattern ]]; then
							break 2
						fi
					done
				fi
			done
		} < "$1"
		if [[ $2 == 'true' ]]; then
			if [[ $matches -eq $noPattern ]]; then
				echo "$FUNCNAME : $matches matches found in file=$1"
				return 0
			else
				local display=$(declare -p patternList)
				echo "$FUNCNAME : Only $matches of Pattern=$display matches in file=$1"
				return $errTestFail
			fi
		else
			if [[ $matches -gt 0 ]]; then
				echo "$FUNCNAME : One matche found in file=$1"
				return 0
			else
				local display=$(declare -p patternList)
				echo "$FUNCNAME : None of Pattern=$display matches in file=$1"
				return $errTestFail
			fi
		fi
	else
		echo "$FUNCNAME: can not open file $1"
		return $errTestFail
	fi
}

TTRO_help_echoAndExecute='
# Function echoAndExecute
#	echo and execute a command
#	varargs
#	$1 the command string
#	$2 the parameters as one string - during execution expansion and word splitting is applied'
function echoAndExecute {
	echo "${FUNCNAME[1]}: $*"
	eval echo "${FUNCNAME[1]}: $*"
	eval "$*"
}

#Guard for the last statement because source testutils will fail if TTPN_debug is not set ??
:
