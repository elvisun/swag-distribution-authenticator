import 'dart:async';

import 'package:flutter/material.dart';
import 'home.dart';
import 'create_event.dart';
import 'list_events.dart';
import 'models/routes.dart' as routes;
import 'event_detail.dart';
import 'collection_view.dart';
import 'package:camera/camera.dart';
import 'models/camera_factory.dart';

List<CameraDescription> cameras;

Future<void> main() async {
  await initializeCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swag Distributor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(title: 'Home'),
      routes: <String, WidgetBuilder>{
        routes.eventDetail: (BuildContext context) => EventDetail(),
        routes.createEvent: (BuildContext context) => CreateEventWidget(),
        routes.listEvents: (BuildContext context) => ListEventWidget(),
        routes.collection: (BuildContext context) => CollectionView(),
      },
    );
  }
}
