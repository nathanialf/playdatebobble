#!/bin/bash
BUILD_DIRECTORY="build"
PDC_OUTPUT_FILE="playdatebobble.pdx"

usage () { echo "Usage: ./build.sh [-b </path/to/build/dir>] [-f <playdatefile.pdx>]"; exit 1; }

while getopts "b:f:" opt; do
    case ${opt} in
        b )
            # Sets BUILD_DIRECTORY to the value following -b
            BUILD_DIRECTORY=$OPTARG
            ;;
        f )
            # Sets PDC_OUTPUT_FILE to the value following -f
            PDC_OUTPUT_FILE=$OPTARG
            ;;
        \? )
            usage
            ;;
    esac
done

# Creates build directory if it doesn't exist
if [ ! -d $BUILD_DIRECTORY ]
then
    echo "Creating ${BUILD_DIRECTORY}/ directory"
    mkdir $BUILD_DIRECTORY
else
    echo "${BUILD_DIRECTORY}/ directory exists."
fi

# PlayDate Compile
echo "Compiling with pdc"
pdc -v source "${BUILD_DIRECTORY}/${PDC_OUTPUT_FILE}"

if [ $? == 0 ]
then
    # Zip file if compile worked
    echo "Zipping ${PDC_OUTPUT_FILE} for uploading to https://play.date/account/sideload/"
    zip -r "${BUILD_DIRECTORY}/${PDC_OUTPUT_FILE}.zip" "${BUILD_DIRECTORY}/${PDC_OUTPUT_FILE}"

    if [ $? == 0 ]
    then
        echo "Build complete! pdx and zip files are located in the ${BUILD_DIRECTORY}/ directory"
    else
        exit 1
    fi
else
    exit 1
fi