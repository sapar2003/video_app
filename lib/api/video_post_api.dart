// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:path/path.dart';
// import 'package:video_compress/video_compress.dart';

// Future<void> compressAndUploadVideo({
//   required String token,
//   required File videoFile,
//   required String serialNumber,
// }) async {
//   try {
//     // 1. Compress video using video_compress
//     final MediaInfo? compressedVideoInfo = await VideoCompress.compressVideo(
//       videoFile.path,
//       quality: VideoQuality.MediumQuality,
//       deleteOrigin: false,
//     );

//     if (compressedVideoInfo == null || compressedVideoInfo.file == null) {
//       print("Video compression failed.");
//       return;
//     }

//     final File compressedFile = compressedVideoInfo.file!;

//     // 2. Prepare and upload compressed video
//     final url = Uri.parse('https://vot.co.tm/api/add-new-video');
//     final request = http.MultipartRequest('POST', url);
//     request.headers['Authorization'] = 'Bearer $token';
//     request.fields['serial_number'] = serialNumber;

//     final videoStream = http.ByteStream(compressedFile.openRead());
//     final videoLength = await compressedFile.length();
//     final videoMultipartFile = http.MultipartFile(
//       'file',
//       videoStream,
//       videoLength,
//       filename: basename(compressedFile.path),
//     );

//     request.files.add(videoMultipartFile);

//     final response = await request.send().timeout(const Duration(minutes: 5));

//     if (response.statusCode == 200) {
//       print('Video uploaded successfully');
//       final responseData = await response.stream.bytesToString();
//       print('Response: $responseData');
//     } else {
//       print('Failed to upload video. Status code: ${response.statusCode}');
//       final errorData = await response.stream.bytesToString();
//       print('Error: $errorData');
//     }
//   } catch (e) {
//     print('An error occurred: $e');
//   } finally {
//     await VideoCompress.deleteAllCache(); // optional clean-up
//   }
// }
