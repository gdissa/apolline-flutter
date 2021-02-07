import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:apollineflutter/services/service_locator.dart';
import 'package:apollineflutter/services/sqflite_service.dart';
import 'package:apollineflutter/utils/simple_geohash.dart';
import 'package:apollineflutter/services/user_configuration_service.dart';

class MapSample extends StatelessWidget {
  MapSample() : super();

  @override
  Widget build(BuildContext context) {
    return const MapUiBody();
  }
}

class MapUiBody extends StatefulWidget {
  const MapUiBody();

  @override
  State<StatefulWidget> createState() => MapUiBodyState();
}

class MapUiBodyState extends State<MapUiBody> {
  MapUiBodyState();

  static final CameraPosition _kInitialPosition = const CameraPosition(
    target: LatLng(50.6333, 3.0667),
    zoom: 11.0,
  );

  CameraPosition _position = _kInitialPosition;
  bool _isMapCreated = false;
  bool _isMoving = false;
  bool _compassEnabled = true;
  bool _mapToolbarEnabled = true;
  CameraTargetBounds _cameraTargetBounds = CameraTargetBounds.unbounded;
  MinMaxZoomPreference _minMaxZoomPreference = MinMaxZoomPreference.unbounded;
  MapType _mapType = MapType.normal;
  bool _rotateGesturesEnabled = true;
  bool _scrollGesturesEnabled = true;
  bool _tiltGesturesEnabled = true;
  bool _zoomControlsEnabled = false;
  bool _zoomGesturesEnabled = true;
  bool _indoorViewEnabled = true;
  bool _myLocationEnabled = true;
  bool _myTrafficEnabled = false;
  bool _myLocationButtonEnabled = true;
  GoogleMapController _controller;
  bool _nightMode = false;
  UserConfigurationService ucS = locator<UserConfigurationService>();

  //instance to manage database
  SqfLiteService _sqliteService = SqfLiteService();
  //circle to put in map
  Set<Circle> _circles;
  //liste of used Position
  List<String> used = [];



  @override
  void initState() {
    super.initState();
    this._circles = HashSet<Circle>();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<String> _getFileData(String path) async {
    return await rootBundle.loadString(path);
  }

  void _setMapStyle(String mapStyle) {
    setState(() {
      _nightMode = true;
      _controller.setMapStyle(mapStyle);
    });
  }

  Widget _nightModeToggler() {
    if (!_isMapCreated) {
      return null;
    }
    return FlatButton(
      //child: Text('${_nightMode ? 'disable' : 'enable'} night mode'),
      onPressed: () {
        if (_nightMode) {
          setState(() {
            _nightMode = false;
            _controller.setMapStyle(null);
          });
        } else {
          _getFileData('assets/night_mode.json').then(_setMapStyle);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final GoogleMap googleMap = GoogleMap(
      onMapCreated: onMapCreated,
      initialCameraPosition: _kInitialPosition,
      compassEnabled: _compassEnabled,
      mapToolbarEnabled: _mapToolbarEnabled,
      cameraTargetBounds: _cameraTargetBounds,
      minMaxZoomPreference: _minMaxZoomPreference,
      mapType: _mapType,
      rotateGesturesEnabled: _rotateGesturesEnabled,
      scrollGesturesEnabled: _scrollGesturesEnabled,
      tiltGesturesEnabled: _tiltGesturesEnabled,
      zoomGesturesEnabled: _zoomGesturesEnabled,
      zoomControlsEnabled: _zoomControlsEnabled,
      indoorViewEnabled: _indoorViewEnabled,
      myLocationEnabled: _myLocationEnabled,
      myLocationButtonEnabled: _myLocationButtonEnabled,
      trafficEnabled: _myTrafficEnabled,
      onCameraMove: _updateCameraPosition,
      circles: this._circles,
    );

    return new Scaffold(
      body: googleMap,
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _nightModeToggler,
      //   label: Text('Mode night!'),
      //   icon: Icon(Icons.nights_stay),
      // ),
    );
  }

  void _updateCameraPosition(CameraPosition position) {
    setState(() {
      _position = position;
    });
  }

  void onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller = controller;
      _isMapCreated = true;
    });
    this._sqliteService.getAllSensorModelAfterDate(this.ucS.userConf.mapSyncFrequency).then((res) {
      this._circles.clear(); //clean last content.
      this.used.clear(); //revoir cette façon de faire.
      for(var i = 0; i < res.length; i++) {
        var json = SimpleGeoHash.decode(res[i].position.geohash);
        if(!this.used.contains(res[i].position.geohash)) {
          this.used.add(res[i].position.geohash);
          this._circles.add(
          Circle(
            circleId: CircleId("$i"),
            center: LatLng(json["latitude"], json["longitude"]),
            radius: 20,
            strokeWidth: 0,
            fillColor: Color.fromRGBO(102, 225, 0, .2)),//Color.fromRGBO(102, 225, 0, .3)), //gérer correctement les couleurs voir ave ramy et les autres.
          );
        }
        
      }
      
      this.setState(() {});
    });
  }
}
