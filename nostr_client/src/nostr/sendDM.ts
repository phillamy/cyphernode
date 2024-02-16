import NDK, { NDKEvent, NDKKind, NDKPrivateKeySigner, NDKUser } from "@nostr-dev-kit/ndk";
import { randomUUID } from "crypto";
import "websocket-polyfill";

// See https://nostrtool.com/
// See https://www.youtube.com/watch?v=djUS6GvU9pM
// See https://github.com/nostr-dev-kit/ndk/tree/master

// NDK recommends using a singlton
let ndk: NDK
let signer: NDKPrivateKeySigner

export async function startNostr(): Promise<void> {
  signer = new NDKPrivateKeySigner(`${process.env.PRIVATE_KEY}`)

  ndk = new NDK({
    explicitRelayUrls: `${process.env.RELAYS}`.split(','),
    signer,
  });
  //ndk.pool.on("relay:connect", (r: NDKRelay) => { console.info(`Connected to relay ${r.url}`); });

  // connect to specified relays
  await ndk.connect(2000);
}

export async function nostrSendDM({ message }: { message: string }) {
  console.log(`Entering nostrSendDM`)

  const userNpubs = `${process.env.PUBLISHING_TO_NPUBS}`.split(',')

  for (const userNPub of userNpubs) {
    try {
      await publishDM({
        message,
        user: ndk.getUser({ npub: userNPub }),
      })
    }
    catch (e) {
      console.error(`Error publishing message`)
    }
  }
}

async function publishDM({ message, user }: { message: string, user: NDKUser }) {
  console.log(`publishDM: [${user.pubkey}] - [${message}]`)

  const ndkEvent = new NDKEvent(ndk);
  ndkEvent.kind = NDKKind.EncryptedDirectMessage;
  ndkEvent.content = `${new Date().toISOString()} [${process.env.APP_NAME}] : [${message}]`
  ndkEvent.tag(user);
  ndkEvent.id = randomUUID();
  ndkEvent.generateTags();

  await ndkEvent.encrypt(user, signer);
  //console.log(`nostr_client: encrypting`, ndkEvent);

  // Relays are calculated by NDK - no relay set specified
  const relaySet = await ndkEvent.publish();

  for (const relay of relaySet) {
    console.log(`Relay status :${relay.status}`);
  }
}
