import 'package:flutter/material.dart';

import 'package:workmanager/workmanager.dart';
import 'bluetoothDevicesPage.dart';
import 'services/service_locator.dart';

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) {
    print(
        "Native called background task: $backgroundTask"); //simpleTask will be emitted here.
    return Future.value(true);
  });
}

void main() {
  Workmanager.initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode:
          true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
      );
  Workmanager.registerOneOffTask("1", "simpleTask",
      initialDelay: Duration(seconds: 10),
      constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
          requiresCharging: true,
          requiresDeviceIdle: true,
          requiresStorageNotLow: true));

  Workmanager.registerPeriodicTask(
    "2",
    "simplePeriodicTask",
    // When no frequency is provided the default 15 minutes is set.
    // Minimum frequency is 15 min. Android will automatically change your frequency to 15 min if you have configured a lower frequency.
    frequency: Duration(minutes: 15),
  );

import 'package:global_configuration/global_configuration.dart';

import 'bluetoothDevicesPage.dart';
import 'services/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfiguration().loadFromAsset("config_dev.json");
  setupServiceLocator();
  runApp(ApollineApp());
}
// This acts as the landing window of the app.
// Scans and displays Bluetooth devices in range, and allows to connect to them.

class ApollineApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apolline',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.green,
      ),
      home: BluetoothDevicesPage(title: 'Apolline - Sensors'),
    );
  }
}
