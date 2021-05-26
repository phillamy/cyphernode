FROM nginx:alpine

RUN apk add --update --no-cache \
		bash \
    git \
    openssl \
    fcgiwrap \
    spawn-fcgi \
    curl \
    jq \
    su-exec

COPY auth.sh /etc/nginx/conf.d/
COPY test/default.conf /etc/nginx/conf.d/default.conf
COPY entrypoint.sh entrypoint.sh
COPY trace.sh /etc/nginx/conf.d/
COPY test/test.sh /etc/nginx/conf.d/
COPY keys-sample.properties /etc/nginx/conf.d/keys.properties
COPY api-sample.properties /etc/nginx/conf.d/api.properties

RUN chmod a+rx /etc/nginx/conf.d/auth.sh entrypoint.sh /etc/nginx/conf.d/trace.sh /etc/nginx/conf.d/test.sh

RUN mkdir /cnlogs
RUN touch /cnlogs/gatekeeper.log
RUN chmod a+rw /cnlogs/gatekeeper.log

ENTRYPOINT ["./entrypoint.sh"]
