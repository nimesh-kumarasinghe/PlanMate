# 📱 PlanMate – Group Activity Organizer for iOS

**PlanMate** is an iOS app built to simplify planning group activities by helping users coordinate schedules, propose venues, and sync events with their device calendar. The app includes group-based planning, event chats, and offline support for a seamless experience.

---

## 🚀 Features

### 🔐 Authentication
- Sign in via Email/Password or Google
- Face ID / Touch ID for secure and fast access

### 👥 Group Management
- Create, join (via code or QR), edit, and leave groups
- Customizable group name, image, and description
- Images stored in Firebase Storage

### 📌 Activity Planning
- Propose group activities with multiple venue suggestions
- Members vote on available times and preferred locations

### 🗓️ Event Scheduling
- Create events based on group availability
- Add title, date, time, location, notes, links, and reminders
- Assign tasks to members
- Sync events with the device’s calendar using EventKit

### 💬 In-App Messaging
- Each event has its own chat thread for group discussions

### 🧑‍💼 Profile Management
- Edit name and profile picture
- Delete account if needed

### 🔔 Notifications
- Local push notifications for event updates, proposals, and reminders
- Notification settings managed in-app

### 📶 Offline Support
- Core Data used for offline access to essential data
- Syncs with Firebase when online

---

## 🧰 Tech Stack

- **Language & UI**: Swift + SwiftUI (MVVM architecture)
- **Authentication**: FirebaseAuth + Google Sign-In + Face ID/Touch ID
- **Backend Database**: Firebase Firestore (NoSQL)
- **Storage**: Firebase Storage for user and group images
- **Local Storage**: Core Data for offline support
- **Calendar Integration**: EventKit for syncing events with device calendar
- **Maps & Location**: MapKit for selecting venues, nearby searches, and navigation
- **Notifications**: Apple Local Push Notifications

---

## 🛠 Development Workflow

1. **Planning & Design**
   - Defined features based on common group planning needs
   - Created wireframes and prototypes with focus on iOS UI standards

2. **UI Implementation**
   - Built screen views using SwiftUI
   - Followed MVVM pattern for maintainable architecture

3. **Core Functionality**
   - Integrated Firebase for real-time data and authentication
   - Built group creation, joining, activity proposing, voting, and event management
   - Implemented profile management and settings

4. **Advanced Integration**
   - **EventKit**: Calendar sync to avoid availability conflicts
   - **MapKit**: Venue selection with nearby search and directions
   - **Core Data**: Offline data caching and sync logic
   - **Face ID / Touch ID**: Biometric authentication using Apple Keychain
   - **Local Notifications**: In-app scheduling for important updates

---

## 📂 Project Structure Highlights

```
PlanMate/
├── Views/               # SwiftUI views
├── ViewModels/          # Business logic (MVVM)
├── Models/              # Data models
├── Services/
│   ├── FirebaseManager.swift
│   ├── EventKitManager.swift
│   ├── MapKitManager.swift
│   └── BiometricManager.swift
├── CoreData/            # Core Data stack
├── Assets/              # Images, Colors, etc.
└── Utilities/           # Helpers and extensions
```

---

## 🧪 Dependencies

- Firebase (Auth, Firestore, Storage)
- GoogleSignIn
- MapKit
- EventKit
- SwiftUI
- CoreData



