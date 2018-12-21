import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/routes.dart' as routes;
class CreateEventWidget extends StatefulWidget {
  @override
  _CreateEventState createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEventWidget> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  Future<void> _addToDb() async {
    await Firestore.instance.collection('events').add({
      'name': _nameController.text,
      'description': _descriptionController.text,
    });
    Navigator.pop(context);
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
      body: Column(
        children: <Widget>[
          Padding(padding: EdgeInsets.all(20)),
          ListTile(
            leading: const Icon(Icons.event_note),
            title: TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: "Event name",
              ),
            ),
          ),
          Padding(padding: EdgeInsets.all(20)),
          ListTile(
            leading: const Icon(Icons.note_add),
            title: TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: "description",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
