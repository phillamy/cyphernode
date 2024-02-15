import NDK, { NDKEvent, NDKKind, NDKPrivateKeySigner, NDKRelay } from "@nostr-dev-kit/ndk";
import { log } from "console";
import { randomUUID } from "crypto";
import "websocket-polyfill";

// See https://nostrtool.com/
// See https://www.youtube.com/watch?v=djUS6GvU9pM
// See https://github.com/nostr-dev-kit/ndk/tree/master

export async function startNostrClient() {
  console.log(`nostr_client: connecting to relays ${process.env.RELAYS}`)

  const signer = new NDKPrivateKeySigner(`${process.env.PRIVATE_KEY}`)
  console.log(`nostr_client: signer created`)

  const ndk = new NDK({
    explicitRelayUrls: `${process.env.RELAYS}`.split(','),
    //  explicitRelayUrls: ["wss://relay.damus.io"],
    //  signer,
  });
  ndk.pool.on("relay:connect", (r: NDKRelay) => { console.info(`Connected to relay ${r.url}`); });

  // Now connect to specified relays
  await ndk.connect(2000);

  console.log(`nostr_client: connected to relays`)

  const phil = ndk.getUser({
    npub: `${process.env.PUBLISHING_TO_NPUBS}`,
  });

  console.log(`nostr_client: phil created`)

  const subscription = ndk.subscribe([
    { // Encrypted DM sent by phil
      kinds: [NDKKind.EncryptedDirectMessage],
      authors: [phil.pubkey],
      since: 0,
      limit: 10,
    },
  ], { closeOnEose: false })

  subscription.on("event", async (event: NDKEvent) => {
    switch (event.author.pubkey) {
      case phil.pubkey:
        console.log(`Message from phil`)
        try {
          await event.decrypt(phil, signer)
          console.log(`[${event.created_at}] pubkey=${event.author.pubkey} content=${event.content} `);
          console.log(`---------------------------------------------------`);
        }
        catch (e) {
          console.error(`Could not decrypt : ${e}`)
        }
        break

      default:
      // Do nothing
    }

  });

  subscription.on("eose", () => console.log("All relays have reached the end of the event stream"));
  subscription.on("close", () => console.log("Subscription closed"));
  setTimeout(() => subscription.stop(), 10000); // Stop the subscription after 10 seconds


  const ndkEvent = new NDKEvent(ndk);
  ndkEvent.kind = 4
  ndkEvent.content = `Hello from CN bot ${new Date().toISOString()}`
  ndkEvent.tag(phil)
  ndkEvent.id = randomUUID()
  ndkEvent.generateTags()

  await ndkEvent.encrypt(phil, signer)

  //console.log(`nostr_client: signing`)
  await ndkEvent.sign(signer)
  console.log(`nostr_client: encrypting`, ndkEvent)

  console.log(`nostr_client: publishing`)

  const relaySet = await ndkEvent.publish()

  for (const relay of relaySet) {
    console.log(`Relay ${relay.status}`)
  }

}
