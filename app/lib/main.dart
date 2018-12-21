import 'package:flutter/material.dart';
import 'home.dart';
import 'create_event.dart';
import 'list_events.dart';
import 'models/routes.dart' as routes;
import 'event_detail.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
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
      },
    );
  }
}
