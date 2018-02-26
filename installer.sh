#!/bin/sh

mkdir -p ~/.config/hey/reports
INSTALLER_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cp -r $INSTALLER_DIR/starter_files/* ~/.config/hey/

echo "---------------------------------------------------------------"
echo "Where should I install the hey cli tool? "
echo "Here are all the writable directories on your PATH:"

arrPATH=(${PATH//:/ })
count=0
for i in "${arrPATH[@]}"
do
	if [ -w "$i" ]; then
	  count=$((count+1))
	  echo "$count: $i" 
	fi
done
echo ""
echo "Which one would you like the cli tool installed in? [number]: "
read number

arrPATH=(${PATH//:/ })
count=0
installed=0
for i in "${arrPATH[@]}"
do
	if [ -w "$i" ]; then
		count=$((count+1))
		if [ "$count" = "$number" ]; then
			echo "installing hey cli tool in $i"

			cp "$INSTALLER_DIR/starter_files/hey" "$i/hey"
			chmod 755 "$i/hey"

			installed=1
		fi
	fi
	# echo "$count: $i" 
done
if [ $installed -eq 0 ]; then
	echo "um... you didn't enter a number I recognized."
	echo "Please start over, you silly human."
	exit 2
else
	echo "Ready to go, boss!"
	echo "run hey with no arguments to get started"
fi

