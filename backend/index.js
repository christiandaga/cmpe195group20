const admin = require('firebase-admin');
const serviceAccount = require('./ServiceAccountKey.json');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const usersDb = db.collection('users');

function createContact(firstname, lastname, phonenumber){
    usersDb.doc('contact').set({
        first: firstname,
        last: lastname,
        number: phonenumber
    })
}