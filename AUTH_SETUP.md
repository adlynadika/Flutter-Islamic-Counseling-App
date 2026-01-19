Firebase Auth setup (Google sign-in + Email/Password)

1) In the Firebase Console (project matching `google-services.json`):
   - Go to Authentication → Sign-in method
   - Enable **Email/Password** (for sign up with email)
   - Enable **Google** sign-in

2) For Android Google Sign-in to work correctly:
   - Add your app's **SHA-1** and **SHA-256** fingerprints to your Android app in Firebase settings.
   - To get the SHA, run in the Android project directory:
     - `.
android\gradlew signingReport` (on Windows PowerShell run from `android` folder)
   - Copy the `Variant: debug` SHA-1 and add it to Firebase.
   - After adding the SHA, re-download the `google-services.json` and replace `android/app/google-services.json` in this project.

3) For iOS or Web additional steps are required (APNs, OAuth client config). See Firebase docs:
   - https://firebase.google.com/docs/auth

4) Testing notes:
   - Email/password sign up and sign in works out-of-the-box after enabling the provider.
   - Google sign-in requires the SHA-1 (Android) and correct OAuth client in Firebase.
   - If Google sign-in fails with `DEVELOPER_ERROR` or similar, double-check the SHA and `google-services.json`.

If you want, I can add an integration test or run the app locally and walk through sign-in with you.