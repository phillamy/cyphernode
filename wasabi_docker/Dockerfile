FROM debian:bullseye-slim

ARG WASABI_VERSION="2.0.1.3"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y xvfb libfontconfig1 wget gpg && apt-get clean

RUN wget https://raw.githubusercontent.com/zkSNACKs/WalletWasabi/master/PGP.txt && \
    gpg --import PGP.txt && \
    wget https://github.com/zkSNACKs/WalletWasabi/releases/download/v${WASABI_VERSION}/Wasabi-${WASABI_VERSION}.deb && \
    wget https://github.com/zkSNACKs/WalletWasabi/releases/download/v${WASABI_VERSION}/Wasabi-${WASABI_VERSION}.deb.asc && \
    gpg --verify Wasabi-${WASABI_VERSION}.deb.asc Wasabi-${WASABI_VERSION}.deb 

RUN dpkg -i Wasabi-${WASABI_VERSION}.deb && \
    rm /Wasabi-${WASABI_VERSION}.deb && \
    rm /Wasabi-${WASABI_VERSION}.deb.asc && \
    apt -y remove wget gpg && apt -y autoremove

WORKDIR /app

COPY docker-entrypoint.sh docker-entrypoint.sh
COPY torrc /etc/tor/torrc

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["wassabee"]
