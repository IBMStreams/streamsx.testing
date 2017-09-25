#--variantList:=success failure error scripterror
#--TTRO_caseStep:=myTestStep

function myTestStep {
	echo "Excecute $FUNCNAME variant is : $TTRO_caseVariant"
	case $TTRO_caseVariant in
		success)
			return 0 ;;
		failure)
			return $errTestFail ;;
		error)
			return 1 ;;
		scripterror)
			executewrongcommand ;;
	esac
}