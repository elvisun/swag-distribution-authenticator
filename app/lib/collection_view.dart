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
import 'package:flutter/foundation.dart' show compute;

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

  final loadingTextObservable = ValueNotifier('');

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
      body: ValueListenableBuilder(
        valueListenable: loadingTextObservable,
        builder: (context, value, snapshot) => Stack(
              children: <Widget>[
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child: AspectRatio(
                          aspectRatio: controller.value.aspectRatio,
                          child: CameraPreview(controller),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _screenshotAndCompare(loadingTextObservable);
                        },
                        color: Colors.black,
                        splashColor: Colors.black38,
                        iconSize: 110.0,
                        icon: Icon(Icons.camera_alt),
                      ),
                    ],
                  ),
                ),
                Builder(builder: (context) {
                  if (loadingTextObservable.value == '') {
                    return Container();
                  }
                  return Stack(
                    children: [
                      Opacity(
                        opacity: 0.9,
                        child: const ModalBarrier(
                            dismissible: false, color: Colors.black),
                      ),
                      Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(),
                          Padding(padding: EdgeInsets.all(30)),
                          Text(
                            loadingTextObservable.value,
                            style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      )),
                    ],
                  );
                }),
              ],
            ),
      ),
    );
  }

  void _showDialog({@required bool faceFound}) {
    if (faceFound) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _croppedPhotoWidget,
                Padding(padding: EdgeInsets.all(10)),
                _comparisionResultWidget,
                Padding(padding: EdgeInsets.all(5)),
                _comparisionResultDebugWidget
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    if (!faceFound) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: Text("Opps, no faces found!"),
            content: Image.asset(
              'assets/empty.png',
              width: 250,
              height: 250,
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _screenshotAndCompare(
      ValueNotifier loadingTextObservable) async {
    var newPath = path_util.join(
        _localDirectory.path, '${_clock.now().toIso8601String()}.jpg');
    await controller.takePicture(newPath);
    setState(() {
      loadingTextObservable.value = 'finding faces...';
    });
    VisionFace face = await _findLargestFace(newPath);

    if (face == null) {
      setState(() {
        loadingTextObservable.value = '';
        _showDialog(faceFound: false);
      });
      return;
    }

    setState(() {
      loadingTextObservable.value = 'converting face to vector...';
    });

    //TODO: send this to a background thread so it doesn't block UI.
    _lastCroppedImg = _cropImage(File(newPath), face.rect);
    var vector = await convertToVector(_lastCroppedImg);

    setState(() {
      loadingTextObservable.value = 'saving vector to database...';
    });
    await saveVectorToDb(vector, session: widget.document);

    setState(() {
      loadingTextObservable.value = 'calculating similarity...';
    });
    maxSimilarity = await getMaxSimilarity(vector, session: widget.document);

    setState(() {
      loadingTextObservable.value = '';
      _showDialog(faceFound: true);
    });
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
    return Text(
      _renderMaxSimilarity(),
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget get _comparisionResultDebugWidget {
    if (_lastCroppedImg == null) return Container();
    return Text(
      _debugMaxSimilarity(),
      style: TextStyle(fontSize: 16, color: Colors.black45),
    );
  }

  String _renderMaxSimilarity() {
    if (maxSimilarity == null) {
      return 'loading';
    }
    return similarityToString(maxSimilarity);
  }

  String _debugMaxSimilarity() {
    if (maxSimilarity == null) {
      return 'loading';
    }
    return similarityToDebugString(maxSimilarity);
  }

  Container get _croppedPhotoWidget {
    if (_lastCroppedImg == null) return Container();
    return Container(
      color: Colors.grey,
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
    processedFile.writeAsBytesSync(img.encodeJpg(newImg), flush: true);
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
