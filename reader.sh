#!/bin/bash

if [[ "$1" == "" ]]; then
  echo "Usage: $0 <target-serial-device>"
  echo "Example: $0 /dev/cu.KETTLER0A7527-SerialPort"
  exit 1
fi

function getDate() {
  date --utc +%FT%TZ
}

TARGET=$1
SUFFIX=$2
LOG_FILE=$(getDate)-${SUFFIX}.ser

echo "timestamp                heartRate cadence speed distanceInFunnyUnits destpower energy timeElapsed realPower"

cat $TARGET | while read data; do
  timestamp=$(getDate)
  heartRate=$(echo $data | cut -d" " -f1)
  cadence=$(echo $data | cut -d" " -f2)
  speed=$(echo $data | cut -d" " -f3)
  distanceInFunnyUnits=$(echo $data | cut -d" " -f4)
  destPower=$(echo $data | cut -d" " -f5)
  energy=$(echo $data | cut -d" " -f6)
  timeElapsed=$(echo $data | cut -d" " -f7)
  realPower=$(echo $data | cut -d" " -f8)
  printf "%24s %9s %7s %5s %20s %9s %6s %11s %9s\n" $timestamp $heartRate $cadence $speed $distanceInFunnyUnits $destPower $energy $timeElapsed $realPower | tee --append ${LOG_FILE}
done
