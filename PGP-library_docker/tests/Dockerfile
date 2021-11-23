FROM eclipse-mosquitto:1.6-openssl

RUN apk add --update --no-cache \
    jq su-exec

ENTRYPOINT ["su-exec"]

# docker build --no-cache -t gpg-test:1.0 .
