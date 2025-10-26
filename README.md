# LocalConnect - Local Business Directory App

A Flutter application that helps small-scale businesses connect with nearby customers. Built with Firebase backend and modern UI/UX design.

## Features

- 🔐 **Firebase Authentication** - Email/password login and registration
- 🏪 **Business Directory** - Browse local businesses by category and location
- ❤️ **Favorites System** - Save favorite businesses for quick access
- 📱 **Modern UI** - Clean, minimalistic design with smooth animations
- 🔍 **Search & Filter** - Find businesses by name, category, or location
- 📞 **Contact Integration** - Call or WhatsApp businesses directly
- 📸 **Image Upload** - Business owners can upload photos
- 🌐 **Responsive** - Works on mobile and web platforms

## Tech Stack

- **Frontend**: Flutter 3.9+
- **Backend**: Firebase (Auth, Firestore, Storage)
- **State Management**: Provider
- **UI Framework**: Material Design 3
- **Font**: Poppins (via Google Fonts)

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── business_model.dart  # Data models
├── providers/
│   └── business_provider.dart # State management
├── services/
│   ├── firebase_service.dart # Firebase integration
│   ├── dummy_data.dart       # Sample data
│   └── firebase_config.dart  # Firebase configuration
├── screens/
│   ├── splash_screen.dart    # App launch screen
│   ├── login_screen.dart     # Authentication
│   ├── home_screen.dart      # Main dashboard
│   ├── business_details_screen.dart
│   ├── add_business_screen.dart
│   ├── favorites_screen.dart
│   └── profile_screen.dart
├── widgets/
│   └── business_card.dart    # Reusable components
└── theme/
    └── app_theme.dart        # App styling
```

## Setup Instructions

### 1. Prerequisites

- Flutter SDK 3.9 or higher
- Dart SDK 3.0 or higher
- Firebase account
- Android Studio / VS Code with Flutter extensions

### 2. Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project called "localconnect"
3. Enable the following services:
   - **Authentication** (Email/Password)
   - **Firestore Database**
   - **Storage**

4. Add your app to the project:
   - For Android: Add Android app and download `google-services.json`
   - For iOS: Add iOS app and download `GoogleService-Info.plist`
   - For Web: Add Web app and get configuration

5. Place configuration files:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`

### 3. Firestore Rules

Set up Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /businesses/{businessId} {
      allow read: if true;
      allow write: if request.auth != null && 
        (request.auth.uid == resource.data.ownerId || 
         request.auth.uid == request.resource.data.ownerId);
    }
  }
}
```

### 4. Storage Rules

Set up Firebase Storage rules:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /business_images/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

### 5. Install Dependencies

```bash
cd connect
flutter pub get
```

### 6. Run the App

```bash
flutter run
```

## Usage

### For Customers:
1. **Sign Up/Login** - Create an account or sign in
2. **Browse Businesses** - View businesses by category or search
3. **View Details** - Tap on business cards to see full information
4. **Contact** - Call or WhatsApp businesses directly
5. **Save Favorites** - Heart businesses you like for quick access

### For Business Owners:
1. **Sign Up** - Create an account
2. **Add Business** - Use the floating action button to list your business
3. **Upload Image** - Add a photo of your business
4. **Manage Listing** - Update business information anytime

## Color Scheme

- **Primary**: #2953A6 (Blue)
- **Secondary**: #FFD966 (Yellow)
- **Background**: #F5F5F5 (Light Gray)
- **Surface**: #FFFFFF (White)
- **Text**: #232F34 (Dark Gray)

## Sample Data

The app includes sample business data for testing. You can find it in `lib/services/dummy_data.dart`.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For support or questions, please open an issue in the repository.

---

**LocalConnect** - Connecting local businesses with their communities! 🏪✨