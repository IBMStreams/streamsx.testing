#!/bin/bash

set -o errexit; set -o nounset;

source bin/version.sh

declare -r releasdir='releases'

echo
echo "Build release package version v$TTRO_version"
echo

while read -p "Is this correct: y/e "; do
	if [[ $REPLY == "y" || $REPLY == "Y" ]]; then
		break
	elif [[ $REPLY == "e" || $REPLY == "E" ]]; then
		exit 2
	fi
done

mkdir -p "$releasdir"

fname="testframeInstaller_v${TTRO_version}.sh"

tar cvJf "$releasdir/tmp.tar.xz" bin samples README.TXT

cat tools/selfextract.sh releases/tmp.tar.xz > "$releasdir/$fname"

chmod +x "$releasdir/$fname"

rm "$releasdir/tmp.tar.xz"

echo
echo "*************************************************"
echo "Success build release package '$releasdir/$fname'"
echo "*************************************************"

exit 0
