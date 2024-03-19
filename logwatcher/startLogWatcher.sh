#!/bin/sh


main(){
   echo "$(date -Iseconds): Starting log watcher"

   echo "$(date -Iseconds): Watching file=[${LOG_FILE}]"
   echo "$(date -Iseconds): Watching pattern=[${GREP_PATTERN}]"
   echo "$(date -Iseconds): Watching exclude pattern=[${GREP_EXCLUDE_PATTERN}]"
   echo "$(date -Iseconds): Publishing topic=[${TOPIC}]"
   LAST_LOG_ENTRY=''

   wait_for_broker

   echo -e "\n==> mosquitto_pub -h broker -t "${TOPIC}" -m $(date -Iseconds): Starting log watcher ${LOG_FILE}"
   mosquitto_pub -h broker -t "${TOPIC}" -m "$(date -Iseconds): Starting log watcher ${LOG_FILE}"

   if [ -n "${GREP_EXCLUDE_PATTERN}" ]; then
      tail -n 0 -F ${LOG_FILE} |
      grep --line-buffered -i "${GREP_PATTERN}" |
      grep --line-buffered -i -v "${GREP_EXCLUDE_PATTERN}" |
      while read msg; do
         echo "Log entry: ${msg}"

         # Skip duplicate log entries
         if [ "${LAST_LOG_ENTRY}" != "${msg}" ]; then
            LAST_LOG_ENTRY=${msg}
            processLogEntry "${msg}"
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
            processLogEntry "${msg}"
         fi
      done
   fi
}

processLogEntry(){
   msg=$1

   # Get real line number - tail starts at EOF, so line number 0 is at EOF
   msgLine=$(more ${LOG_FILE} | nl -s ':' | grep -F "$msg")
   line_number=$(echo ${msgLine} | cut -d ":" -f 1)
   back_track=$(($line_number-50))
   process_id=$(echo ${msgLine} | cut -d " " -f 2)

   if [ "${back_track}" -le "0" ]; then
      back_track=0
   fi

   # get 50 lines before the actual error
   lines_buffer=$(awk 'FNR >= '${back_track}' {print FNR ": " $0}; FNR == '${line_number}' {exit}' ${LOG_FILE})

   # Keep last 5 lines concernig this process id
   log_entries=$(echo "${lines_buffer}" | grep "+[0-9][0-9]:[0-9][0-9] ${process_id} " | tail -n 5)

   mosquitto_pub -h broker -t "${TOPIC}" -m "${log_entries}"
}

wait_for_broker() {
  echo "$(date -Iseconds): Waiting for broker to be ready"
  # curl code 28 == CURLE_OPERATION_TIMEDOUT
  while true ; do curl -s --max-time 1 mqtt://broker/\$SYS/broker/version ; [ "$?" -eq "28" ] && break ; sleep 5; done
}

main
returncode=$?
echo "$(date -Iseconds): Stopping log watcher"
exit ${returncode}
