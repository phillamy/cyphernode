#!/bin/sh


main(){
   echo "Starting log watcher $(date)"

   echo "Watching file=[${LOG_FILE}]"
   echo "Watching pattern=[${GREP_PATTERN}]"
   echo "Watching exclude pattern=[${GREP_EXCLUDE_PATTERN}]"
   echo "Publishing topic=[${TOPIC}]"
   LAST_LOG_ENTRY=''

   wait_for_broker

   echo -e "\n==> mosquitto_pub -h broker -t "${TOPIC}" -m Starting log watcher ${LOG_FILE}"
   mosquitto_pub -h broker -t "${TOPIC}" -m "Starting log watcher ${LOG_FILE}"

   if [ -n "${GREP_EXCLUDE_PATTERN}" ]; then
      tail -n 0 -F ${LOG_FILE} |
      grep --line-buffered -i "${GREP_PATTERN}" |
      grep --line-buffered -i -v "${GREP_EXCLUDE_PATTERN}" |
      while read msg; do
         echo "Log entry: ${msg}"

         # Skip duplicate log entries
         if [ "${LAST_LOG_ENTRY}" != "${msg}" ]; then
            LAST_LOG_ENTRY=${msg}
            echo "==> mosquitto_pub -h broker -t "${TOPIC}" -m ${msg}"
            mosquitto_pub -h broker -t "${TOPIC}" -m "${msg}"
         fi
      done
   else
      tail -n 0 -F ${LOG_FILE} |
      grep --line-buffered -i "${GREP_PATTERN}" |
      while read msg; do
         echo "Log entry: ${msg}"

         # Skip duplicate log entries
         if [ "${LAST_LOG_ENTRY}" != "${msg}" ]; then
            LAST_LOG_ENTRY=${msg}
            echo "==> mosquitto_pub -h broker -t "${TOPIC}" -m ${msg}"
            mosquitto_pub -h broker -t "${TOPIC}" -m "${msg}"
         fi
      done
   fi
}

wait_for_broker() {
  echo "Waiting for broker to be ready"
  # curl code 28 == CURLE_OPERATION_TIMEDOUT
  while true ; do curl -s --max-time 1 mqtt://broker/\$SYS/broker/version ; [ "$?" -eq "28" ] && break ; sleep 5; done
}

main
returncode=$?
echo 'Stopping log watcher'
exit ${returncode}
