// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXX', // Replace with your API key
    authDomain: 'rmsgold.firebaseapp.com', // Replace with your domain
    projectId: 'rmsgold', // Replace with your project ID
    storageBucket: 'rmsgold.appspot.com', // Replace with your bucket
    messagingSenderId: '1234567890', // Replace with your sender ID
    appId: '1:1234567890:web:abcdef123456789', // Replace with your app ID
  );

  // Android and iOS configs (add later if needed)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'your-android-api-key',
    appId: 'your-android-app-id',
    messagingSenderId: '1234567890',
    projectId: 'rmsgold',
    storageBucket: 'rmsgold.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'your-ios-api-key',
    appId: 'your-ios-app-id',
    messagingSenderId: '1234567890',
    projectId: 'rmsgold',
    storageBucket: 'rmsgold.appspot.com',
    iosBundleId: 'com.rms.rmsgold',
  );
}
