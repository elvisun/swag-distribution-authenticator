import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'models/routes.dart' as routes;
import 'list_empty_state.dart';
import 'event_detail.dart';

class ListEventWidget extends StatefulWidget {
  @override
  _ListEventState createState() => _ListEventState();
}

class _ListEventState extends State<ListEventWidget> {
  void _navigateToCreate() =>
      Navigator.of(context).pushNamed(routes.listEvents);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: Firestore.instance.collection('events').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data.documents.isEmpty) {
              return ListEmptyState();
            }
            return ListView.builder(
              scrollDirection: Axis.vertical,
              itemExtent: 80.0,
              shrinkWrap: true,
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) =>
                  _buildListItem(context, snapshot.data.documents[index]),
            );
          }),
    );
  }

  Widget _buildListItem(context, DocumentSnapshot document) => Card(
        elevation: 8.0,
        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Container(
          decoration: BoxDecoration(color: Colors.white70),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EventDetail(
                          document: document,
                        )),
              );
            },
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
            leading: Container(
              padding: EdgeInsets.only(right: 12.0),
              decoration: BoxDecoration(
                border: Border(
                    right: BorderSide(width: 1.0, color: Colors.black54)),
              ),
              child: Icon(Icons.flag, color: Colors.black54),
            ),
            title: Text(
              document.data['name'],
              style:
                  TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
            ),
            subtitle: Row(
              children: <Widget>[
                Text(document.data['description'],
                    style: TextStyle(color: Colors.black54))
              ],
            ),
            trailing: Icon(Icons.keyboard_arrow_right,
                color: Colors.black54, size: 30.0),
          ),
        ),
      );
}
