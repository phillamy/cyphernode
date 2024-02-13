FROM debian:bookworm-slim
RUN apt update && apt -y install \
    mosquitto-clients \
 && apt -y autoremove

RUN addgroup --system logwatcher \
    && adduser --system --ingroup logwatcher --disabled-password --uid 999 --home /home/logwatcher logwatcher \
    && chown -R logwatcher:logwatcher /home/logwatcher

WORKDIR /home/logwatcher

COPY --chown=logwatcher:logwatcher startLogWatcher.sh /home/logwatcher

RUN chmod +x /home/logwatcher/startLogWatcher.sh
