import 'package:flutter/material.dart';
import 'package:apollineflutter/widgets/map_settings.dart';

///Author (Issagha BARRY)
///Widget for all settings app
class SettingsPage extends StatelessWidget {

  final String title;

  SettingsPage({Key key, this.title}): super(key: key);

  List<Widget> _buildSettingsList(BuildContext context) {
    
    return [
      ListTile(
        title: Text('Map settings'),
        leading: Icon(Icons.map),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => MapSettings(title: "Map settings")));
        },
      )
    ];
    
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        
        title: Text(this.title),
      ),
      body: Center(
          child: ListView(children: _buildSettingsList(context))),
    );
  }

  
}