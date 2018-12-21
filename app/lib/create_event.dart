import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateEventWidget extends StatefulWidget {
  @override
  _CreateEventState createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEventWidget> {
  final _nameController = TextEditingController();

  void _addToDb() async {
    await Firestore.instance.collection('events').add({'name': _nameController.text});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register a new event'),
      ),
      body: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
              ),
              MaterialButton(
                onPressed: _addToDb,
                color: Colors.blue,
                textColor: Colors.white,
                child: Text('submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
