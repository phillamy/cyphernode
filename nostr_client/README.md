## Add a .env file in nostr_client directory - see sample.env

.env:
```sh
APP_NAME='Cypernode nostr client'

# CN broker config
BROKER_URL='mqtt://broker'
BROKER_TOPIC='cn/logwatcher/#'

# Nostr configs
PRIVATE_KEY='ccf4249464a9000000000000000000000000000000000000000e575fb301ee0b1'
RELAYS='wss://relay.some.io,wss://relay.aaaaa'
PUBLISHING_TO_NPUBS='npub100000000000000000000000000000000000000000000000000000'
CRON_SCHEDULE='0 */10 * * * *' #every 10 minutes
MAX_MESSAGE_PER_CRON_TICK=5
```

## Add a section in cyphernode docker-compose.yaml

```yaml
  ##########################
  # nostr_client           #
  ##########################

  nostr_client:
    image: cyphernode/nostr_client:0.1

    volumes:
      - "/cyphernode/nostr_client/.env:/home/nostr_client/.env"

    stop_grace_period: 30s
    networks:
      - cyphernodenet
    depends_on:
      - broker

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