import 'package:flutter/material.dart';
import 'models/routes.dart' as routes;

class ListEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void _navigateToCreate() =>
        Navigator.of(context).pushNamed(routes.createEvent);

    return Center(
      child: MaterialButton(
        color: Colors.pink,
        textColor: Colors.white,
        onPressed: _navigateToCreate,
        child: Text("Create new event"),
      ),
    );
  }
}
