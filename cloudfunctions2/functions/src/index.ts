import * as functions from 'firebase-functions';
import Messaging from './helpers/messaging';


// export const ping = functions.https.onRequest((request, response) => {
//     response.send(" 🍎  🍎  🍎  🍎 ping from Skottie Network One!  🍎  🍎  🍎  🍎");
// });

export const memberCreated = functions.firestore.document(`members/{memberId}`)
    .onWrite((snapshot: any, context: any) => {
        
        const newValue = snapshot.after.data();
        console.log(`🔵 🔵 🔵 memberCreated: ${newValue} 🍎`);
        return Messaging.sendMemberCreated(newValue)
    });
    export const memberUpdated = functions.firestore.document(`members/{memberId}`)
    .onUpdate((snapshot: any, context: any) => {
        
        const newValue = snapshot.after.data();
        console.log(`🔵 🔵 🔵 memberUpdated: ${newValue} 🍎`);
        return Messaging.sendMemberUpdated(newValue)
    });

export const stokvelCreated = functions.firestore.document(`stokvels/{stokvelId}`)
    .onWrite((snapshot: any, context: any) => {
        const newValue = snapshot.after.data();
        console.log(`🔵 🔵 🔵 stokvelCreated: ${newValue} 🍎`);
        return Messaging.sendStokvelCreated(newValue)
    });
export const stokvelPaymentCreated = functions.firestore.document(`stokvelPayments/{stokvelId}`)
    .onWrite((snapshot: any, context: any) => {
        const newValue = snapshot.after.data();
        console.log(`🔵 🔵 🔵 stokvelPaymentCreated: ${newValue} 🍎`);
        return Messaging.sendStokvelPaymentCreated(newValue)

    });
export const memberPaymentCreated = functions.firestore.document(`memberPayments/{memberId}`)
    .onWrite((snapshot: any, context: any) => {
        const newValue = snapshot.after.data();
        console.log(`🔵 🔵 🔵 memberPaymentCreated: ${newValue} 🍎`);
        return Messaging.sendMemberPaymentCreated(newValue)
    });
