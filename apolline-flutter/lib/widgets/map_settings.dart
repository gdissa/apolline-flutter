import 'package:flutter/material.dart';
import 'package:apollineflutter/services/service_locator.dart';
import 'package:apollineflutter/models/user_configuration.dart';

///Author (Issagha BARRY)
///Widget
class MapSettings extends StatefulWidget {

  ///The title at the top of widget
  final String title;

  ///constructor
  MapSettings({Key key, this.title}) : super(key: key);

  @override
  _MapSettingsState createState() => _MapSettingsState();
}

///Author (Issagha BARRY)
///State
class _MapSettingsState extends State<MapSettings> {

  ///User configuration
  UserConfiguration uConf = locator<UserConfiguration>();
  ///The labels that will be displayed in the radio buttons
  List<String> mapSyncLabel = [
    "1 minute",
    "5 minute",
    "15 minute",
    "30 minute",
    "1 heure",
    "3 heures",
    "6 heures",
    "12 heures",
    "24 heures"
  ];

  ///
  ///This function build a radio button for mapSync
  ///[context] the context
  List<Widget> frequencyRadio(BuildContext context) {
  
    List<Widget> renders = [];
    for(var i = 0; i < mapSyncLabel.length; i++) {
      renders.add(
        ListTile(
            title: Text(mapSyncLabel[i]),
            leading: Radio(
              value: MapFrequency.values[i], //we use index for maping label et MapFrequency
              groupValue: uConf.mapSyncFrequency,
              onChanged: (MapFrequency value) {
                Navigator.pop(context, MapFrequency.values[i]);
              },
            ),
          ),
      );
    }
    return renders;
  }

  ///
  ///It's show the popup that containt the radiobutton
  ///[ctx] the context
  Future<void> chooseSyncFrequency(BuildContext ctx) async{
    var val = await showDialog(
      context: ctx,
      builder: (BuildContext context) {
        return SimpleDialog(
          children: this.frequencyRadio(context),
          contentPadding: EdgeInsets.symmetric(horizontal: 0.0)
        );
      }
    );
    if(val != null) {
      //save user config
      setState(() {
        uConf.mapSyncFrequency = val;
      });
    }
    
  }

  ///
  ///build all settings
  ///[context] the context
  List<Widget> _buildSettings(BuildContext context) {
    return [
      ListTile(
        title: Text('Sync frequency'),
        leading: Icon(Icons.map),
        subtitle: Text(mapSyncLabel[uConf.mapSyncFrequency.index]),
        onTap: () {
          this.chooseSyncFrequency(context);
        },
      )
      
    ];
  }

  ///
  ///build widget
  ///[context] the context.
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        
        title: Text(widget.title),
      ),
      body: Center(
          child: ListView(children: _buildSettings(context))),
    );
  }

  
}

