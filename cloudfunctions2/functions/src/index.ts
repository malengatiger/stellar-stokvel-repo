import * as functions from 'firebase-functions';
import Messaging from './helpers/messaging';


export const ping = functions.https.onRequest((request, response) => {
    response.send(" 🍎  🍎  🍎  🍎 ping from Skottie Network One!  🍎  🍎  🍎  🍎");
});

export const memberCreated = functions.firestore.document(`members/{memberId}`)
    .onWrite((snapshot, context) => {
        console.log(`🔵 🔵 🔵 memberCreated: ${snapshot.after}`);
        Messaging.sendMemberCreated(snapshot.after)
    });

export const stokvelCreated = functions.firestore.document(`stokvels/{stokvelId}`)
    .onWrite((snapshot, context) => {
        console.log(`🔵 🔵 🔵 stokvelCreated: ${snapshot.after}`);
        Messaging.sendStokvelCreated(snapshot.after)
    });
export const stokvelPaymentCreated = functions.firestore.document(`stokvelPayments/{stokvelId}`)
    .onWrite((snapshot, context) => {
        console.log(`🔵 🔵 🔵 stokvelPaymentCreated: ${snapshot.after}`);
        Messaging.sendStokvelCreated(snapshot.after)

    });
export const memberPaymentCreated = functions.firestore.document(`memberPayments/{memberId}`)
    .onWrite((snapshot, context) => {
        console.log(`🔵 🔵 🔵 memberPaymentCreated: ${snapshot.after}`);
        Messaging.sendMemberPaymentCreated(snapshot.after)
    });
