// Firebase Configuration Template
//
// To set up Firebase for your LocalConnect app:
//
// 1. Go to https://console.firebase.google.com/
// 2. Create a new project called "localconnect"
// 3. Enable Authentication, Firestore Database, and Storage
// 4. Add your app to the project
// 5. Download the configuration files:
//    - android/app/google-services.json (for Android)
//    - ios/Runner/GoogleService-Info.plist (for iOS)
//    - web/firebase-config.js (for Web)
//
// 6. Update the Firebase rules:
//
// Firestore Rules:
// rules_version = '2';
// service cloud.firestore {
//   match /databases/{database}/documents {
//     match /users/{userId} {
//       allow read, write: if request.auth != null && request.auth.uid == userId;
//     }
//     match /businesses/{businessId} {
//       allow read: if true;
//       allow write: if request.auth != null &&
//         (request.auth.uid == resource.data.ownerId ||
//          request.auth.uid == request.resource.data.ownerId);
//     }
//   }
// }
//
// Storage Rules:
// rules_version = '2';
// service firebase.storage {
//   match /b/{bucket}/o {
//     match /business_images/{allPaths=**} {
//       allow read: if true;
//       allow write: if request.auth != null;
//     }
//   }
// }
//
// Authentication:
// Enable Email/Password authentication in Firebase Console

class FirebaseConfig {
  // This is a placeholder class
  // Replace with actual Firebase configuration when setting up the project
  static const String projectId = 'your-project-id';
  static const String apiKey = 'your-api-key';
  static const String appId = 'your-app-id';
  static const String messagingSenderId = 'your-sender-id';
}
