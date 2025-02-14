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
    apiKey: 'AIzaSyDBiHwWT6M4zyyArjViPLz3KGeTtuOeOpc',
    appId: '1:621812118549:web:070dd0ae22d7b819f3ca1c',
    messagingSenderId: '621812118549',
    projectId: 'plansanearapp',
    authDomain: 'plansanearapp.firebaseapp.com',
    storageBucket: 'plansanearapp.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyByKp1pGvh_-T8E3Tco0tuzUK6VNWTZR_8',
    appId: '1:621812118549:android:04a10df339d5ece0f3ca1c',
    messagingSenderId: '621812118549',
    projectId: 'plansanearapp',
    storageBucket: 'plansanearapp.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCscsa9JeJpT0ugtEgUfrv74otb7T7c4ls',
    appId: '1:621812118549:ios:b00c143c147c24b8f3ca1c',
    messagingSenderId: '621812118549',
    projectId: 'plansanearapp',
    storageBucket: 'plansanearapp.firebasestorage.app',
    iosBundleId: 'com.br.app.redeplansanea',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCscsa9JeJpT0ugtEgUfrv74otb7T7c4ls',
    appId: '1:621812118549:ios:b00c143c147c24b8f3ca1c',
    messagingSenderId: '621812118549',
    projectId: 'plansanearapp',
    storageBucket: 'plansanearapp.firebasestorage.app',
    iosBundleId: 'com.br.app.redeplansanea',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDBiHwWT6M4zyyArjViPLz3KGeTtuOeOpc',
    appId: '1:621812118549:web:e779906878b8ee40f3ca1c',
    messagingSenderId: '621812118549',
    projectId: 'plansanearapp',
    authDomain: 'plansanearapp.firebaseapp.com',
    storageBucket: 'plansanearapp.firebasestorage.app',
  );
}
