
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
                body: `${data.name}`,
            },
            data: {
                type: 'stokvel',
                stokvel: JSON.stringify(data)
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
                title: data.stokvel`Member added to Network`,
                body: `${data.name}`,
            },
            data: {
                type: 'memberCreate',
                member: JSON.stringify(data)
            },
        };
        const topic = 'members';
        const result = await msg.sendToTopic(topic, payload, options);
        console.log(
            `🎽 🎽  member created: FCM message sent: 😍 topic: ${topic} : result: 🍎🍎 ${JSON.stringify(result)} 🍎🍎`,
        );
        return result
    }
    public static async sendMemberUpdated(data: any, ): Promise<any> {
        const ids = data.stokvelIds
        const length = ids.length
        const stokvelId = data.stokvelIds[length - 1]
        const options: any = {
            priority: "high",
            timeToLive: 60 * 60,
        };
        const payload: any = {
            notification: {
                title: `Member added to Stokvel`,
                body: `${data.name}`,
            },
            data: {
                type: 'memberUpdate',
                member: JSON.stringify(data)
            },
        };
        const topic = `members_${stokvelId}`;
        const result = await msg.sendToTopic(topic, payload, options);
        console.log(
            `🎽 🎽  member updated: FCM message sent: 😍 topic: ${topic} : result: 🍎🍎 ${JSON.stringify(result)} 🍎🍎`,
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
                title: `Stokvel Payment processed on Network`,
                body: `${data.stokvel.name}`,
            },
            data: {
                type: 'stokvelPayment',
                stokvelPayment: JSON.stringify(data)
            },
        };
        const topic = `stokvelPayments_${data.stokvel.stokvelId}`;
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
                body: `${data.fromMember.name} to ${data.toMember.name}`,
            },
            data: {
                type: 'memberPayment',
                memberPayment: JSON.stringify(data)
            },
        };
        const fromToken = data.fromMember.fcmToken
        const toToken = data.toMember.fcmToken
        if (fromToken) {
            const result1 = await msg.sendToDevice(fromToken, payload, options)
            console.log(
                `😍 memberPayment created: FCM message sent: 😍 result: 🍎🍎 ${JSON.stringify(result1)} 🍎🍎`)
        }
        if (toToken) {
            const result2 = await msg.sendToDevice(toToken, payload, options)
        console.log(
            `😍 memberPayment created: FCM message sent: 😍 result: 🍎🍎 ${JSON.stringify(result2)} 🍎🍎`)
        }
        
        
        return 0
    }
   
}

export default Messaging