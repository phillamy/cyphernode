# Cyphernode Log watcher

Configure a grep pattern and optionnaly a grep exclude pattern.  Logwatcher will return the last 5 log entries related the sme process id that triggered the message

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
GREP_EXCLUDE_PATTERN=no error\|"error":null\|Last return code: 0
TOPIC=cn/logwatcher/proxy
```


## Example outputs - logwatcher

```sh
2024-03-19T20:06:06+00:00: Starting log watcher
2024-03-19T20:06:06+00:00: Watching file=[/cnlogs/proxy.log]
2024-03-19T20:06:06+00:00: Watching pattern=[error\|Last return code:]
2024-03-19T20:06:06+00:00: Watching exclude pattern=[no error\|"error":null\|Last return code: 0]
2024-03-19T20:06:06+00:00: Publishing topic=[cn/logwatcher/proxy]
2024-03-19T20:06:06+00:00: Waiting for broker to be ready
$SYS/broker/versionmosquitto version 1.6.15
==> mosquitto_pub -h broker -t cn/logwatcher/proxy -m 2024-03-19T20:06:07+00:00: Starting log watcher /cnlogs/proxy.log
tail: cannot open '/cnlogs/proxy.log' for reading: No such file or directory
tail: '/cnlogs/proxy.log' has appeared;  following new file
...
```

## Example outputs - process subing to topic

```sh
/ # mosquitto_sub -h broker -t cn/logwatcher/#
2024-02-13T21:12:15+00:00 93 [bitcoin_node_newtip] reconnecting in 60 secs
```
