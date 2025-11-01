import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video/bottombar.dart';
import 'package:video_compress/video_compress.dart';

class VideoUploader {
  final String uploadUrl = 'https://vot.co.tm/api/add-new-video';

  Future<bool> uploadVideo({
    required String token,
    required File videoFile,
  }) async {
    try {
      final compressedVideo = await VideoCompress.compressVideo(
        videoFile.path,
        quality: VideoQuality.LowQuality,
        deleteOrigin: false,
      );

      if (compressedVideo?.file == null) return false;

      final File compressedFile = compressedVideo!.file!;
      final uri = Uri.parse(uploadUrl);
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      final videoStream = http.ByteStream(compressedFile.openRead());
      final videoLength = await compressedFile.length();

      request.files.add(http.MultipartFile(
        'file',
        videoStream,
        videoLength,
        filename: basename(compressedFile.path),
      ));

      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        await VideoCompress.deleteAllCache();
        return true;
      } else {
        debugPrint(await response.stream.bytesToString());
        return false;
      }
    } catch (e) {
      debugPrint('Upload error: $e');
      return false;
    }
  }
}

class VideoCapturePage extends StatefulWidget {
  const VideoCapturePage({Key? key}) : super(key: key);

  @override
  State<VideoCapturePage> createState() => _VideoCapturePageState();
}

class _VideoCapturePageState extends State<VideoCapturePage> {
  late CameraController _controller;
  bool _isRecording = false;
  bool _isCameraInitialized = false;
  File? _recordedVideoFile;
  String? token;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      _controller = CameraController(cameras.first, ResolutionPreset.high);
      await _controller.initialize();
      setState(() => _isCameraInitialized = true);
    } catch (e) {
      debugPrint('Camera error: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (_controller.value.isRecordingVideo) return;

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';

    await _controller.startVideoRecording();
    setState(() => _isRecording = true);
  }

  Future<void> _stopRecording(BuildContext context) async {
    if (!_controller.value.isRecordingVideo) return;

    final file = await _controller.stopVideoRecording();
    setState(() {
      _isRecording = false;
      _recordedVideoFile = File(file.path);
    });

    _showDialog(
      message: "Video ýatda saklandy!",
      context: context,
    );
  }

  Future<void> _uploadVideo(BuildContext context) async {
    if (_recordedVideoFile == null) {
      _showDialog(
        message: "Video tapylmady!",
        context: context,
      );
      return;
    }
    if (token == null) {
      _showDialog(
        message: "Token ýok! Ilki login ediň.",
        context: context,
      );
      return;
    }

    _showDialog(
      message: "Ýüklenýär...",
      isLoading: true,
      context: context,
    );

    final uploader = VideoUploader();
    final success = await uploader.uploadVideo(
      token: token!,
      videoFile: _recordedVideoFile!,
    );

    Navigator.pop(context); // Remove loading
    _showDialog(
      message:
          success ? "✅ Video üstünlikli ugradyldy!" : "❌ Ugratmak başartmady.",
      color: success ? Colors.white : Colors.white,
      context: context,
    );
  }

  void _showDialog({
    required String message,
    bool isLoading = false,
    Color? color,
    required BuildContext context,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: color ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: CircularProgressIndicator(),
                ),
              Flexible(
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          actions: isLoading
              ? null
              : [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Hawa",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BottomNavBar(),
            ));
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              if (_isCameraInitialized)
                SizedBox.expand(
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: CameraPreview(_controller),
                  ),
                )
              else
                const Center(
                    child: CircularProgressIndicator(color: Colors.orange)),

              Positioned(
                left: 0,
                right: 0,
                bottom: 90,
                child: ElevatedButton.icon(
                  onPressed: _isRecording
                      ? () => _stopRecording(context)
                      : _startRecording,
                  icon: Icon(
                    _isRecording ? Icons.stop : Icons.videocam,
                    color: Colors.white,
                    size: 30,
                  ),
                  label: Text(
                    _isRecording ? "Duruzmak" : "Video almak",
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRecording ? Colors.red : Colors.orange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // ☁️ Upload Button
              if (_recordedVideoFile != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 20,
                  child: ElevatedButton.icon(
                    onPressed: () => _uploadVideo(context),
                    icon:
                        const Icon(Icons.upload, color: Colors.white, size: 30),
                    label: const Text("Ugratmak",
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
