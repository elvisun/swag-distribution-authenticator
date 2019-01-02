import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/routes.dart' as routes;
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateEventWidget extends StatefulWidget {
  @override
  _CreateEventState createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEventWidget> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _addToDb() async {
    if (!_formKey.currentState.validate()) return;
    await Firestore.instance.collection('events').add({
      'name': _nameController.text,
    });
    Navigator.pop(context);
  }

  String _isNotEmptyValidator(v) {
    if (v.isEmpty) return 'Please enter a value';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register a new event'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.send),
            onPressed: (() async => await _addToDb()),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            Padding(padding: EdgeInsets.all(20)),
            Image.asset(
              'assets/oct.png',
              width: 250,
              height: 250,
            ),
            Padding(padding: EdgeInsets.all(20)),
            ListTile(
              leading: const Icon(Icons.event_note),
              title: TextFormField(
                validator: _isNotEmptyValidator,
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: "Event name",
                ),
              ),
            ),
            Padding(padding: EdgeInsets.all(20)),
          ],
        ),
      ),
    );
  }
}
