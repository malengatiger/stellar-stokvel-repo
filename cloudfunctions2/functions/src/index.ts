import * as functions from 'firebase-functions';
import Messaging from './helpers/messaging';

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
export const ping = functions.https.onRequest((request, response) => {
 response.send(" 🍎  🍎  🍎  🍎 ping from Skottie Network One!  🍎  🍎  🍎  🍎");
});

export const memberCreated = functions.firestore.document(`members/{memberId}`).onCreate((snapshot, context) => {
   console.log(`🔵 🔵 🔵 memberCreated: ${snapshot.data}`);
   Messaging.sendMemberCreated(snapshot.data)
});

export const stokvelCreated = functions.firestore.document(`stokvels/{stokvelId}`).onCreate((snapshot, context) => {
    console.log(`🔵 🔵 🔵 stokvelCreated: ${snapshot.data}`);
    Messaging.sendStokvelCreated(snapshot.data)
 });
 export const stokvelPaymentCreated = functions.firestore.document(`stokvelPayments/{stokvelId}`).onCreate((snapshot, context) => {
    console.log(`🔵 🔵 🔵 stokvelPaymentCreated: ${snapshot.data}`);
    Messaging.sendStokvelCreated(snapshot.data)
  
 });
 export const memberPaymentCreated = functions.firestore.document(`memberPayments/{memberId}`).onCreate((snapshot, context) => {
    console.log(`🔵 🔵 🔵 memberPaymentCreated: ${snapshot.data}`);
    Messaging.sendMemberPaymentCreated(snapshot.data)
 });
