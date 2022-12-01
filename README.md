# CMPE 195 Group 20 Repository

## Usage

Download [SafeStreets.apk](https://github.com/christiandaga/cmpe195group20/releases/latest/download/SafeStreets.apk) and install to android device of choice. To setup your own project, follow steps below.

Demo: <https://youtu.be/SQFB_uXaB_Y>

___

## Firebase Backend

### Structure

```text
.backend
|   firebase.json # Firebase Config
|   
\---functions # Source Code
        index.js # checkTrips Function
        package.json # Dependencies
```

### Requirements

- Install [Node](https://nodejs.org/en/)

- Setup [Firebase](https://firebase.google.com/)

- Install [Firebase CLI](https://firebase.google.com/docs/cli)

### To Deploy

- From `backend` directory, install dependencies

```bash
npm install
```

- Navigate to `messaging/functions`, install dependencies

```bash
cd messaging/functions
npm install
```

- Deploy Function to Firebase

```bash
firebase deploy --only functions
```

## Frontend Mobile App

### Structure

```text
.frontend
|   pubspec.yaml # Dependencies
|       
+---android # Android build files
|               
+---assets
|   |   sampleData.json # Static streetlight and bluelight data
|   |   streetLightData.json
|   |   
|   +---icon
|   |       icon.png
|   |       
|   \---images
|           phone.png
|                                   
+---ios # IOS build files
|               
+---lib # Source Code
|   |   app.dart # Main App
|   |   config.dart
|   |   main.dart # Entry Point
|   |   
|   +---models
|   |       trip.dart
|   |       
|   +---screens
|   |       home.dart
|   |       settings.dart
|   |       
|   +---utils
|   |       api.dart
|   |       contact_controller.dart
|   |       
|   \---widgets
|           contacts_form.dart
|           layout.dart
|           map.dart
```

### Requirements

- Setup Flutter. <https://docs.flutter.dev/get-started/install>

- From `frontend` directory, install dependencies

```bash
flutter pub get
```

- Configure Firebase for Flutter. Follow Steps 1 and 2 from <https://firebase.google.com/docs/flutter/setup?platform=android>

### To Run

- Launch emulator of choice or connect device

- Launch from debug panel in VSCode, or

```bash
flutter run
```
