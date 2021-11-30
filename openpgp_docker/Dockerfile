FROM eclipse-mosquitto:1.6-openssl

ENV HOME /

RUN apk add --update --no-cache \
    gnupg jq su-exec

WORKDIR ${HOME}

COPY scripts/* ./
COPY data/* ./
RUN chmod +x gen-key.sh startgpg.sh requesthandler.sh process_msg.sh

ENV GNUPGHOME=/.gnupgp

ENTRYPOINT ["su-exec"]

# docker run --rm -v `pwd`/data/:/data -v `pwd`/keys:/.gnupgp -v `pwd`/../dist/cyphernode/logs:/cnlogs --network cyphernodenet --name cn-pgp pgp-mosquitto:1.0 `id -u`:`id -g` ./startgpg.sh

# docker build --no-cache -t pgp-mosquitto:1.0 . 
