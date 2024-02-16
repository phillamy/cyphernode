import { startMqttClient } from "./mqtt"
import { startNostr } from "./nostr/sendDM"

console.log(`nostr_client: starting up`)

console.log(`nostr_client: BROKER_URL => [${process.env.BROKER_URL}]`)
console.log(`nostr_client: BROKER_TOPIC => [${process.env.BROKER_TOPIC}]`)

console.log(`nostr_client: PUBLIC_KEY => [${process.env.PUBLIC_KEY}]`)
console.log(`nostr_client: RELAYS => [${process.env.RELAYS}]`)

startMqttClient()
await startNostr()
