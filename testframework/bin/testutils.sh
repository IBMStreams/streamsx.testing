######################################################
# Utilities for testframework test
#
######################################################

TTRO_help_useCpu="
# Function useCpu
#	use one core for a number of seconds
#	\$1 the number seconds this function runs
#	\$2 an id to print
#	\$3 if true the function returns 11"
function useCpu {
	if [[ $# -ne 3 ]]; then
		printErrorAndExit "$FUNCNAME needs 3 arguments" ${errRt}
	fi

	local myId="$2"
	local -i myDuration="$1"
	local errorex="$3"

	echo "START $FUNCNAME myDuration=$1 id=$myId"
	local -i t1=$(date '+%s')
	local -i t2=$((t1 + myDuration))
	local -i tx=0
	while ((tx < t2)); do
		local -i x=100000;
		while let x=x-1; do
		:
		done;
		#echo "******* "
		tx=$(date '+%s')
		#echo $tx
	done
	if [[ $errorex == "true" ]]; then
		echo "END $FUNCNAME id=$myId Failure emulated"
		return 11
	else
		echo "END $FUNCNAME id=$myId Success emulated"
		return 0
	fi
}

:
