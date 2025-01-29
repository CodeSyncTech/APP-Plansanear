import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_watermark/image_watermark.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      home: CameraScreen(camera: firstCamera),
    ),
  );
}

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({Key? key, required this.camera}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
    });
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;

      final image = await _controller.takePicture();

      if (_currentPosition == null) {
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          const SnackBar(content: Text('Localização não disponível')),
        );
        return;
      }

      final String locationText =
          "Lat: ${_currentPosition!.latitude}, Lon: ${_currentPosition!.longitude}";

      final Uint8List imageBytes = await File(image.path).readAsBytes();
      final Uint8List watermarkImage = await _loadWatermarkImage();

      final Uint8List watermarkedImage = await ImageWatermark.addTextWatermark(
        imgBytes: imageBytes,
        watermarkText: locationText,
        dstX: 20,
        dstY: 20,
        color: Colors.white,
      );

      final Uint8List finalImage = await ImageWatermark.addImageWatermark(
        waterkmarkImageBytes: watermarkImage,
        dstX: 20,
        dstY: 60,
        originalImageBytes: watermarkedImage,
      );

      final Directory appDir = await getApplicationDocumentsDirectory();
      final String savedImagePath = join(appDir.path, 'watermarked_image.png');
      await File(savedImagePath).writeAsBytes(finalImage);

      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text('Foto salva em: $savedImagePath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text('Erro ao capturar foto: $e')),
      );
    }
  }

  Future<Uint8List> _loadWatermarkImage() async {
    final ByteData data = await rootBundle.load('assets/watermark.png');
    return data.buffer.asUint8List();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Câmera com Marca d\'Água')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
