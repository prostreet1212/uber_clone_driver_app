import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationSystem {
  FirebaseMessaging firebaseCloudMessaging = FirebaseMessaging.instance;

  Future<String?> generateDeviceRegistrationToken() async {
    String? deviceRecognitionToken = await firebaseCloudMessaging.getToken();
    DatabaseReference referenceOnlineDriver = FirebaseDatabase.instance
        .ref()
        .child('drivers')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('deviceToken');
    referenceOnlineDriver.set(deviceRecognitionToken);
    firebaseCloudMessaging.subscribeToTopic('drivers');
    firebaseCloudMessaging.subscribeToTopic('users');
  }

  startListeningForNewNotification()async{
    //1. Terminated
    firebaseCloudMessaging.getInitialMessage().then((messageRemote){
      if(messageRemote!=null){
        String tripID=messageRemote.data['tripID'];
      }
    });

    //2. Foreground
    FirebaseMessaging.onMessage.listen((messageRemote) {
      if(messageRemote!=null){
        String tripID=messageRemote.data['tripID'];
      }
    });
    //3. Background
    FirebaseMessaging.onMessageOpenedApp.listen((messageRemote) {
      if(messageRemote!=null){
        String tripID=messageRemote.data['tripID'];
      }
    });

  }

}
