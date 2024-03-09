

import 'dart:async';

//import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:just_audio/just_audio.dart';


String userName='';
String googleMapKey='AIzaSyBPq2bCfprMYNLBgL_1u4cLmJIZitUrMPw';
 const CameraPosition googlePlexInitialPosition = CameraPosition(
  target: LatLng(37.42796133580664, -122.085749655962),
  zoom: 14.4746,
);
 StreamSubscription<Position>? positionStreamHomePage;
 int driverTripRequestTimeout=20;

final player1 = AudioPlayer();



