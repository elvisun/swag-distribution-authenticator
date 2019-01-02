import 'package:flutter/material.dart';
import 'models/routes.dart' as routes;
import 'list_events.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'collection_view.dart';
import 'models/calculate_embedding.dart';
import 'dart:io';

class EventDetail extends StatelessWidget {
  EventDetail({Key key, this.document}) : super(key: key);

  final DocumentSnapshot document;

  @override
  Widget build(BuildContext context) {
    void goToCollectionView() => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CollectionView(document),
          ),
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(document.data['name']),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/rocket.png',
              width: 250,
              height: 250,
            ),
            Padding(padding: EdgeInsets.all(30)),
            SizedBox(
              width: 200,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 4.0,
                padding: const EdgeInsets.all(8.0),
                textColor: Colors.white,
                color: Colors.pink,
                splashColor: Colors.pinkAccent,
                onPressed: goToCollectionView,
                child: const Text('Start session now'),
              ),
            ),
            Padding(padding: EdgeInsets.all(10)),
            FutureBuilder(
              future: document.reference
                  .collection(vectorCollectionName)
                  .reference()
                  .getDocuments(),
              builder: (context, snapshot) => Text(
                    'Total faces in database: ${_getFaceCount(snapshot)}',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

String _getFaceCount(AsyncSnapshot snapshot) {
  return ((snapshot.data) as QuerySnapshot)?.documents?.length.toString() ??
      '0';
}
