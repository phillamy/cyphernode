# Cyphernode CRON container

## Pull our Cyphernode image

```shell
docker pull cyphernode/proxycron:latest
```

## Build yourself the image

```shell
docker build -t cyphernode/proxycron:TAG .
```

## Run image

If you are using it independantly from the Docker stack (docker-compose.yml), you can run it like that:

```shell
docker run --rm -d --network cyphernodenet --env-file env.properties cyphernode/proxycron:TAG
```

## Configure your container by modifying `env.properties` file

```properties
TX_CONF_URL=proxy:8888/executecallbacks
OTS_URL=proxy:8888/ots_backoffice
```
