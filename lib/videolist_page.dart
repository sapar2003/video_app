import 'package:flutter/material.dart';
import 'package:video/api/user_get_data.dart';
import 'package:video_player/video_player.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:chewie/chewie.dart';

class VideoListPage extends StatelessWidget {
  final ApiService apiService = ApiService("https://vot.co.tm/api/patient");

  VideoListPage({Key? key}) : super(key: key);

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('token');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<String?>(
          future: _getToken(),
          builder: (context, tokenSnapshot) {
            if (tokenSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (tokenSnapshot.hasError) {
              return Center(child: Text('Error fetching token'));
            } else if (tokenSnapshot.hasData && tokenSnapshot.data != null) {
              final token = tokenSnapshot.data!;
              return FutureBuilder<Patient>(
                future: apiService.getPatientData(token),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                      color: Color(0xFFFFAA33),
                    ));
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    final patient = snapshot.data!;
                    final videos = patient.videos;

                    return ListView.builder(
                      itemCount: videos.length,
                      itemBuilder: (context, index) {
                        final video = videos[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: ListTile(
                            leading: const Icon(Icons.video_collection,
                                color: Color(0xFFFFAA33)),
                            title: Text("Video ${video['id']}"),
                            trailing: IconButton(
                              icon: const Icon(Icons.play_arrow,
                                  color: Color(0xFFFFAA33)),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VideoPlayerPage(
                                        videoUrl: video['source']),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text('No data available'));
                  }
                },
              );
            } else {
              return const Center(child: Text('Token not available'));
            }
          },
        ),
      ),
    );
  }
}

class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerPage({super.key, required this.videoUrl});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();

    _videoPlayerController = VideoPlayerController.network(
      "https://vot.co.tm/${widget.videoUrl}",
    )..initialize().then((_) {
        setState(() {}); // Ensure the UI updates once the video is initialized
      });

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      looping: false,
      allowFullScreen: true,
      aspectRatio: _videoPlayerController.value.aspectRatio,
    );
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_chewieController?.isFullScreen == true) {
      _chewieController?.exitFullScreen();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: _videoPlayerController.value.isInitialized
              ? Chewie(controller: _chewieController!)
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ),
    );
  }
}
