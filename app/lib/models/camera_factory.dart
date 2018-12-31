import 'package:camera/camera.dart';

List<CameraDescription> _cameras;

Future<void> initializeCameras() async => _cameras = await availableCameras();

List<CameraDescription> get cameras => _cameras;
