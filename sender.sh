#!/bin/bash

if [[ "$1" == "" ]]; then
  echo "Usage: $0 <target-serial-device>"
  echo "Example: $0 /dev/cu.KETTLER0A7527-SerialPort"
  exit 1
fi

TARGET=$1

HELLO=CM
GET_ID=ID
RESET=RS
GET_STATUS=ST

UNKNOWN=cd

SET_POWER=PW

function say() {
  local message=$1
  local target=$2

  echo -en "${message}\r\n" | tee --append ${TARGET}
}

#say ${GET_ID}
while true; do
  sleep 0.5
  say ${GET_STATUS}
done
