#!/bin/sh

. ./trace.sh
. ./process_msg.sh
. ./response.sh

main() {
  trace "Entering main()..."

  local version=$(gpg --version)

  trace "Version : ${version}"

  local msg
  local cmd
  local response
  local response_topic
  local prev_msg

  # Messages should have this form:
  # {"response-topic":"response/5541","cmd":"sign","body":"text-to-sign"}
  while read msg; do
    trace "[main] New msg just arrived!"
    trace "[main] msg=${msg}"

    cmd=$(echo ${msg} | jq -r ".cmd")
    trace "[main] cmd=${cmd}"

    response_topic=$(echo ${msg} | jq -r '."response-topic"')
    trace "[main] response_topic=${response_topic}"

    case "${cmd}" in
      clearsign)
        response=$(process_clearsign "${msg}")
        publish_response "${response}" "${response_topic}" ${?}
        ;;
      verifyclearsign)
        response=$(process_verifyclearsign "${msg}")
        publish_response "${response}" "${response_topic}" ${?}
        ;;
      detachsign)
        response=$(process_detachsign "${msg}")
        publish_response "${response}" "${response_topic}" ${?}
        ;;
      verifydetachsign)
        response=$(process_verifydetachsign "${msg}")
        publish_response "${response}" "${response_topic}" ${?}
        ;;
       *)
        response='{"error": {"code": -32602, "message": "Method not found"}, "id": "1"}'
        returncode=1
        ;;
    esac
    trace "[main] msg processed"
  done
}

export TRACING=1

main
trace "[requesthandler] exiting"
exit $?
