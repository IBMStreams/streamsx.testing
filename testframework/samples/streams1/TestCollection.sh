##-----------the properties and varaiables part ---------------------------------

#Put here the test preparation steps whith noticable runtime effects

##-----------the script part -----------------------------------------------------
# The initialization section should contain all
# actions which are imediately executed during test collection, test suite and test case initialization

# source all necesary tool collections
source "$TTRO_scriptDir/streamsutils.sh"

setVar 'TTPN_streamsInetToolkit' "$STREAMS_INSTALL/toolkits/com.ibm.streamsx.inet"
setVar 'TT_toolkitPath' "$TTPN_streamsInetToolkit" #consider more than one tk...

# Function definitions for this test collection