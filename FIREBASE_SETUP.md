# 🔥 Firebase Setup Guide for LocalConnect

## **Step 1: Enable Firebase Authentication**

1. **Go to Firebase Console**: https://console.firebase.google.com/
2. **Select your project**: `connect-9b9e2`
3. **Navigate to Authentication**:
   - Click on "Authentication" in the left sidebar
   - Click "Get started" if you haven't set it up yet

## **Step 2: Configure Sign-in Methods**

1. **Go to Sign-in method tab**
2. **Enable Email/Password**:
   - Click on "Email/Password"
   - Toggle "Enable" for the first option (Email/Password)
   - Click "Save"

## **Step 3: Configure Firestore Database**

1. **Go to Firestore Database**
2. **Create database**:
   - Click "Create database"
   - Choose "Start in test mode" (for development)
   - Select a location (choose closest to you)

## **Step 4: Configure Firebase Storage**

1. **Go to Storage**
2. **Get started**:
   - Click "Get started"
   - Choose "Start in test mode"
   - Select same location as Firestore

## **Step 5: Configure Authentication Settings**

1. **Go to Authentication > Settings**
2. **Add authorized domains**:
   - Add `localhost` for local development
   - Add your production domain when you deploy

## **Step 6: Test Your Setup**

After completing the above steps:

1. **Run the app**: `flutter run -d chrome`
2. **Try to sign up** with a test email
3. **Check Firebase Console** to see if the user was created

## **Common Issues & Solutions**

### ❌ **Error: `[firebase_auth/configuration-not-found]`**
**Solution**: Authentication is not enabled. Follow Step 1 & 2 above.

### ❌ **Error: `[firebase_auth/invalid-email]`**
**Solution**: Check if the email format is valid.

### ❌ **Error: `[firebase_auth/weak-password]`**
**Solution**: Password must be at least 6 characters.

### ❌ **Error: `[firebase_auth/email-already-in-use]`**
**Solution**: Email is already registered. Try signing in instead.

## **Database Structure**

Your Firestore will have these collections:

```
/users/{userId}
  - name: string
  - email: string
  - favorites: array of business IDs
  - createdAt: timestamp

/businesses/{businessId}
  - ownerId: string
  - name: string
  - category: string
  - location: string
  - description: string
  - contact: string
  - imageUrl: string (optional)
  - rating: number
  - reviewCount: number
  - isActive: boolean
  - createdAt: timestamp
```

## **Security Rules (Optional)**

For production, update your Firestore rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Anyone can read businesses, only owners can write
    match /businesses/{businessId} {
      allow read: if true;
      allow write: if request.auth != null && 
        (request.auth.uid == resource.data.ownerId || 
         request.auth.uid == request.resource.data.ownerId);
    }
  }
}
```

## **Next Steps**

1. ✅ Complete Firebase setup
2. ✅ Test authentication
3. ✅ Add some test businesses
4. ✅ Test all features

---

**Need Help?** Check the Firebase documentation: https://firebase.google.com/docs
