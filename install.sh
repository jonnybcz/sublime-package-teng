#!/bin/bash +x

function _copy() {
	ARGS="";
	case $# in
		2) TARGET="$1"; LINK_NAME="$2"; ;;
		3) ARG="$1"; TARGET="$2"; LINK_NAME="$3"; ;;
		*) echo "Bad arguments"; return 1; ;;
	esac
	echo -n " ${TARGET}";
	cp -rf "$TARGET" "$LINK_NAME" > /dev/null;
	if [ $? -eq 0 ] ; then
		 echo -e " \e[0;92m[OK]\e[0m";
	else 
		 echo -e " \e[0;91m[fail]\e[0m";
	fi
}

function maintainer() {
	echo -e "Maintainer: \e[38;5;208mFilip Mösner\e[0m <\e[30;38;5;208mfilip.mosner@firma.seznam.cz\e[0m>";
	if [ ! -z $1 ]; then
		exit $1;
	fi
}

# zjištění absolutní cesty k souboru, fční i pro OSX
function realpath() {
	[[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}


DIRS=("$HOME/.config/sublime-text-2/" "$HOME/.config/sublime-text-3/" "$HOME/Library/Application Support/Sublime Text 2/");
PACKAGE_DIR="Packages/";
PACKAGES=("HTML" "JavaScript" "Teng");
SCRIPT_DIR=$(dirname $(realpath $0))/;



# Kontrola již existujících uživatelských šablon (balíčků)
echo "Copying files..."
NO_COPIED=1;
for ((i = 0; i < ${#DIRS[@]}; i++))
do
	DIR="${DIRS[$i]}";
	for ((j = 0; j < ${#PACKAGES[@]}; j++))
	do
	PACKAGE="${PACKAGES[$j]}";
		PACKAGE_NEW_DIR="${DIR}${PACKAGE_DIR}";
		PACKAGE_TARGET_DIR="${SCRIPT_DIR}${PACKAGE_DIR}${PACKAGE}";
		if [ -d "${PACKAGE_NEW_DIR}" ]; then
			if [ "$1" == "-f" ]; then
				rm -r "${PACKAGE_NEW_DIR}${PACKAGE}";
			fi
			if [ -d "${PACKAGE_NEW_DIR}${PACKAGE}" ]; then
				# Chceme provadet kontrolu balicku?
				read -p "User package ${PACKAGE_NEW_DIR}${PACKAGE} exists, do you want overwrite? (Y/n): " YN
				if [ -z $YN ] || [ $YN == "y" ] || [ $YN == "Y" ]; then
					_copy "${PACKAGE_TARGET_DIR}" "${PACKAGE_NEW_DIR}";
				fi
			else
				_copy "${PACKAGE_TARGET_DIR}" "${PACKAGE_NEW_DIR}";			
			fi
			NO_COPIED=0;
		fi
	done
done

if [ $NO_COPIED -eq 1 ]; then
	echo "!! no files copied";
fi

echo "done";

# restart sublime
TMPFILE=$(mktemp XXXXXX.tmp);
ps -e > $TMPFILE;
SUBL_PIDS=$(cat $TMPFILE | grep "subl" | sed "s;^[^0-9]*\([0-9]\+\).*;\1;");
if [ "$SUBL_PIDS" != "" ]; then
	YN="Y";
	if [ "$1" != "-f" ]; then
		read -p "Do you want restart sublime-text? (Y/n): " YN;
	fi
	if [ -z $YN ] || [ $YN == "y" ] || [ $YN == "Y" ]; then
		echo -n "Restarting sublime-text...";
		for PID in $SUBL_PIDS
		do
			APP=$(ps -p ${PID} -o args=);
			kill -9 $PID > /dev/null;
			"$APP";
		done
		echo " done";
	fi
fi
rm $TMPFILE;

maintainer
