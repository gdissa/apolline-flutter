import 'package:flutter/material.dart';
import 'package:apollineflutter/services/service_locator.dart';
import 'package:apollineflutter/models/user_configuration.dart';


class MapSettings extends StatefulWidget {

  final String title;

  MapSettings({Key key, this.title}) : super(key: key);

  @override
  _MapSettingsState createState() => _MapSettingsState();
}

class _MapSettingsState extends State<MapSettings> {

  UserConfiguration uConf = locator<UserConfiguration>();

  List<Widget> _buildSettings() {
    return [
      // ListTile(
      //   title: Text('Sync frequency'),
      //   leading: Icon(Icons.map),
      //   subtitle: Text('1 hour'),
      //   onTap: () {
      //     print("titititititi");
      //   },
      // ),
      
    ];
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        
        title: Text(widget.title),
      ),
      body: Center(
          child: ListView(children: _buildSettings())),
    );
  }

  
}

