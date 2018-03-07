#!/bin/bash

# ###############################################################
# Package generation from git repository
#
# Authors       Mathieu Marleix
#
# Last update   2018/06/02
#
# Version       2.0
#
# Changelog
# ---------------------------------------------------
#
# 2018/02/06	Second version
# 2017/12/01	First version
#
# ###############################################################

# -------- Global Vars definition --------------- #
# Colors
ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;01m"
COL_GREEN=$ESC_SEQ"32;01m"
COL_YELLOW=$ESC_SEQ"33;01m"
COL_BLUE=$ESC_SEQ"34;01m"
COL_MAGENTA=$ESC_SEQ"35;01m"
COL_CYAN=$ESC_SEQ"36;01m"

# Tags
DEBUG_TAG="$COL_GREEN[DEBUG]$COL_RESET"
ERROR_TAG="$COL_RED[ERROR]$COL_RESET"
STATUS_TAG="$COL_BLUE[STATUS]$COL_RESET"

# -------- Functions definition --------------- #
# Get script location path
function get_script_location(){
	SOURCE="${BASH_SOURCE[0]}"
	while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
	  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
	  SOURCE="$(readlink "$SOURCE")"
	  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
	done
	DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
	if [  "$DIR" != "" ] ; then
		echo $DIR
		return 0
	else
		return 1
	fi
}
# Display the help
function usage(){
        [[ $@ ]] && echo -e >&2 "$@"
echo -e "${COL_BLUE}Usage:$COL_RESET
    $0 -o {DEBIAN|RHEL} -a {32|64} -c {<configuration_file>}-d {<directory_file>}
${COL_BLUE}Arguments:$COL_RESET
    - a|architecture)	Architecture of the output package (32|64)
    - o|os)		Destination OS of the package (DEBIAN|RHEL)
    - c|config)         Path to a configuration file  
    - d|directory)      Path to a directory file
${COL_BLUE}Options:$COL_RESET
    - h|help|\?)	Display this help
    - D|dependencies)   Path to a dependency file
    - f|fpm)   		Path to a file with option passed to FPM
    - b|branch)		A list of branch formatted as 'project:branch1,project2,branch1'
${COL_BLUE}Informations:$COL_RESET
    This script is used to generate a package from
    a GIT repository.
${COL_BLUE}Configuration file:$COL_RESET
    The configuration file is used to import
    configuration variable.
    The syntax of a line is:
    VAR_NAME=\"VAR_VALUE\"

    The following variable are needed by the script:
	PACKAGE_NAME
	VENDOR	
	LICENSE
	MAINTAINER
	URL
	VERSION_DIR
	CLONE_URL
   The output can be changed by setting:
	OUTPUT_DIR

   An example can be found under configuration/build.conf
${COL_BLUE}Directory file:$COL_RESET
   This file link the source directories with the package
   output directories, it tell FPM where place your software.
   
   The syntax used is SOURCE_DIR=DESTINATION_DIR

   An example can be found under configuration/directory.conf
${COL_BLUE}Dependency file:$COL_RESET
   This file list the dependencies needed by the generated
   package, one on each line.

   An example can be found under configuration/debian.deps
${COL_BLUE}FPM Options file:$COL_RESET
   This file can allow to pass options to FPM during the build.
   Each option should be one line.

   An example can be found under configuration/fpm.conf
