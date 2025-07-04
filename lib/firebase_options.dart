// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCJnlgn1oP3-LciR6f8NV6q7ioZ9Hhhlyw',
    appId: '1:289178375634:web:bd8414dd1959598ab2e40b',
    messagingSenderId: '289178375634',
    projectId: 'sikancil-apps',
    authDomain: 'sikancil-apps.firebaseapp.com',
    storageBucket: 'sikancil-apps.firebasestorage.app',
    measurementId: 'G-4GF305M2MQ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCN_eeIEIxpNlKF4a9Xq2Jqjmk6QDNsVoE',
    appId: '1:289178375634:android:03ce6b8f8530bc4cb2e40b',
    messagingSenderId: '289178375634',
    projectId: 'sikancil-apps',
    storageBucket: 'sikancil-apps.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyClFU99sGzdoGnSDcfKamxN4nFKXCbCKjs',
    appId: '1:289178375634:ios:4ec8e7910d43e038b2e40b',
    messagingSenderId: '289178375634',
    projectId: 'sikancil-apps',
    storageBucket: 'sikancil-apps.firebasestorage.app',
    iosBundleId: 'com.example.sikancil',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyClFU99sGzdoGnSDcfKamxN4nFKXCbCKjs',
    appId: '1:289178375634:ios:4ec8e7910d43e038b2e40b',
    messagingSenderId: '289178375634',
    projectId: 'sikancil-apps',
    storageBucket: 'sikancil-apps.firebasestorage.app',
    iosBundleId: 'com.example.sikancil',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCJnlgn1oP3-LciR6f8NV6q7ioZ9Hhhlyw',
    appId: '1:289178375634:web:c42669fd02581987b2e40b',
    messagingSenderId: '289178375634',
    projectId: 'sikancil-apps',
    authDomain: 'sikancil-apps.firebaseapp.com',
    storageBucket: 'sikancil-apps.firebasestorage.app',
    measurementId: 'G-QLBEK2GXX9',
  );
}
