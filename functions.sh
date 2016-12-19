
function echoStdErr() {
  cat <<< "$@" 1>&2
}

function tsvParseLine() {
  # sample output
  # 2016-11-19T12:09:30.891Z 075 000 000 000 025 0000 00:00 005
  local dataWithTimestamp="$@ spacer"
  local timestamp=$(echo $dataWithTimestamp | cut -d" " -f1)
  # sample output
  # HR     cadance speed   *100m   destpower energy  time    realPower
  # 071    000     000     000     025       0000    00:00   005
  local data=$(echo $dataWithTimestamp | cut -d" " -f2-)

  local array=(${data})

  if [[ "${#array[@]}" -le "8" ]]; then
    echoStdErr "Skipping: $@"
    return 0;
  fi

  local heartRate=$(echo $data | cut -d" " -f1)
  local cadence=$(echo $data | cut -d" " -f2)
  # speedString is (kph * 10)
  local speedString=$(echo $data | cut -d" " -f3)
  # multiple by 0.277778 for kph -> metres/sec
  # and divide by 10 for the funny unit
  local speedMps=$(echo $speedString | awk "{print \$1 * 0.0277778}")
  local distanceInFunnyUnits=$(echo $data | cut -d" " -f4)
#  local destPower=$(echo $data | cut -d" " -f5)
#  local energy=$(echo $data | cut -d" " -f6)
#  local timeElapsed=$(echo $data | cut -d" " -f7)
  local realPower=$(echo -n $data | cut -d" " -f8)

  sed -e "s/\${timestamp}/${timestamp}/" \
      -e "s/\${heartRate}/$((10#${heartRate}))/" \
      -e "s/\${distance}/$((10#${distanceInFunnyUnits} * 100)).0/" \
      -e "s/\${cadence}/$((10#${cadence}))/" \
      -e "s/\${realPower}/$((10#${realPower}))/" \
      -e "s/\${speed}/${speedMps}/" \
      tcx/tcx-trackpoint-template.xml
}

#tsvParse "$@"
