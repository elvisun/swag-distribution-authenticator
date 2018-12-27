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
import 'package:quiver/time.dart';
import 'package:mlkit/mlkit.dart';

const preprocessedFolderName = 'preprocessed';

class CollectionView extends StatefulWidget {
  final List<CameraDescription> cameras;

  CollectionView(this.cameras);

  @override
  _CollectionViewState createState() => _CollectionViewState();
}

class _CollectionViewState extends State<CollectionView> {
  final _clock = Clock();
  CameraController controller;
  Directory _localDirectory;
  String _preprocessDirectoryPath;

  @override
  void initState() {
    super.initState();
    _initCamera();

    getApplicationDocumentsDirectory().then((dir) {
      setState(() {
        _localDirectory = dir;
        _preprocessDirectoryPath = path_util.join(_localDirectory.path, preprocessedFolderName);
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

  Future<void> screenshot() async {
    var newPath = path_util.join(
        _localDirectory.path, '${_clock.now().toIso8601String()}.jpg');
    await controller.takePicture(newPath);
    List<VisionFace> faces = await FirebaseVisionFaceDetector.instance.detectFromPath(listAllPictures().last);
    print(faces);
    setState(() {});
  }

  List<String> listAllPictures() {
    return _localDirectory
        .listSync()
        .where((f) => path_util.extension(f.path).contains('jpg'))
        .map((f) => f.path)
        .toList();
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
            width: 50,
            height: 80,
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
          Text(
            _localDirectory.path,
            style: TextStyle(color: Colors.pink),
          ),
          Text(listAllPictures().length.toString(),
              style: TextStyle(color: Colors.blue)),
          Text(listAllPictures().first, style: TextStyle(color: Colors.green)),
          Container(
            width: double.infinity,
            height: 400,
            child: Image.file(File(listAllPictures().last)),
          )
        ],
      ),
    );
  }
}
