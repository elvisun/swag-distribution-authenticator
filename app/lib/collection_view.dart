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
  File _lastCroppedImg;
  File _lastImg;

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

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  File cropImage(File f, Rect faceBoundary) {
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

  Future<void> screenshot() async {
    var newPath = path_util.join(
        _localDirectory.path, '${_clock.now().toIso8601String()}.jpg');
    await controller.takePicture(newPath);
    List<VisionFace> faces =
        await FirebaseVisionFaceDetector.instance.detectFromPath(newPath);
    _lastImg = File(newPath);
    print(newPath);
    if (faces.isEmpty) {
      print('NO FACES FOUND!');
    } else {
      print('FOUND ${faces.length} FACES!');
      _lastCroppedImg = cropImage(File(newPath), faces.first.rect);
    }
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
              onPressed: screenshot,
              iconSize: 30.0,
              icon: Icon(Icons.camera_alt),
            ),
            Text(listAllPictures().length.toString(),
                style: TextStyle(color: Colors.blue)),
            getContainer(),
            getEmbeddingWidget(),
          ],
        ),
      ),
    );
  }

  Widget getEmbeddingWidget() {
    if (_lastCroppedImg == null) return Container();
    return FutureBuilder(
        future: getImageEmbeddingDistance(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Text('No data');
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Text('Awaiting result...');
            case ConnectionState.done:
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              return Text('Result: ${snapshot.data}');
          }
        });
  }

  Future<String> getImageEmbeddingDistance() async {
    var vector = await convertToVector(_lastCroppedImg);
    print('converted vector: $vector');
    var distance = await getMaxSimilarity(vector);
    return distance;
  }

  Container getContainer() {
    if (_lastCroppedImg == null) return Container();
    return Container(
      color: Colors.grey,
      height: 200,
      width: 200,
      child: Image.file(_lastCroppedImg, fit: BoxFit.scaleDown),
    );
  }
}
