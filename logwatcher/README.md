# Cyphernode Log watcher

## Pull our Cyphernode image

```shell
docker pull cyphernode/logwatcher:v0.9.0-dev-local
```

## Build yourself the image

```shell
docker build -t cyphernode/logwatcher:v0.9.0-dev-local .
```

## Add a section in cyphernode docker-compose.yaml

```yaml
  ##########################
  # logwatcher             #
  ##########################

  logwatcher:
    image: cyphernode/logwatcher:v0.9.0-dev-local
    command: ./startLogWatcher.sh

    volumes:
      - "/cyphernode/dist/cyphernode/logs:/cnlogs"
    environment:
      - LOG_FILE=/cnlogs/proxy.log
      - GREP_PATTERN=error\|bitcoin_node_newtip
      - TOPIC=cn/logwatcher/proxy

    stop_grace_period: 30s
    networks:
      - cyphernodenet
    depends_on:
      - proxy

    deploy:
      replicas: 1
      placement:
        constraints:
          - node.labels.io.cyphernode == true
      restart_policy:
        condition: "any"
        delay: 1s
      update_config:
        parallelism: 1
```

## Example outputs - logwatcher

```sh
Starting log watcher Tue Feb 13 21:09:47 UTC 2024
Watching file=[/cnlogs/proxy.log]
Watching pattern=[error\|bitcoin_node_newtip]
Publishing topic=[cn/logwatcher/proxy]
tail: cannot open '/cnlogs/proxy.log' for reading: No such file or directory
tail: '/cnlogs/proxy.log' has appeared;  following new file
2024-02-13T21:10:12+00:00 93 Entering bitcoin_node_newtip()...
2024-02-13T21:10:13+00:00 93 [bitcoin_node_newtip] reconnecting in 60 secs
```

## Example outputs - process subing to topic

```sh
/ # mosquitto_sub -h broker -t cn/logwatcher/#
2024-02-13T21:12:15+00:00 93 [bitcoin_node_newtip] reconnecting in 60 secs
```
