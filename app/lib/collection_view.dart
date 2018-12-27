import 'package:flutter/material.dart';
import 'models/routes.dart' as routes;
import 'list_events.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path_util;
import 'package:path_provider/path_provider.dart';

class CollectionView extends StatefulWidget {
  final List<CameraDescription> cameras;

  CollectionView(this.cameras);

  @override
  _CollectionViewState createState() => _CollectionViewState();
}

class _CollectionViewState extends State<CollectionView> {
  CameraController controller;
  Directory _localDirectory;

  @override
  void initState() {
    super.initState();
    _initCamera();

    getApplicationDocumentsDirectory().then((dir) {
      setState(() {
        _localDirectory = dir;
      });
    });
  }

  void _initCamera() {
    controller = CameraController(widget.cameras[1], ResolutionPreset.low);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void screenshot() {
    controller.takePicture(path_util.join(_localDirectory.path, 'test.jpg'));
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized || _localDirectory == null) {
      return Container();
    }
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            width: 250,
            height: 300,
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: CameraPreview(controller),
            ),
          ),
          IconButton(
            onPressed: screenshot,
            iconSize: 30.0,
            icon: Icon(Icons.camera_alt),
          ),
          Text('hellow'),
          Image.file(File(path_util.join(_localDirectory.path, 'test.jpg'))),
        ],
      ),
    );
  }
}
