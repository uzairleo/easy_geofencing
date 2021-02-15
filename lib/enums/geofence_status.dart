///
/// Geofence events state
/// [init]: this is triggered when geofence service started
/// [enter]: this is triggered when the device current location is in the allocated geofence area
/// [exit]: this is triggered when the device current location is outside of the allocated geofence area
///
enum GeofenceStatus { init, enter, exit }
