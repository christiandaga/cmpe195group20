require('dotenv').config();
const client = require('twilio')(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);

var PNF = require('google-libphonenumber').PhoneNumberFormat;
var phoneUtil = require('google-libphonenumber').PhoneNumberUtil.getInstance();

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

const startingRoute = (phone_number, name, expected_time, destination=None, country="US") => {
  let message;
  if(destination){
    message = "ALERT: " + name + " has started a route to " + destination + ". They are expected to arrive by " + expected_time;
  } else {
    message = "ALERT: " + name + " has started a route. They are expected to arrive by " + expected_time;
  }
  sendMessage(phone_number, message, country=country);
}

const reachedDestination = (phone_number, name, country="US") => {
  let message = "ALERT: " + name + " has reached their destination"
  sendMessage(phone_number, message, country=country);
}

const cancelledRoute = (phone_number, name, country="US") => {
  let message = "ALERT: " + name + " has canceled their route"
  sendMessage(phone_number, message, country=country);
}

const lateToDestination = (phone_number, name, expected_time, destination=None, country="US") => {
  let message;
  if(destination){
    message = "WARNING: " + name + " has not reached their destination by their ETA. They were expected to arrive at " + destination + " by " + expected_time;
  } else {
    message = "WARNING: " + name + " has not reached their destination by their ETA. They were expected to arrive by " + expected_time;
  }
  sendMessage(phone_number, message, country=country);
}

startingRoute("4159393125", "Cassidy", "5:00", "Home")
reachedDestination("4159393125", "Cassidy")
cancelledRoute("4159393125", "Cassidy")
lateToDestination("4159393125", "Cassidy", "5:00", "Home")