import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_clone_driver_app/global/global_var.dart';
import 'package:uber_clone_driver_app/models/road_information.dart';

import '../models/direction_details.dart';
import 'package:http/http.dart' as http;

class CommonMethods {
  checkConnectivity(BuildContext context) async {
    var connectionResult = await Connectivity().checkConnectivity();
    if (connectionResult != ConnectivityResult.mobile &&
        connectionResult != ConnectivityResult.wifi) {
      if (!context.mounted) return;
      displaySnackBar(
          'your Internet is not available. Check your connection. Try Again',
          context);
    }
  }

  displaySnackBar(String messageText, BuildContext context) {
    var snackBar = SnackBar(content: Text(messageText));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  turnOffLocationUpdatesForHomePage() {
    positionStreamHomePage!.pause();
    Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);
  }

  turnOnLocationUpdatesForHomePage() {
    positionStreamHomePage!.resume();
    Geofire.setLocation(FirebaseAuth.instance.currentUser!.uid,
        driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
  }

  //directions API1
  static Future<DirectionDetails?> getDirectionDetailsFromAPI(
      LatLng source, LatLng destination) async {
    String urlDirectionsAPI =
        "https://routing.openstreetmap.de/routed-car/route/v1/driving/${destination.longitude},${destination.latitude};${source.longitude},${source.latitude}?alternatives=false&overview=full&steps=true";
    //String urlDirectionsAPI = "https://routing.openstreetmap.de/routed-car/route/v1/driving/46.6487000000,61.2356967000;46.6491476000,61.2354754000?alternatives=false&overview=full&steps=true";
    print(urlDirectionsAPI);
    Map<String, dynamic> responseFromDirectionsAPI =
        await sendRequestToAPI(urlDirectionsAPI);

    if (responseFromDirectionsAPI == "error") {
      return null;
    }
    DirectionDetails detailsModel = DirectionDetails();
    num du=responseFromDirectionsAPI['routes'][0]['duration'];
    double duration=du.toDouble();
    duration=duration/60;
    detailsModel.durationTextString =
        '${duration.toStringAsFixed(1)} мин.';
    num d=(responseFromDirectionsAPI['routes'][0]['distance']);
    double distance=d.toDouble();
    distance=distance/1000;
    detailsModel.distanceTextString= '${distance.toStringAsFixed(2)} км';
    detailsModel.distanceValueDigits=distance;
    detailsModel.durationValueDigits=duration;

    return detailsModel;
  }

  static sendRequestToAPI(String apiUrl) async {
    http.Response responseFromAPI = await http.get(Uri.parse(apiUrl));

    try {
      if (responseFromAPI.statusCode == 200) {
        String dataFromApi = responseFromAPI.body;
        var dataDecoded = jsonDecode(dataFromApi);
        return dataDecoded;
      } else {
        return "error";
      }
    } catch (errorMsg) {
      return "error";
    }
  }

  calculateFareAmount(DirectionDetails directionDetails) {
    double distancePerKmAmount = 0.4;
    double durationPerMinuteAmount = 0.3;
    double baseFareAmount = 2;

    double totalDistanceTravelFareAmount = (directionDetails
        .distanceValueDigits! / 100) * distancePerKmAmount;
    double totalDurationSpendFareAmount = (directionDetails
        .durationValueDigits! / 60) * durationPerMinuteAmount;

    double overAllTotalFareAmount = baseFareAmount +
        totalDistanceTravelFareAmount + totalDurationSpendFareAmount;

    return overAllTotalFareAmount.toStringAsFixed(2);
  }


  }
