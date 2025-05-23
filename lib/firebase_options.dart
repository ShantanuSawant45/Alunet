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
    apiKey: 'AIzaSyCPmwwtK7CLtRZKGKxqEFhENrHZSq-snI4',
    appId: '1:160513777062:web:c6ba3f45d415230cc90367',
    messagingSenderId: '160513777062',
    projectId: 'alunet-60077',
    authDomain: 'alunet-60077.firebaseapp.com',
    storageBucket: 'alunet-60077.firebasestorage.app',
    measurementId: 'G-JXKWP9GD6H',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBJLQVpbSgCG_ncLPi8_6YfOGwl1mHBnwg',
    appId: '1:160513777062:android:08d65070f0872e6ac90367',
    messagingSenderId: '160513777062',
    projectId: 'alunet-60077',
    storageBucket: 'alunet-60077.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDPwQwYwHtmxFVNJIDMrmgMdPyCWf2p4_w',
    appId: '1:160513777062:ios:c426007c8431ac7ac90367',
    messagingSenderId: '160513777062',
    projectId: 'alunet-60077',
    storageBucket: 'alunet-60077.firebasestorage.app',
    iosBundleId: 'com.example.dbmsProject',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDPwQwYwHtmxFVNJIDMrmgMdPyCWf2p4_w',
    appId: '1:160513777062:ios:c426007c8431ac7ac90367',
    messagingSenderId: '160513777062',
    projectId: 'alunet-60077',
    storageBucket: 'alunet-60077.firebasestorage.app',
    iosBundleId: 'com.example.dbmsProject',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCPmwwtK7CLtRZKGKxqEFhENrHZSq-snI4',
    appId: '1:160513777062:web:ec6801d95d91080ec90367',
    messagingSenderId: '160513777062',
    projectId: 'alunet-60077',
    authDomain: 'alunet-60077.firebaseapp.com',
    storageBucket: 'alunet-60077.firebasestorage.app',
    measurementId: 'G-3K1LD79MCJ',
  );
}
