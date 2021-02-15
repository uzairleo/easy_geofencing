import 'dart:async';
import 'package:easy_geofencing/easy_geofencing.dart';
import 'package:easy_geofencing/enums/geofence_status.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

///
///This is an [example] app for testing the [EasyGeofencing] dart package
///that is purely written in dart
///
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easy Geofencing',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Easy Geofencing'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController latitudeController = new TextEditingController();
  TextEditingController longitudeController = new TextEditingController();
  TextEditingController radiusController = new TextEditingController();
  StreamSubscription<GeofenceStatus> geofenceStatusStream;
  Geolocator geolocator = Geolocator();
  String geofenceStatus = '';
  bool isReady = false;
  Position position;
  @override
  void initState() {
    super.initState();
    getCurrentPosition();
  }

  getCurrentPosition() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print("LOCATION => ${position.toJson()}");
    isReady = (position != null) ? true : false;
  }

  setLocation() async {
    await getCurrentPosition();
    latitudeController =
        new TextEditingController(text: position.latitude.toString());
    longitudeController =
        new TextEditingController(text: position.longitude.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.my_location),
            onPressed: () {
              if (isReady) {
                setState(() {
                  setLocation();
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: latitudeController,
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: 'Enter pointed latitude'),
            ),
            TextField(
              controller: longitudeController,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter pointed longitude'),
            ),
            TextField(
              controller: radiusController,
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: 'Enter radius in meter'),
            ),
            SizedBox(
              height: 60,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton(
                  child: Text("Start"),
                  onPressed: () {
                    print("starting geoFencing Service");
                    EasyGeofencing.startGeofenceService(
                        pointedLatitude: latitudeController.text,
                        pointedLongitude: longitudeController.text,
                        radiusMeter: radiusController.text,
                        eventPeriodInSeconds: 5);
                    if (geofenceStatusStream == null) {
                      geofenceStatusStream = EasyGeofencing.getGeofenceStream()
                          .listen((GeofenceStatus status) {
                        print(status.toString());
                        setState(() {
                          geofenceStatus = status.toString();
                        });
                      });
                    }
                  },
                ),
                SizedBox(
                  width: 10.0,
                ),
                RaisedButton(
                  child: Text("Stop"),
                  onPressed: () {
                    print("stop");
                    EasyGeofencing.stopGeofenceService();
                    geofenceStatusStream.cancel();
                  },
                ),
              ],
            ),
            SizedBox(
              height: 100,
            ),
            Text(
              "Geofence Status: \n\n\n" + geofenceStatus,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    latitudeController.dispose();
    longitudeController.dispose();
    radiusController.dispose();
    super.dispose();
  }
}
