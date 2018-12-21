import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'models/routes.dart' as routes;
import 'list_empty_state.dart';

class ListEventWidget extends StatefulWidget {
  @override
  _ListEventState createState() => _ListEventState();
}

class _ListEventState extends State<ListEventWidget> {
  Widget _buildListItem(context, DocumentSnapshot document) =>
      Text('${document['name']}');

  void _navigateToCreate() =>
      Navigator.of(context).pushNamed(routes.listEvents);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: Firestore.instance.collection('events').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return ListEmptyState();
            return ListView.builder(
              itemExtent: 80.0,
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) =>
                  _buildListItem(context, snapshot.data.documents[index]),
            );
          }),
    );
  }
}
