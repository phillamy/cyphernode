import { ErrorWithReasonCode, IConnackPacket, IPublishPacket, connect } from 'mqtt';
import { nostrSendDM } from './nostr/sendDM';

export function startMqttClient() {
  console.log(`nostr_client: connecting to MQTT [${process.env.BROKER_URL}]`)

  const mqttClient = connect(`${process.env.BROKER_URL}`, { clientId: process.env.APP_NAME })

  mqttClient.on('connect', (packet: IConnackPacket) => {
    console.log(`nostr_client: connected ${JSON.stringify(packet)}`)

    console.log(`nostr_client: subscribing to [${process.env.BROKER_TOPIC}]`)
    mqttClient.subscribe(`${process.env.BROKER_TOPIC}`, { qos: 2 }, (error, granted) => {
      if (error) {
        console.error(`nostr_client: Could not connect to ${process.env.BROKER_TOPIC}`)
      }

      console.log(granted, 'nostr_client: subscribed')
    })
  })

  mqttClient.on('message', async (topic: string, payload: Buffer, _packet: IPublishPacket) => {
    console.log(`nostr_client: Message topic: ${topic}`)
    console.log(`nostr_client: Message : ${payload}`)
    await nostrSendDM({ message: `[${topic}] [${payload.toString()}]` })
  })

  mqttClient.on('error', (error: Error | ErrorWithReasonCode) => {
    console.log(`nostr_client: ${error}`)
  })

  mqttClient.on('disconnect', () => {
    console.log(`nostr_client: disconnected`)
  })

  mqttClient.on('reconnect', () => {
    console.log(`nostr_client: reconnecting`)
  })
}