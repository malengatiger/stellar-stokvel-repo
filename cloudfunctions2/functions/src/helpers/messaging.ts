
import * as admin from 'firebase-admin';

admin.initializeApp()
// console.log(`🌽 🌽 🌽 Firebase initialized. 🎽 ${app.name} 🎽 ${app.options}`)
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
                body: '',
            },
            data: {
                type: 'stokvel'
            },
        };
        const topic = 'stokvels';
        const result = await msg.sendToTopic(topic, payload, options);
        console.log(
            `🎽 🎽  stokvel created: FCM message sent: 😍 topic: ${topic} : result: 🍎🍎 ${JSON.stringify(result)} 🍎🍎`,
        );
        return result
    }
    public static async sendMemberCreated(data: any, ): Promise<any> {
        const options: any = {
            priority: "high",
            timeToLive: 60 * 60,
        };
        const payload: any = {
            notification: {
                title: `Member added to Network`,
                body: '',
            },
            data: {
                type: 'member'
            },
        };
        const topic = 'members';
        const result = await msg.sendToTopic(topic, payload, options);
        console.log(
            `🎽 🎽  member created: FCM message sent: 😍 topic: ${topic} : result: 🍎🍎 ${JSON.stringify(result)} 🍎🍎`,
        );
        return result
    }
    public static async sendStokvelPaymentCreated(data: any, ): Promise<any> {
        const options: any = {
            priority: "high",
            timeToLive: 60 * 60,
        };
        const payload: any = {
            notification: {
                title: `Stokvel Payment added to Network`,
                body: '',
            },
            data: {
                type: 'stokvelPayment'
            },
        };
        const topic = 'stokvelPayments';
        const result = await msg.sendToTopic(topic, payload, options);
        console.log(
            `😍 stokvelPayment created: FCM message sent: 😍 topic: ${topic} : result: 🍎🍎 ${JSON.stringify(result)} 🍎🍎`,
        );
        return result
    }
    public static async sendMemberPaymentCreated(data: any, ): Promise<any> {
        const options: any = {
            priority: "high",
            timeToLive: 60 * 60,
        };
        const payload: any = {
            notification: {
                title: `Member Payment added to Network`,
                body: '',
            },
            data: {
                type: 'memberPayment'
            },
        };
        const topic = 'memberPayments';
        const result = await msg.sendToTopic(topic, payload, options);
        console.log(
            `😍 memberPayment created: FCM message sent: 😍 topic: ${topic} : result: 🍎🍎 ${JSON.stringify(result)} 🍎🍎`,
        );
        return result
    }
   
}

export default Messaging