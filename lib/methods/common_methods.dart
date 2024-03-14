import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_clone_driver_app/global/global_var.dart';

import '../models/direction_details.dart';

class CommonMethods {
  checkConnectivity(BuildContext context) async {
    var connectionResult = await Connectivity().checkConnectivity();
    if (connectionResult != ConnectivityResult.mobile &&
        connectionResult != ConnectivityResult.wifi) {
      if(!context.mounted) return;
      displaySnackBar(
          'your Internet is not available. Check your connection. Try Again',
          context);
    }
  }

  displaySnackBar(String messageText, BuildContext context) {
    var snackBar = SnackBar(content: Text(messageText));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  turnOffLocationUpdatesForHomePage(){
    positionStreamHomePage!.pause();
    Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);
  }

  turnOnLocationUpdatesForHomePage(){
    positionStreamHomePage!.resume();
    Geofire.setLocation(FirebaseAuth.instance.currentUser!.uid,
    driverCurrentPosition!.latitude,driverCurrentPosition!.longitude);
  }

  //directions API1
  static Future<DirectionDetails> getDirectionDetailsFromAPI(LatLng source,LatLng destination,MapController controller)async{

    RoadInfo roadInfo = await controller.drawRoad(
      GeoPoint(latitude: source.latitude, longitude: source.longitude),
      GeoPoint(latitude: destination.latitude, longitude: destination.longitude),
      roadType: RoadType.car,
    );
    print('Расстояние: ${roadInfo.distance}, длительность ${roadInfo.duration}');
    return DirectionDetails(distanceTextString: '${roadInfo.distance!.toStringAsFixed(2)} км',durationTextString: '${(roadInfo.duration!/60).toStringAsFixed(2)} мин.',distanceValueDigits: 15,durationValueDigits: 5,encodedPoints: 'points');
  }





}


