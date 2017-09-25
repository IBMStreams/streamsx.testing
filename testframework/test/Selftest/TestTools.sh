###################################
# test tools for the self test
###################################

#--TTRO_testPrep:=modifyAll

# This function modifies the varname prefix and copies the code
# 1 the input file
# 2 the output file
function modifyPrefix {
	if [[ $1 == $2 ]]; then
		printErrorAndExit "$FUNCNAME: Origin and destination must be different file" $errRt
	fi
	sed -e "s/TT_/TY_/g;s/TTRO_/TYRO_/g;s/TTP_/TYP_/g;s/TTPN_/TYPN_/g" "$1" > "$2"
}

function modifyAll {
	setVar 'TTPN_binDir' "$TTRO_workDir/bin"
	mkdir "$TTPN_binDir"
	modifyPrefix "$TTPN_sourceDir/runTTF" "$TTPN_binDir/runTTF"
	modifyPrefix "$TTPN_sourceDir/defs.sh" "$TTPN_binDir/defs.sh"
	modifyPrefix "$TTPN_sourceDir/man.sh" "$TTPN_binDir/man.sh"
	modifyPrefix "$TTPN_sourceDir/manbash.sh" "$TTPN_binDir/manbash.sh"
	modifyPrefix "$TTPN_sourceDir/suite.sh" "$TTPN_binDir/suite.sh"
	modifyPrefix "$TTPN_sourceDir/case.sh" "$TTPN_binDir/case.sh"
	modifyPrefix "$TTPN_sourceDir/util.sh" "$TTPN_binDir/util.sh"
	modifyPrefix "$TTPN_sourceDir/mainutil.sh" "$TTPN_binDir/mainutil.sh"
	chmod +x "$TTPN_binDir/runTTF"
	chmod +x "$TTPN_binDir/suite.sh"
	chmod +x "$TTPN_binDir/case.sh"
}