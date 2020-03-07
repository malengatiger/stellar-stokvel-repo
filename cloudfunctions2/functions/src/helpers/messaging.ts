
import * as admin from 'firebase-admin';

const app = admin.initializeApp()
console.log(`🌽 🌽 🌽 Firebase initialized. ${app.name} ${app.options}`)
const msg = admin.messaging();

class Messaging {
    
    public static async sendStokvelCreated(data: any, ): Promise<any> {
        const options: any = {
            priority: "high",
            timeToLive: 60 * 60,
        };
        const payload: any = {
            notification: {
                title: `Stokvel added to Network`,
                body: data.name,
            },
            data: {
                stokvel: JSON.stringify(data)
            },
        };
        const topic = 'stokvels';
        const result = await msg.sendToTopic(topic, payload, options);
        console.log(
            `😍 stokvel created: FCM message sent: 😍 topic: ${topic} : result: 🍎🍎 ${JSON.stringify(result)} 🍎🍎`,
        );
    }
    public static async sendMemberCreated(data: any, ): Promise<any> {
        const options: any = {
            priority: "high",
            timeToLive: 60 * 60,
        };
        const payload: any = {
            notification: {
                title: `Member added to Network`,
                body: data.name,
            },
            data: {
                stokvel: JSON.stringify(data)
            },
        };
        const topic = 'members';
        const result = await msg.sendToTopic(topic, payload, options);
        console.log(
            `😍 stokvel created: FCM message sent: 😍 topic: ${topic} : result: 🍎🍎 ${JSON.stringify(result)} 🍎🍎`,
        );
    }
    public static async sendStokvelPaymentCreated(data: any, ): Promise<any> {
        const options: any = {
            priority: "high",
            timeToLive: 60 * 60,
        };
        const payload: any = {
            notification: {
                title: `Stokvel has been paid`,
                body: data.amount,
            },
            data: {
                stokvel: JSON.stringify(data)
            },
        };
        const topic = 'stokvelPayments';
        const result = await msg.sendToTopic(topic, payload, options);
        console.log(
            `😍 stokvelPayment created: FCM message sent: 😍 topic: ${topic} : result: 🍎🍎 ${JSON.stringify(result)} 🍎🍎`,
        );
    }
    public static async sendMemberPaymentCreated(data: any, ): Promise<any> {
        const options: any = {
            priority: "high",
            timeToLive: 60 * 60,
        };
        const payload: any = {
            notification: {
                title: `Member Payment added to Network`,
                body: data.amount,
            },
            data: {
                stokvel: JSON.stringify(data)
            },
        };
        const topic = 'memberPayments';
        const result = await msg.sendToTopic(topic, payload, options);
        console.log(
            `😍 memberPayment created: FCM message sent: 😍 topic: ${topic} : result: 🍎🍎 ${JSON.stringify(result)} 🍎🍎`,
        );
    }
   
}

export default Messaging