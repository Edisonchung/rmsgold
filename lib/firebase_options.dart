// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Demo configuration - Replace with your actual Firebase config
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:123456789:web:demo-app-id',
    messagingSenderId: '123456789',
    projectId: 'rmsgold-demo',
    authDomain: 'rmsgold-demo.firebaseapp.com',
    storageBucket: 'rmsgold-demo.appspot.com',
    measurementId: 'G-DEMO123456',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'demo-android-api-key',
    appId: '1:123456789:android:demo-app-id',
    messagingSenderId: '123456789',
    projectId: 'rmsgold-demo',
    storageBucket: 'rmsgold-demo.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'demo-ios-api-key',
    appId: '1:123456789:ios:demo-app-id',
    messagingSenderId: '123456789',
    projectId: 'rmsgold-demo',
    storageBucket: 'rmsgold-demo.appspot.com',
    iosBundleId: 'com.rmsgold.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'demo-macos-api-key',
    appId: '1:123456789:macos:demo-app-id',
    messagingSenderId: '123456789',
    projectId: 'rmsgold-demo',
    storageBucket: 'rmsgold-demo.appspot.com',
    iosBundleId: 'com.rmsgold.app',
  );
}
