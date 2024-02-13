#!/bin/sh


main(){
   echo "Starting log watcher $(date)"

   echo "Watching file=[${LOG_FILE}]"
   echo "Watching pattern=[${GREP_PATTERN}]"
   echo "Publishing topic=[${TOPIC}]"

   tail -n 0 -F ${LOG_FILE} |
   grep --line-buffered -i "${GREP_PATTERN}" |
   while read msg; do
      echo $msg
      mosquitto_pub -h broker -t "${TOPIC}" -m "${msg}"
   done
}

main
returncode=$?
echo 'Stopping log watcher'
exit ${returncode}
