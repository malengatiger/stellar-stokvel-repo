import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin'
// import * as Hello from './messaging/hello'
// import * as Tryer from './messaging/tryer'

export const app = admin.initializeApp(functions.config().firebase)
console.log(`Firebase is initialized: ${app.name} options: ${app.options}`)

export const helloStokkie = functions.https.onRequest((request, response) => {
    response.send(`🛎 🛎 Hello from Stokkiex Functions! 🛎 🛎 date: ` + new Date().toISOString());
   });
//export const hello = Hello.helloWorld
// export const newNotification = Tryer.newNotification
