import NDK, { NDKEvent, NDKKind, NDKPrivateKeySigner, NDKRelay } from "@nostr-dev-kit/ndk";
import "websocket-polyfill";

// See https://nostrtool.com/
// See https://www.youtube.com/watch?v=djUS6GvU9pM
// See https://github.com/nostr-dev-kit/ndk/tree/master

async function nostrReadDM() {
  console.log(`nostrReadDM: connecting to relays ${process.env.RELAYS}`)

  const signer = new NDKPrivateKeySigner(`${process.env.PRIVATE_KEY}`)
  console.log(`nostrReadDM: signer created`)

  const ndk = new NDK({
    explicitRelayUrls: `${process.env.RELAYS}`.split(','),
    signer,
  });
  ndk.pool.on("relay:connect", (r: NDKRelay) => { console.info(`Connected to relay ${r.url}`); });

  // Now connect to specified relays
  await ndk.connect(2000);

  console.log(`nostr_client: connected to relays`)

  const user = ndk.getUser({
    npub: `${process.env.PUBLISHING_TO_NPUBS}`,
  });

  console.log(`nostr_client: user created`)

  const subscription = ndk.subscribe([
    { // Encrypted DM sent by user
      kinds: [NDKKind.EncryptedDirectMessage],
      authors: [user.pubkey],
      since: 0,
      limit: 10,
    },
  ])

  subscription.on("event", async (event: NDKEvent) => {
    switch (event.author.pubkey) {
      case user.pubkey:
        console.log(`Message from user`)
        try {
          await event.decrypt(user, signer)
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
}
