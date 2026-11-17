import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBGQBs4EXb2K45MgmXDLdLQkVHaDvqwlSs',
    appId: '1:1005777924050:android:29e00cad2c29632245620b',
    messagingSenderId: '1005777924050',
    projectId: 'task-db-346b7',
    storageBucket: 'task-db-346b7.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBGQBs4EXb2K45MgmXDLdLQkVHaDvqwlSs',
    appId: '1:1005777924050:web:dummy',
    messagingSenderId: '1005777924050',
    projectId: 'task-db-346b7',
    storageBucket: 'task-db-346b7.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBGQBs4EXb2K45MgmXDLdLQkVHaDvqwlSs',
    appId: '1:1005777924050:ios:dummy',
    messagingSenderId: '1005777924050',
    projectId: 'task-db-346b7',
    storageBucket: 'task-db-346b7.firebasestorage.app',
  );
}
