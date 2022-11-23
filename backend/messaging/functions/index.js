const functions = require("firebase-functions");

const twillio_sid = functions.config().config.twillio_sid
const twillio_token = functions.config().config.twillio_auth_token
const client = require('twilio')(twillio_sid, twillio_token);
var PNF = require('google-libphonenumber').PhoneNumberFormat;
var phoneUtil = require('google-libphonenumber').PhoneNumberUtil.getInstance();

const { initializeApp, applicationDefault, cert } = require('firebase-admin/app');
const { getFirestore, Timestamp, FieldValue } = require('firebase-admin/firestore');

initializeApp();
const db = getFirestore();

const sendMessage = async (phone_number, message, country="US") => {
  // Format and validate phone_number is in E164 format.
  let tel = phoneUtil.parse(phone_number, country);
  phone_number = phoneUtil.format(tel, PNF.E164);

  let response = await client.messages.create({ 
     body: message,  
     messagingServiceSid: 'MG5670dfb1d4ed1b4dbdd10d779347a236',      
     to: phone_number 
   }) 
}

exports.checkTrips = functions.pubsub.schedule('every 1 minutes').onRun(async (context) => {
    const tripsRef = db.collection('trip');
    const snapshot = await tripsRef.get();
    if (snapshot.empty) {
        console.log('No matching documents.');
        return;
    }  
      
    snapshot.forEach(doc => {
        let contact = doc.data().contact;
        let eta = doc.data().eta;
        if(!doc.data().tripStartedMsgSent){
            let message = "ALERT: " + contact.user + " started a route to " + doc.data().route.address + ". Their ETA is " + eta.toDate().toLocaleTimeString("en-US");
            sendMessage(contact.number, message);
            db.collection("trip").doc(doc.id).update({tripStartedMsgSent: 1});
        }

        let currentTime = Timestamp.now();
        if(eta < currentTime && !doc.data().msgSent){
            let message = "ALERT: " + contact.user + " did not reach " + doc.data().route.address + " by their ETA.\nThey were expected to arrive by " + eta.toDate().toLocaleTimeString("en-US");
            sendMessage(contact.number, message);
            db.collection("trip").doc(doc.id).update({msgSent: 1});
        }
    });

});