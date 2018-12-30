import 'package:flutter/material.dart';
import 'models/routes.dart' as routes;
import 'list_events.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class EventDetail extends StatelessWidget {
  EventDetail({Key key, this.document}) : super(key: key);

  final DocumentSnapshot document;

  @override
  Widget build(BuildContext context) {
    void goToCollectionView() =>
        Navigator.of(context).pushNamed(routes.collection);

    return Scaffold(
        appBar: AppBar(
          title: Text(document.data['name']),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              RaisedButton(
                elevation: 4.0,
                padding: const EdgeInsets.all(8.0),
                textColor: Colors.white,
                color: Colors.pink,
                splashColor: Colors.pinkAccent,
                onPressed: goToCollectionView,
                child: const Text('Start session now'),
              ),
              RaisedButton(
                elevation: 4.0,
                padding: const EdgeInsets.all(8.0),
                textColor: Colors.white,
                color: Colors.green,
                splashColor: Colors.greenAccent,
                onPressed: callFunction,
                child: const Text('test test'),
              ),
            ],
          ),
        ),
    );
  }
}

Future<void> callFunction() async {
  var res = await CloudFunctions.instance.call(functionName: 'helloWorld',
    parameters: {
      'data': '11',
      'data2': '22',
    }
  );
  print(res);
}
