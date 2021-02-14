import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:apollineflutter/services/service_locator.dart';
import 'package:apollineflutter/services/sqflite_service.dart';
import 'package:apollineflutter/utils/simple_geohash.dart';
import 'package:apollineflutter/services/user_configuration_service.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:apollineflutter/configuration_key_name.dart';
import 'package:apollineflutter/models/user_configuration.dart';
import 'package:apollineflutter/services/realtime_data_service.dart';
import 'package:apollineflutter/models/sensormodel.dart';
import 'package:location/location.dart';



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
  
  ///the min value of pm order in sensormodel.
  var minPmValues = GlobalConfiguration().get(ApollineConf.MINPMVALUES) ?? [];
  ///the max value of pm order in sensormodel.
  var maxPmValues = GlobalConfiguration().get(ApollineConf.MAXPMVALUES) ?? [];
  ///user configuration in the ui
  UserConfigurationService ucS = locator<UserConfigurationService>();
  ///instance to manage database
  SqfLiteService _sqliteService = SqfLiteService();
  ///circle to put in map
  Set<Circle> _circles;
  ///help for close subscription
  StreamSubscription _sub;
  ///help to listen data
  Stream<SensorModel> _sensorDataStream = locator<RealtimeDataService>().dataStream;
  /// the label for time.
  List<String> mapTimeLabel = [
    "last minute",
    "last 5 minutes",
    "last 15 minutes",
    "last 30 minutes",
    "last 1 hour",
    "last 3 hours",
    "last 6 hours",
    "last 12 hours",
    "last 24 hours",
    "Today",
    "This week"

  ];
  /// the label of pm
  List<String> pmLabels= [
    "PM 1",
    "PM 2_5",
    "PM 10",
    "PM_ABOVE 0_3",
    "PM_ABOVE 0_5",
    "PM_ABOVE 1",
    "PM_ABOVE 2_5",
    "PM_ABOVE 5",
    "PM_ABOVE 10",
  ];
  ///the index of each pm in model.
  List<int> indexPmValueInModel = [1, 2, 3, 4, 5, 6, 7, 8, 9];
  // location to get position 
  Location _location = Location();
  
  MapUiBodyState();

  static final CameraPosition _kInitialPosition = const CameraPosition(
    target: LatLng(50.6333, 3.0667),
    zoom: 16.0,
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

  @override
  void initState() {
    super.initState();
    this._circles = HashSet<Circle>();
    this.getSensorDataAfterDate();
    this.listenSensorData();
  }

  ///
  ///Listen sensor data.
  void listenSensorData() {
    this._sub = this._sensorDataStream.listen((pModel) {
      this.addCircle(pModel);
      //manage the rendering frequency.
      if(this._circles.length % 10 == 0) {
        this.setState(() { });
      }
    });
  }

  @override
  void dispose() {
    this._sub?.cancel();
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

  ///
  ///This function build a radio button for mapSync
  ///[context] the context
  ///[labels] the label
  ///[values] all value 
  List<Widget> frequencyRadio(BuildContext context, List<String> labels, List<dynamic> values, dynamic current) {
    
    List<Widget> renders = [];
    for(var i = 0; i < labels.length; i++) {
      renders.add(
        ListTile(
          title: Text(labels[i]),
          leading: Radio(
            value: values[i], //we use index for maping label et MapFrequency
            groupValue: current,
            onChanged: (dynamic value) {
              Navigator.pop(context, values[i]);
            },
          ),
        ),
      );
    }
    return renders;
  }

  ///
  ///Create dialog for select.
  ///[ctx] the context of app
  ///[labels] label in the select
  ///[values] the values corresponding to labels
  ///[current] the current value of select
  Future<dynamic> dialog(BuildContext ctx, List<String> labels, List<dynamic> values, dynamic current) async{
    var val = await showDialog(
      context: ctx,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.only(left:0),
          content: Container(
            height: 300,
            width: 300,
            child: ListView(
              children: this.frequencyRadio(context, labels, values, current),
            )
          ),
        );
      }
    );
    return val;
  }

  ///
  ///select for time frequency
  ///[ctx] the context of app
  Future<void> chooseTimeFrequency(BuildContext ctx) async{
    var uConf = this.ucS.userConf;
    var val = await this.dialog(ctx, mapTimeLabel, MapFrequency.values, uConf.mapSyncFrequency);
    if(val != null) {
      uConf.mapSyncFrequency = val;
      this.ucS.update(); //notify the settings page that something has changed.
      this.getSensorDataAfterDate();
    }
  }

  ///
  ///select for choose pm.
  ///[ctx] the context of app
  Future<void> choosePm(BuildContext ctx) async {
    var uConf = this.ucS.userConf;
    var val = await this.dialog(ctx, pmLabels, indexPmValueInModel, uConf.pmIndex);
    if(val != null) {
      uConf.pmIndex = val;
      this.ucS.update();
      this.getSensorDataAfterDate();
    }
  }

  ///
  ///Not used, help to change in night mode.
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton.extended(
              label: Text("Time"),
              onPressed: () { this.chooseTimeFrequency(context); },
              backgroundColor: Colors.green, //TODO trouver le moyen de factoriser dans ThemeData
            ),
            FloatingActionButton.extended(
              label: Text("PM"),
              onPressed: () { this.choosePm(context); },
              backgroundColor: Colors.green, //TODO trouver le moyen de factoriser dans ThemeData
            )
          ],
        ),
      ),
    );
  }

  void _updateCameraPosition(CameraPosition position) {
    setState(() {
      _position = position;
    });
  }

  ///
  ///Get the color fonction of pm25 value
  Color getColorOfPM25(double pmValue) {
    var index = this.indexPmValueInModel.indexOf(this.ucS.userConf.pmIndex);

    var min = index >= 0 && index < this.minPmValues.length ? this.minPmValues[index] : 0;
    var max = index >= 0 && index < this.maxPmValues.length ? this.maxPmValues[index] : 1;
    if(pmValue < min) {
      return Color.fromRGBO(170, 255, 0, .1); //vert
    } else if(pmValue > min && pmValue < max) {
      return Color.fromRGBO(255, 143, 0, .1); //orange
    } else {
      return Color.fromRGBO(255, 15, 0, .1); //rouge
    }
  }

  ///
  ///add circle to model.
  ///[pModel] model
  void addCircle(SensorModel pModel) {
    var json = SimpleGeoHash.decode(pModel.position.geohash);
    this._circles.add(
      Circle(
        circleId: CircleId(UniqueKey().toString()),
        center: LatLng(json["latitude"], json["longitude"]),
        radius: 10,
        strokeWidth: 0,
        fillColor: this.getColorOfPM25(double.parse(pModel.values[this.ucS.userConf.pmIndex]))
      )
    );
  }

  ///
  ///update data after change time of pm choice.
  void getSensorDataAfterDate() {
    this._sqliteService.getAllSensorModelAfterDate(this.ucS.userConf.mapSyncFrequency).then((res) {
      this._circles.clear(); //clean last content.
      for(var i = 0; i < res.length; i++) {
        this.addCircle(res[i]);
      }
      
      this.setState(() {});
    });
  }

  // Created map
  void onMapCreated(GoogleMapController controller) {
    _controller = controller;
    _location.onLocationChanged.listen((l) { 
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(l.latitude, l.longitude),zoom: 16),
          ),
      );
    });
     _isMapCreated = true;
    
  }
}
