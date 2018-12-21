import 'package:flutter/material.dart';
import 'models/routes.dart' as routes;
import 'list_events.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventDetail extends StatelessWidget {
  EventDetail({Key key, this.document}) : super(key: key);

  final DocumentSnapshot document;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(document.data['name']),
        ),
        body: Text(document.data['description']));
  }
}
