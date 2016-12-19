#!/bin/bash

set -e

. ./functions.sh

if [[ "$#" == "0" ]]; then
  echo "Usage: $0 <file-to-convert.ser> [<output.tcx>]"
  echo "Example: $0 my-workout.ser output.tcx"
  exit 1
fi

inputFile=$1
outputFile=$2
if [[ "${outputFile}" == "" ]]; then
  outputFile=${inputFile/.ser/.tcx}
fi

if [ -a $outputFile ]; then
  echo "Output file [$outputFile] exists, quitting"
  exit 2
fi

dos2unix ${inputFile}

# for progress indications
numLines=$(cat ${inputFile} | wc -l)

# for Lap start data
firstDate=$(grep -E -m 1 -o "[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z" ${inputFile})
courseName=$(basename ${inputFile})

# for summary data
lastLine=$(tail -n 1 ${inputFile})
distanceInFunnyUnits=$(echo $lastLine | cut -d" " -f5)
distance=$((10#${distanceInFunnyUnits} * 100))
totalTimeElapsedString=$(echo $lastLine | cut -d" " -f8)
totalTimeSeconds=$(echo ${totalTimeElapsedString} | awk -F':' '{print $1 * 60 + $2}')

sed -e "s/\${courseName}/${courseName}/" \
    -e "s/\${id}/${courseName}/" \
    -e "s/\${totalDistance}/${distance}/" \
    -e "s/\${totalTimeSeconds}/$((10#${totalTimeSeconds}))/" \
    -e "s/\${startTime}/${firstDate}/" \
    tcx/tcx-header-template.xml >> ${outputFile}

linesProcessed=0
while read line; do
  linesProcessed=$((linesProcessed + 1))
  if [[ "$((linesProcessed % 100))" == "0" ]]; then
    echoStdErr "[${courseName}] Processed ${linesProcessed} lines of ${numLines}..."
  fi
  tsvParseLine $line
done < ${inputFile} >> ${outputFile}

cat tcx/tcx-footer-template.xml >> ${outputFile}