"
}
# Check parameters definition
function verify_parameters(){
	if [ -z ${OS} ]; then
		echo -e "$ERROR_TAG OS must be defined!";
		usage;
		exit 1;
	fi
	if [ -z ${ARCH} ]; then
		echo -e "$ERROR_TAG ARCH must be defined!";
		usage;
		exit 3;
	fi
	if [ -z "${CONFIG_FILE}" ] && [ -r "${CONFIG_FILE}" ]; then
		echo -e "$ERROR_TAG Configuration file must be defined and readable!";
		usage;
		exit 4;
	fi
	if [ -z "${OUTPUT_FPM_DIR_FILE}" ] && [ -r "${OUTPUT_FPM_DIR_FILE}" ]; then
		echo -e "$ERROR_TAG Output directories file must be defined and readable!";
		usage;
		exit 4;
	fi
	if [ ! -z "${DEPS_FILE}" ] && [ ! -r "${DEPS_FILE}" ]; then
		echo -e "$ERROR_TAG Dependancies file must be defined and readable!";
		usage;
		exit 4;
	fi
}
function source_configuration_file(){
	CONFIG=$1
	CONFIG_SYNTAX="^\s*#|^\s*$|^[a-zA-Z_]+=[\"][^\"]*[\"]$"

	# check if the file contains something we don't want
	if egrep -q -v ${CONFIG_SYNTAX} $CONFIG; then
		echo "Error parsing config file ${CONFIG}." >&2
		echo "The following lines in the configfile do not fit the syntax:" >&2
		egrep -vn "${CONFIG_SYNTAX}" "$CONFIG"
		exit 5
	fi
	echo -e "Sourcing configuration file:"
	source $CONFIG
	if [ $? -eq 0 ] ; then echo "[OK]"; else echo "[NOK]";exit 5; fi
}
# Check config definition
function verify_configuration(){
	if [ -z "${PACKAGE_NAME}" ]; then
		echo -e "$ERROR_TAG Package name must be defined!";
		usage;
		exit 1;
	fi
	if [ -z "${VENDOR}" ]; then
		echo -e "$ERROR_TAG Vendor must be defined!";
		usage;
		exit 1;
	fi
	if [ -z "${LICENSE}" ]; then
		echo -e "$ERROR_TAG License must be defined!";
		usage;
		exit 1;
	fi
	if [ -z "${MAINTAINER}" ]; then
		echo -e "$ERROR_TAG Maintainer name & mail must be defined!";
		usage;
		exit 1;
	fi
	if [ -z "${URL}" ]; then
		echo -e "$ERROR_TAG Package URL must be defined!";
		usage;
		exit 1;
	fi
	if [ -z "${PACKAGE_NAME}" ]; then
		echo -e "$ERROR_TAG Package name must be defined!";
		usage;
		exit 1;
	fi
	if [ -z "${VERSION_DIR}" ]; then
		echo -e "$ERROR_TAG Version directory must be defined!";
		usage;
		exit 1;
	fi
	if [ -z "${CLONE_URL}" ]; then
		echo -e "$ERROR_TAG Repository URL(s) to clone must be defined!";
		usage;
		exit 1;
	fi
	if [ -z "${OUTPUT_DIR}" ]; then
		echo -e "$ERROR_TAG Output directory not specified, using /tmp";
		OUTPUT_DIR="/tmp"
	fi
}
# Generate the dependency list for FPM from a given file
# Args:		$1	DEPENDENCIES_FILE
# Return:	$DEPS	List of dependencies to use during the build
function generate_dependencies(){
	DEPS='';
	for dep in $(egrep -v '^\s*#|^\s*$' $1|tr '\n' ' ') ; do 
		DEPS+="--depends $dep "; 
	done
	echo $DEPS
}
# Generate the option to pass to FPM
# Args:		$1		OPTIONS_FILE
# Return:	$FPM_OPTIONS	List of options to use during the build
function generate_fpm_options(){
	FPM_OPTIONS='';
	for options in $(egrep -v '^\s*#|^\s*$' $1|tr '\n' ' ') ; do 
		FPM_OPTIONS+="$options "; 
	done
	echo $FPM_OPTIONS
}
# Generate the directory list for FPM from a given file
# Args:		$1		DIRECTORIES_FILE
# Return:	$OUTPUT_FPM_DIR	List of directories to include in the build
function generate_directories(){
	OUTPUT_FPM_DIR='';
	for dir in $(egrep -v '^\s*#|^\s*$' $1|tr '\n' ' ') ; do 
		OUTPUT_FPM_DIR+="$dir "; 
	done
	echo $OUTPUT_FPM_DIR
}
# Use git functions to extrapolate the version number
# Args:		$1		The git directory to use
# Return:	$VERSION_NUMBER The version number
function get_version_number(){
	if [ ! -d "$1" ] || [ ! -x "$1" ]; then echo -e "$ERROR_TAG Cannot access to version directory $1";exit 1;fi
	cd $1
	revisioncount=$(git log --oneline|wc -l|tr -d ' ')
	projectversion=$(git describe --long --tags --dirty --always --match 'cv[0-9].*')
	cleanversion=$(echo ${projectversion%%-*}|tr -d 'cv')
	cd - 2>&1 1>/dev/null
	echo "$cleanversion.$revisioncount"
}
# Clone repositories given
# Args:		$1	List of repository
#		$2	List branch to clone
function clone_repositories(){
	for url in $1 ; do 
		for project_branch in $(echo $2|tr ',' ' ') ; do
			PROJECT=$(echo $project_branch|awk -F: '{print $1}')
			BRANCH=$(echo $project_branch|awk -F: '{print $2}')
			echo PROJECT $PROJECT
			echo BRANCH $BRANCH
			if [ "$PROJECT" == "$(echo $url|sed -n "s/^[^\]*\/\(.*\)\.git.*$/\1/p")" ] ; then
				branch="-b $BRANCH"
			fi
		done; 
		echo -e "Cloning $url $branch:\n-----"
		git clone $branch $url
		if [ $? -eq 0 ] ; then echo -e "-----\nCloned: [OK]"; else echo -e "-----\n$url Clone failed: [NOK]"; exit 1; fi
	done
}
#
# Use FPM to construct the package and move it to the output directory
# Args: 	$1	ARCH: 64/32
#		$2	OS: DEBIAN/RHEL
#		$3	PACKAGE_NAME
#		$4	VERSION_NUMBER
#		$5	VENDOR
#		$6	LICENSE
#		$7	MAINTAINER
#		$8	URL
#		$9	FPM_VARS
#		$10	OUTPUT_DIR
#
function launch_build(){
	ARCH=$1
	OS=$2
	if [ ! -r ${10} ] || [ ! -w ${10} ]; then echo "$ERROR_TAG Cannot output in ${10}"; exit 1;fi
	if [[ "$ARCH" == 32 ]] ; then ARCH="i386"; else ARCH="amd64"; fi
	if [[ "$OS" == "DEBIAN" ]] ; then TYPE="deb"; else TYPE="rpm"; fi
	fpm --force -s dir -t "$TYPE" -a "$ARCH" -n "$3" -v "$4" \
	  --vendor "$5" \
	  --license "$6" \
	  --maintainer "$7" \
	  --url "$8" \
	  --log info --verbose \
	  --rpm-auto-add-directories \
          ${9}
	if [ $? -eq 0 ] ; then
	  PACKAGE_FINAL_NAME=$(ls $TMP_DIR |grep $3*.*)
          echo -en "Moving package to $OUTPUT_DIR/$PACKAGE_FINAL_NAME:\t"
          mv $TMP_DIR/$3*.* $OUTPUT_DIR
	  if [ $? -eq 0 ] ; then echo "[OK]"; else echo "[NOK]"; fi
        else
          echo "Error while building, exiting"
          exit 1
        fi
}
# -------- Start of main script --------------- #
# Parse args
while getopts "h?vpo:a:c:d:D:f:b:": opt; do
    case "$opt" in
    h|help|\?)  	usage ; exit 0  		;;
    v|verbose)  	VERB=1          		;;
    p|packages) 	ALL=1           		;;
    b|branch)		BRANCH=$OPTARG         		;;
    c|config)		CONFIG_FILE=$OPTARG		;;
    f|fpm)		FPM_OPTIONS_FILE=$OPTARG	;;
    d|directory)	OUTPUT_FPM_DIR_FILE=$OPTARG	;;
    D|dependencies)	DEPS_FILE=$OPTARG		;;
    o|os)
        if [[ "$OPTARG" != "DEBIAN" && "$OPTARG" != "RHEL" && "$OPTARG" != "WINDOWS" ]] ; then
                echo -e "$ERROR_TAG $OPTARG is not a valid OS."
                usage;
                exit -1;
        fi
        OS=$OPTARG
        ;;
    a|architecture)
        if [[ "$OPTARG" != "64" && "$OPTARG" != "32" ]] ; then
                echo -e "$ERROR_TAG $OPTARG is not a valid architecture."
                usage;
                exit -1;
        fi
        ARCH=$OPTARG
        ;;
    esac
