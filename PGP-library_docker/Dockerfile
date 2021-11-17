FROM eclipse-mosquitto:1.6-openssl

ENV HOME /

RUN apk add --update --no-cache \
    gnupg jq su-exec mosquitto tmux

WORKDIR ${HOME}


COPY scripts/* ./
RUN chmod +x gen-key.sh list-key.sh startgpg.sh requesthandler.sh process_msg.sh

ENV GNUPGHOME=/.gnupgp


ENTRYPOINT ["su-exec"]

# docker build --no-cache -t pgp-mosquitto:1.0 . 
# docker run --rm -it --network cyphernodenet --name cn-pgp pgp-server
# docker run --rm -it -v `pwd`/data:/pgp/.gnupgp --network cyphernodenet --name cn-pgp pgp-mosquitto:1.0 `id -u`:`id -g` ./gen-key.sh
# docker run --rm -it -v `pwd`/data:/pgp/.gnupgp --network cyphernodenet --name cn-pgp pgp-mosquitto:1.0 `id -u`:`id -g` ./startgpg.sh
