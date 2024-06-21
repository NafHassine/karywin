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

  // Placeholder values
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'your_web_api_key_placeholder',
    appId: 'your_web_app_id_placeholder',
    messagingSenderId: 'your_web_messaging_sender_id_placeholder',
    projectId: 'your_web_project_id_placeholder',
    authDomain: 'your_web_auth_domain_placeholder',
    databaseURL: 'your_web_database_url_placeholder',
    storageBucket: 'your_web_storage_bucket_placeholder',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'your_android_api_key_placeholder',
    appId: 'your_android_app_id_placeholder',
    messagingSenderId: 'your_android_messaging_sender_id_placeholder',
    projectId: 'your_android_project_id_placeholder',
    databaseURL: 'your_android_database_url_placeholder',
    storageBucket: 'your_android_storage_bucket_placeholder',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'your_ios_api_key_placeholder',
    appId: 'your_ios_app_id_placeholder',
    messagingSenderId: 'your_ios_messaging_sender_id_placeholder',
    projectId: 'your_ios_project_id_placeholder',
    databaseURL: 'your_ios_database_url_placeholder',
    storageBucket: 'your_ios_storage_bucket_placeholder',
    iosBundleId: 'your_ios_bundle_id_placeholder',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'your_macos_api_key_placeholder',
    appId: 'your_macos_app_id_placeholder',
    messagingSenderId: 'your_macos_messaging_sender_id_placeholder',
    projectId: 'your_macos_project_id_placeholder',
    databaseURL: 'your_macos_database_url_placeholder',
    storageBucket: 'your_macos_storage_bucket_placeholder',
    iosBundleId: 'your_macos_bundle_id_placeholder',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'your_windows_api_key_placeholder',
    appId: 'your_windows_app_id_placeholder',
    messagingSenderId: 'your_windows_messaging_sender_id_placeholder',
    projectId: 'your_windows_project_id_placeholder',
    authDomain: 'your_windows_auth_domain_placeholder',
    databaseURL: 'your_windows_database_url_placeholder',
    storageBucket: 'your_windows_storage_bucket_placeholder',
  );
}
