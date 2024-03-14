import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:uber_clone_driver_app/global/global_var.dart';
import 'package:uber_clone_driver_app/models/trip_details.dart';
import 'package:uber_clone_driver_app/widgets/loading_dialog.dart';
import 'package:uber_clone_driver_app/widgets/notification_dialog.dart';

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

  startListeningForNewNotification(BuildContext context) async {
    //1. Terminated
    firebaseCloudMessaging.getInitialMessage().then((messageRemote) {
      if (messageRemote != null) {
        String tripID = messageRemote.data['tripID'];
        retrieveTripRequestInfo(tripID, context);
      }
    });

    //2. Foreground
    FirebaseMessaging.onMessage.listen((messageRemote) {
      if (messageRemote != null) {
        String tripID = messageRemote.data['tripID'];
        retrieveTripRequestInfo(tripID, context);
      }
    });
    //3. Background
    FirebaseMessaging.onMessageOpenedApp.listen((messageRemote) {
      if (messageRemote != null) {
        String tripID = messageRemote.data['tripID'];
        retrieveTripRequestInfo(tripID, context);
      }
    });
  }

  retrieveTripRequestInfo(tripID, context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => LoadingDialog(messageText: 'getting details...'));
    DatabaseReference tripRequestRef =
        FirebaseDatabase.instance.ref().child('tripRequests').child(tripID);
    tripRequestRef.once().then((dataSnapshot) async {
      Navigator.pop(context);
      //play notification sound
       player1.setAudioSource(AudioSource.asset('assets/sound/alert_sound.mp3'));// Create a player
      player1.play();


      TripDetails tripDetailsInfo = TripDetails();
      double pickUpLat = double.parse(
          (dataSnapshot.snapshot.value! as Map)['pickUpLatLng']['latitude']);
      double pickUpLng = double.parse(
          (dataSnapshot.snapshot.value! as Map)['pickUpLatLng']['longitude']);
      tripDetailsInfo.pickUpLatLng = LatLng(pickUpLat, pickUpLng);
      tripDetailsInfo.pickUpAddress =
          (dataSnapshot.snapshot.value! as Map)['pickUpAddress'];

      double dropOffLat = double.parse(
          (dataSnapshot.snapshot.value! as Map)['dropOffLatLng']['latitude']);
      double dropOffLng = double.parse(
          (dataSnapshot.snapshot.value! as Map)['dropOffLatLng']['longitude']);
      tripDetailsInfo.dropOffLatLng = LatLng(dropOffLat, dropOffLng);

      tripDetailsInfo.dropOffAddress =(dataSnapshot.snapshot.value! as Map)['dropOffAddress'];

      tripDetailsInfo.userName =(dataSnapshot.snapshot.value! as Map)['userName'];
      tripDetailsInfo.userPhone =(dataSnapshot.snapshot.value! as Map)['userPhone'];

      tripDetailsInfo.tripID=tripID;

      showDialog(
          context: context,
          builder: (context)=>NotificationDialog(tripDetailsInfo: tripDetailsInfo,));
    });
  }
}
