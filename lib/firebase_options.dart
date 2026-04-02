// lib/firebase_options.dart
// ---------------------------------------------------------------
// REPLACE the values below with your real Firebase project config.
// Get them from: Firebase Console → Project Settings → Your Apps
// → Add Android app → download google-services.json
// OR run: flutterfire configure --project=YOUR_PROJECT_ID
// ---------------------------------------------------------------

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ── REPLACE THESE VALUES ──────────────────────────────────────

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD_eqUTfRBAKcohgGoZkTfNZra_Sgtb3u4',
    appId: '1:1040932287542:android:d2e38e12dc3fef50e21497',
    messagingSenderId: '1040932287542',
    projectId: 'gcloud-swag',
    storageBucket: 'gcloud-swag.firebasestorage.app',
  );

  // From Firebase Console → Project Settings → General → Your apps

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: '1:000000000000:ios:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosClientId: 'YOUR_IOS_CLIENT_ID',
    iosBundleId: 'com.example.swagAdminApp',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: '1:000000000000:web:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
  );
}