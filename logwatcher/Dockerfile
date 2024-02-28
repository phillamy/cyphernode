FROM alpine:3.19
RUN apk add --update \
    mosquitto-clients grep curl

ENV USER=logwatch
ENV GROUPNAME=$USER
ENV UID=1000
ENV GID=1000
ENV pwd=/home/logwatcher

RUN addgroup \
    --gid "$GID" \
    "$GROUPNAME"
RUN  adduser \
    --disabled-password \
    --gecos "" \
    --home "$(pwd)" \
    --ingroup "$GROUPNAME" \
    --no-create-home \
    --uid "$UID" \
    $USER

WORKDIR /home/logwatcher

COPY --chown=logwatcher:logwatcher startLogWatcher.sh /home/logwatcher

RUN chmod +x /home/logwatcher/startLogWatcher.sh
