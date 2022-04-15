#!/bin/sh

. ./trace.sh
. ./web.sh
. ./response.sh
. ./sql.sh

main() {
  trace "Entering main()..."

  local msg
  local cmd
  local response
  local response_topic
  local url

  if [ "${FEATURE_TELEGRAM}" = "true" ]; then
    trace "[main] FEATURE_TELEGRAM is ENABLED"

    trace "[main] Looking up TG_BOT_URL in database"
    TG_BOT_URL=$(sql "SELECT value FROM cyphernode_props WHERE category='notifier' AND property='tg_base_url'")
    returncode=$?
    trace_rc ${returncode}

    trace "[main] Looking up TG_API_KEY in database"
    TG_API_KEY=$(sql "SELECT value FROM cyphernode_props WHERE category='notifier' AND property='tg_api_key'")
    returncode=$?
    trace_rc ${returncode}

    trace "[main] Looking up TG_CHAT_ID in database"
    TG_CHAT_ID=$(sql "SELECT value FROM cyphernode_props WHERE category='notifier' AND property='tg_chat_id'")
    returncode=$?
    trace_rc ${returncode}
  else
    trace "[main] FEATURE_TELEGRAM is DISABLED"
  fi

  # Messages should have this form:
  # {"response-topic":"response/5541","cmd":"web","url":"2557df870b9a:1111/callback1conf","body":"eyJpZCI6IjUxIiwiYWRkc...dCI6MTUxNzYwMH0K"}
  while read msg; do
    trace "[main] New msg just arrived!"
    trace "[main] msg=${msg}"

    cmd=$(echo ${msg} | jq -r ".cmd")
    trace "[main] cmd=${cmd}"

    response_topic=$(echo ${msg} | jq -r '."response-topic"')
    trace "[main] response_topic=${response_topic}"

    case "${cmd}" in
      web)
        response=$(web "${msg}")
        publish_response "${response}" "${response_topic}" ${?}
        ;;
      sendToTelegramGroup)
        # example:
        #   local body=$(echo "{\"text\":\"Hello world in Telegram at `date -u +"%FT%H%MZ"`\"}" | base64)
        #   response=$(mosquitto_rr -h broker -W 15 -t notifier -e "response/$$" -m "{\"response-topic\":\"response/$$\",\"cmd\":\"sendToTelegramGroup\",\"body\":\"${body}\"}")
        if [ "${FEATURE_TELEGRAM}" = "true" ]; then
          url=$(echo ${TG_BOT_URL}${TG_API_KEY}/sendMessage?chat_id=${TG_CHAT_ID})
          trace "[main] telegram-url=${url}"

          msg=$(echo ${msg} | jq --arg url ${url} '. += {"url":$url}' )
          trace "[main] web-msg=${msg}"

          response=$(web "${msg}")
          publish_response "${response}" "${response_topic}" ${?}
        else
          trace "[main] Telegram is NOT enabled - message not sent"
        fi
        ;;
      sendToTelegramNoop)
        if [ "${FEATURE_TELEGRAM}" = "true" ]; then
          url=$(echo ${TG_BOT_URL}${TG_API_KEY}/getMe)
          trace "[main] telegram-url=${url}"

          msg=$(echo ${msg} | jq --arg url ${url} '. += {"url":$url}' )
          trace "[main] web-msg=${msg}"

          response=$(web "${msg}")
          publish_response "${response}" "${response_topic}" ${?}
        else
          trace "[main] Telegram is NOT enabled - message not sent"
        fi
        ;;
    esac
    trace "[main] msg processed"
  done
}

main
returncode=$?
trace "[requesthandler] exiting"
exit ${returncode}
