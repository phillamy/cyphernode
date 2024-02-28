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
    env_file:
      - .env/logwatcher-proxy.env

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

env file:
```sh
LOG_FILE=/cnlogs/proxy.log
GREP_PATTERN=error\|Last return code:
GREP_EXCLUDE_PATTERN=no error\|"error:null"\|Last return code: 0
TOPIC=cn/logwatcher/proxy
```


## Example outputs - logwatcher

```sh
Starting log watcher Wed Feb 28 13:43:43 UTC 2024
Watching file=[/cnlogs/proxy.log]
Watching pattern=[error\|Last return code:]
Watching exclude pattern=[no error\|"error":null\|Last return code: 0]
Publishing topic=[cn/logwatcher/proxy]
Waiting for broker to be ready
\$SYS/broker/versionmosquitto version 1.6.15
==> mosquitto_pub -h broker -t cn/logwatcher/proxy -m Starting log watcher /cnlogs/proxy.log
tail: cannot open '/cnlogs/proxy.log' for reading: No such file or directory
tail: '/cnlogs/proxy.log' has appeared;  following new file
...
```

## Example outputs - process subing to topic

```sh
/ # mosquitto_sub -h broker -t cn/logwatcher/#
2024-02-13T21:12:15+00:00 93 [bitcoin_node_newtip] reconnecting in 60 secs
```
