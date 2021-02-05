import 'package:flutter/material.dart';
import 'package:apollineflutter/widgets/map_settings.dart';

///Author (Issagha BARRY)
///Widget for all settings app.
class SettingsPage extends StatelessWidget {

  ///The title at the top of widget.
  final String title;

  ///
  ///constructor.
  SettingsPage({Key key, this.title}): super(key: key);

  ///
  ///Build all settings list.
  ///[context] the context.
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

  ///
  ///Create the widget.
  ///[context] the context.
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