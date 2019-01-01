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
import 'package:image/image.dart' as img;
import 'models/calculate_embedding.dart';
import 'services/functions.dart';
import 'models/camera_factory.dart' as camera_factory;

const preprocessedFolderName = 'preprocessed';

class CollectionView extends StatefulWidget {
  List<CameraDescription> cameras = camera_factory.cameras;
  DocumentSnapshot document;

  CollectionView(this.document);

  @override
  _CollectionViewState createState() => _CollectionViewState();
}

class _CollectionViewState extends State<CollectionView> {
  final _clock = Clock();
  CameraController controller;
  Directory _localDirectory;
  String _preprocessDirectoryPath;
  File _lastCroppedImg;

  num maxSimilarity;

  @override
  void initState() {
    super.initState();
    _initCamera();

    getApplicationDocumentsDirectory().then((dir) {
      setState(() {
        _localDirectory = dir;
        _preprocessDirectoryPath =
            path_util.join(_localDirectory.path, preprocessedFolderName);
        _initializePreprocessDirectory(_preprocessDirectoryPath);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized || _localDirectory == null) {
      return Container();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Take a picture'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              width: 200,
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: CameraPreview(controller),
              ),
            ),
            IconButton(
              onPressed: _screenshotAndCompare,
              color: Colors.pink,
              splashColor: Colors.pinkAccent,
              iconSize: 50.0,
              icon: Icon(Icons.camera_alt),
            ),
            _croppedPhotoWidget,
            _comparisionResultWidget,
          ],
        ),
      ),
    );
  }

  Future<void> _screenshotAndCompare() async {
    var newPath = path_util.join(
        _localDirectory.path, '${_clock.now().toIso8601String()}.jpg');
    await controller.takePicture(newPath);
    VisionFace face = await _findLargestFace(newPath);

    if (face == null) {
      setState(() {});
      return;
    }
    _lastCroppedImg = _cropImage(File(newPath), face.rect);

    var vector = await convertToVector(_lastCroppedImg);
    await saveVectorToDb(vector, session: widget.document);
    maxSimilarity = await getMaxSimilarity(vector);
    setState(() {});
    return;
  }

  Future<VisionFace> _findLargestFace(String newPath) async {
    List<VisionFace> faces =
        await FirebaseVisionFaceDetector.instance.detectFromPath(newPath);

    print('FOUND ${faces.length} FACES!');

    if (faces.isEmpty) return null;

    if (faces.length == 1) return faces.first;

    return faces.reduce((a, b) => (a.rect.size > b.rect.size) ? a : b);
  }

  Widget get _comparisionResultWidget {
    if (_lastCroppedImg == null) return Container();
    return Text(renderMaxSimilarity());
  }

  String renderMaxSimilarity() {
    if (maxSimilarity == null) {
      return 'loading';
    }
    return similarityToString(maxSimilarity);
  }

  Container get _croppedPhotoWidget {
    if (_lastCroppedImg == null) return Container();
    return Container(
      color: Colors.grey,
      height: 200,
      width: 200,
      child: Image.file(_lastCroppedImg, fit: BoxFit.scaleDown),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  File _cropImage(File f, Rect faceBoundary) {
    var basename = path_util.basename(f.path);
    img.Image image = img.decodeImage(f.readAsBytesSync()).clone();

    // The [img.copyCrop] method starts from the bottom left of the img,
    // also takes the width as height and height as width.
    // So we need this weird transformation math.
    var newImg = img.copyCrop(
        image,
        image.width - faceBoundary.bottom.round(),
        faceBoundary.left.round(),
        faceBoundary.height.round(),
        faceBoundary.width.round());
    var path = path_util.join(_preprocessDirectoryPath, basename);
    var processedFile = File(path);
    processedFile.writeAsBytesSync(img.encodeJpg(newImg));
    return processedFile;
  }

  void _initializePreprocessDirectory(String path) {
    if (Directory(path).existsSync()) {
      return;
    }
    Directory(path).createSync();
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
}
