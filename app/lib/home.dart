import 'package:flutter/material.dart';
import 'models/routes.dart' as routes;
import 'list_events.dart';

class Home extends StatelessWidget {
  Home({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    void _navigateToCreate() =>
        Navigator.of(context).pushNamed(routes.createEvent);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListEventWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreate,
        child: Icon(Icons.add),
      ),
    );
  }
}
