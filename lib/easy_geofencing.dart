import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';

////
/// Geofence plugin class
class GeoFenceService {
  /// [ _positionStream ] is for getting stream position on location updates
  static StreamSubscription<Position> _positionStream;

  /// [_geostream] is for geofence event stream
  static Stream<GeofenceStatus> _geostream;

  /// [_controller] is Stream controller for geofence event stream
  static StreamController<GeofenceStatus> _controller =
      StreamController<GeofenceStatus>();

  /// Parser method which is basically for parsing [String] values
  /// to [double] values
  static double _parser(String value) {
    return double.parse(value);
  }

  /// For [getting geofence event stream] property which is basically returns [_geostream]
  static Stream<GeofenceStatus> getGeofenceStream() {
    return _geostream;
  }

  /// [startGeofenceService] To start the geofence service
  /// this method takes this required following parameters
  /// pointedLatitude is the latitude of geofencing area center which is [String] datatype
  /// pointedLongitude is the longitude of geofencing area center which is [String] datatype
  /// radiusMeter is the radius of geofencing area in meters
  /// radiusMeter takes value is in [String] datatype and
  /// eventPeriodInSeconds will determine whether the stream listener period in seconds
  /// eventPeriodInSeconds takes value in [int]
  /// The purpose of this method is to initialize and start the geofencing service.
  /// At first it will check location permission and if enabled then it will start listening the current location changes
  /// then calculate the distance of changes point to the allocated geofencing area points
  static startGeofenceService(
      {String pointedLatitude,
      String pointedLongitude,
      String radiusMeter,
      int eventPeriodInSeconds}) {
    double latitude = _parser(pointedLatitude);
    double longitude = _parser(pointedLongitude);
    double radiusInMeter = _parser(radiusMeter);
    if (_positionStream == null) {
      _geostream = _controller.stream;
      _positionStream = Geolocator.getPositionStream(
        desiredAccuracy: LocationAccuracy.high,
      ).listen((Position position) {
        print("Started Position $latitude  $longitude");
        print("Current Position ${position.toJson()}");
        double distanceInMeters = Geolocator.distanceBetween(
            latitude, longitude, position.latitude, position.longitude);
        print(
            "Distance in meters $distanceInMeters and Radius in Meter $radiusInMeter");
        _checkGeofence(distanceInMeters, radiusInMeter);
        _positionStream
            .pause(Future.delayed(Duration(seconds: eventPeriodInSeconds)));
      });
      _controller.add(GeofenceStatus.init);
    }
  }

  /// [_checkGeofence] is for checking whether current location is in
  /// or
  /// outside of the geofence area
  /// this takes two parameters which is [double] distanceInMeters
  /// distanceInMeters parameters is basically the calculated distance between
  /// geofence area points and the current location points
  /// radiusInMeter take value in [double] and it's the radius of geofence area in meters
  static _checkGeofence(double distanceInMeters, double radiusInMeter) {
    if (distanceInMeters <= radiusInMeter) {
      _controller.add(GeofenceStatus.enter);
    } else {
      _controller.add(GeofenceStatus.exit);
    }
  }

  /// [stopGeofenceService] to stop the geofencing service
  /// if the [_positionStream] is not null then
  /// it will cancel the subscription of the stream
  static stopGeofenceService() {
    if (_positionStream != null) {
      _positionStream.cancel();
    }
  }

  static distanceBetween(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}