done

verify_parameters

echo -ne "Getting script location:\t\t\t\t"
DIR=$(get_script_location)
if [ $? -eq 0 ] ; then echo "$DIR [OK]"; else echo "[NOK]"; fi
LOG_DIR="${DIR}/log"

source_configuration_file $CONFIG_FILE
verify_configuration

echo -ne "Creating tempdir:\t\t\t\t"
TMP_DIR=$($ssh mktemp -d /tmp/$PACKAGE_NAME.dir.XXXXXXXXX)
if [ $? -eq 0 ] ; then echo "[OK]"; else echo "[NOK]"; fi

if [ ! -z $DEPS_FILE ] ; then
	DEPS=$(generate_dependencies $DEPS_FILE)
fi

if [ ! -z $OUTPUT_FPM_DIR_FILE ] ; then
	OUTPUT_FPM_DIR=$(generate_directories $OUTPUT_FPM_DIR_FILE)
fi

if [ ! -z $FPM_OPTIONS_FILE ] ; then
	FPM_OPTIONS=$(generate_fpm_options $FPM_OPTIONS_FILE)
fi

# Going in temporary dir
echo -ne "Moving to $TMP_DIR:\t\t\t\t"
cd $TMP_DIR
if [ $? -eq 0 ] ; then echo "[OK]"; else echo "[NOK]"; fi

clone_repositories "$CLONE_URL" $BRANCH

VERSION_NUMBER=$(get_version_number $VERSION_DIR)

FPM_VARS="$FPM_OPTIONS $DEPS $OUTPUT_FPM_DIR"
echo "Launching build with $ARCH $OS $PACKAGE_NAME $VERSION_NUMBER $VENDOR $LICENSE $MAINTAINER $URL $FPM_VARS $OUTPUT_DIR"
launch_build "$ARCH" "$OS" "$PACKAGE_NAME" "$VERSION_NUMBER" "$VENDOR" "$LICENSE" "$MAINTAINER" "$URL" "$FPM_VARS" "$OUTPUT_DIR"
rm -rf /tmp/$PACKAGE_NAME.dir.*
exit 0
