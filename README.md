# CMPE 195 Group 20 Repository

## Usage

Download [SafeStreets.apk](https://github.com/christiandaga/cmpe195group20/releases/latest/download/SafeStreets.apk) and install to android device of choice. To setup your own project, follow steps below.

___

## Firebase Backend

### Requirements

- Install [Node](https://nodejs.org/en/)

- Setup [Firebase](https://firebase.google.com/)

- Install [Firebase CLI](https://firebase.google.com/docs/cli)

### To Deploy

- From `backend` directory, install dependencies

```bash
npm install
```

- Navigate to `messaging/functions`, install depndencies

```bash
cd messaging/functions
npm install
```

- Deploy Function to Firebase

```bash
firebase deploy --only functions
```

## Frontend Mobile App

### Requirements

- Setup Flutter. <https://docs.flutter.dev/get-started/install>

- From `frontend` directory, install dependencies

```bash
flutter pub get
```

- Setup Firebase for Flutter. <https://firebase.google.com/docs/flutter/setup?platform=android>

### To Run

- Launch emulator of choice or connect device

- Launch from debug panel in VSCode, or

```bash
flutter run
```
