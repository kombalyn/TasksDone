import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

// Firebase service class
class TemakorService {
  final databaseRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://lumeei-test-default-rtdb.europe-west1.firebasedatabase.app',
  ).ref();

  Future<List<Map<String, dynamic>>> fetchVideoData({int offset = 0, int limit = 10}) async {
    try {
      final snapshot = await databaseRef.child('Video_hang_DB').get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final temakorMap = Map<String, dynamic>.from(data);
        final longMap = Map<String, dynamic>.from(temakorMap['long']);
        final elemekLista = List<Map<String, dynamic>>.from(
          (longMap['Matematika'] as Map)['8'].map(
            (e) => Map<String, dynamic>.from(e),
          ),
        );
        
        // Pagination logic - take slice based on offset and limit
        final startIndex = offset;
        final endIndex = (startIndex + limit).clamp(0, elemekLista.length);
        
        if (startIndex >= elemekLista.length) {
          return []; // No more data
        }
        
        return elemekLista
            .sublist(startIndex, endIndex)
            .where((elem) => elem['video_URL'] != null && (elem['video_URL'] as String).isNotEmpty)
            .toList();
      } else {
        throw Exception('A temakorok nem található');
      }
    } catch (e) {
      print('Hiba a Firebase adatok betöltésekor: $e');
      // Fallback videók teszteléshez with pagination simulation
      final fallbackData = [
        {
          'video_URL': 'https://storage.googleapis.com/lumeei_bucket/Lumeei%20vid2.MP4',
          'title': 'Lumeei Vid 2',
          'description': 'Sample video 1'
        },
        {
          'video_URL': 'https://storage.googleapis.com/lumeei_bucket/balazs_lumeeiVideo.mp4',
          'title': 'Balazs Video',
          'description': 'Sample video 2'
        },
        {
          'video_URL': 'https://storage.googleapis.com/lumeei_bucket/balazstori05_06_gorog-roma.mp4',
          'title': 'Görög-római történelem',
          'description': 'Sample video 3'
        },
        // Simulate more videos by repeating
        {
          'video_URL': 'https://storage.googleapis.com/lumeei_bucket/Lumeei%20vid2.MP4',
          'title': 'Lumeei Vid 2 (Copy)',
          'description': 'Sample video 4'
        },
        {
          'video_URL': 'https://storage.googleapis.com/lumeei_bucket/balazs_lumeeiVideo.mp4',
          'title': 'Balazs Video (Copy)',
          'description': 'Sample video 5'
        },
      ];
      
      final startIndex = offset;
      final endIndex = (startIndex + limit).clamp(0, fallbackData.length);
      
      if (startIndex >= fallbackData.length) {
        return []; // No more data
      }
      
      return fallbackData.sublist(startIndex, endIndex);
    }
  }
}

class VideoItem {
  final String url;
  final String title;
  final String description;
  VideoPlayerController? controller;
  bool isInitialized = false;
  bool isLoading = false;

  VideoItem({
    required this.url,
    required this.title,
    required this.description,
  });

  Future<void> initialize() async {
    if (controller != null || isLoading) return;
    
    isLoading = true;
    controller = VideoPlayerController.networkUrl(Uri.parse(url));
    
    try {
      await controller!.initialize();
      isInitialized = true;
    } catch (e) {
      print('Error initializing video: $e');
      controller?.dispose();
      controller = null;
    } finally {
      isLoading = false;
    }
  }

  void dispose() {
    controller?.dispose();
    controller = null;
    isInitialized = false;
  }
}

class TikTokStylePlayer extends StatefulWidget {
  const TikTokStylePlayer({Key? key}) : super(key: key);

  @override
  State<TikTokStylePlayer> createState() => _TikTokStylePlayerState();
}

class _TikTokStylePlayerState extends State<TikTokStylePlayer> {
  late PageController _pageController;
  List<VideoItem> _videos = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  final TemakorService _temakorService = TemakorService();
  final int _batchSize = 3; // Load 3 videos at a time
  int _currentOffset = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadInitialVideos();
  }

  Future<void> _loadInitialVideos() async {
    try {
      final videoData = await _temakorService.fetchVideoData(
        offset: 0, 
        limit: _batchSize
      );
      
      if (videoData.isNotEmpty) {
        _videos = videoData.map((data) => VideoItem(
          url: data['video_URL'] as String,
          title: data['title'] as String? ?? 'Untitled',
          description: data['description'] as String? ?? '',
        )).toList();
        
        _currentOffset = _batchSize;
        
        // Pre-load the first video
        if (_videos.isNotEmpty) {
          await _videos[0].initialize();
        }
        
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasMoreData = false;
        });
      }
    } catch (e) {
      print('Error loading initial videos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreVideos() async {
    if (_isLoadingMore || !_hasMoreData) return;
    
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final videoData = await _temakorService.fetchVideoData(
        offset: _currentOffset,
        limit: _batchSize
      );
      
      if (videoData.isNotEmpty) {
        final newVideos = videoData.map((data) => VideoItem(
          url: data['video_URL'] as String,
          title: data['title'] as String? ?? 'Untitled',
          description: data['description'] as String? ?? '',
        )).toList();
        
        _videos.addAll(newVideos);
        _currentOffset += _batchSize;
        
        setState(() {
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _hasMoreData = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      print('Error loading more videos: $e');
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _onPageChanged(int index) {
    // Pause previous video
    if (_currentIndex < _videos.length && _videos[_currentIndex].controller != null) {
      _videos[_currentIndex].controller!.pause();
    }
    
    setState(() {
      _currentIndex = index;
    });
    
    // Initialize current video if not done
    if (index < _videos.length && !_videos[index].isInitialized && !_videos[index].isLoading) {
      _videos[index].initialize().then((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
    
    // Pre-load next video
    if (index + 1 < _videos.length && !_videos[index + 1].isInitialized && !_videos[index + 1].isLoading) {
      _videos[index + 1].initialize();
    }
    
    // Load more videos when approaching the end
    if (index >= _videos.length - 2 && _hasMoreData) {
      _loadMoreVideos();
    }
    
    // Clean up old videos to save memory (keep 5 videos in memory)
    _cleanupOldVideos(index);
  }

  void _cleanupOldVideos(int currentIndex) {
    const keepRange = 2; // Keep 2 videos before and after current
    
    for (int i = 0; i < _videos.length; i++) {
      if ((i < currentIndex - keepRange || i > currentIndex + keepRange) && _videos[i].isInitialized) {
        _videos[i].dispose();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final orientation = MediaQuery.of(context).orientation;
    if (orientation == Orientation.landscape) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  void dispose() {
    for (var video in _videos) {
      video.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  PopupMenuItem<double> _buildSpeedMenuItem(double speed) {
    return PopupMenuItem<double>(
      value: speed,
      child: Text(
        "${speed}x",
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildVideoPlayer(int index) {
    if (index >= _videos.length) {
      return const Center(child: CircularProgressIndicator());
    }

    final video = _videos[index];
    final controller = video.controller;
    
    return GestureDetector(
      onTap: () {
        if (controller != null && controller.value.isInitialized) {
          controller.value.isPlaying ? controller.pause() : controller.play();
        }
      },
      child: Container(
        color: Colors.black,
        child: video.isInitialized && controller != null
            ? Stack(
                alignment: Alignment.center,
                children: [
                  // Video player
                  SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: controller.value.size.width,
                        height: controller.value.size.height,
                        child: VideoPlayer(controller),
                      ),
                    ),
                  ),

                  // Play/Pause icon
                  if (!controller.value.isPlaying)
                    const Center(
                      child: Icon(
                        Icons.play_circle_outline_sharp,
                        color: Colors.white70,
                        size: 80,
                      ),
                    ),

                  // Speed menu (top right)
                  if (!controller.value.isPlaying)
                    Positioned(
                      top: 50,
                      right: 20,
                      child: Column(
                        children: [
                          PopupMenuButton<double>(
                            initialValue: controller.value.playbackSpeed,
                            onSelected: (double speed) {
                              controller.setPlaybackSpeed(speed);
                            },
                            icon: const Icon(
                              Icons.speed,
                              color: Colors.white,
                              size: 40,
                            ),
                            color: Colors.black87,
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<double>>[
                              _buildSpeedMenuItem(0.5),
                              _buildSpeedMenuItem(0.75),
                              _buildSpeedMenuItem(1.0),
                              _buildSpeedMenuItem(1.25),
                              _buildSpeedMenuItem(1.5),
                              _buildSpeedMenuItem(2.0),
                            ],
                          ),
                          const Text(
                            "Sebesség",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          )
                        ],
                      ),
                    ),

                  // Video counter and title (top left)
                  Positioned(
                    top: 50,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${index + 1} / ${_hasMoreData ? '${_videos.length}+' : _videos.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (video.title.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              video.title,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                  ),

                  // Loading more indicator (top center)
                  if (_isLoadingMore)
                    const Positioned(
                      top: 50,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Töltés...',
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Progress bar (bottom)
                  Positioned(
                    bottom: 30,
                    left: 20,
                    right: 20,
                    child: VideoProgressIndicator(
                      controller,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: Colors.purple,
                        backgroundColor: Colors.white24,
                        bufferedColor: Colors.white38,
                      ),
                    ),
                  ),

                  // Navigation guide
                  if (!controller.value.isPlaying)
                    Positioned(
                      bottom: 100,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.swipe_vertical, 
                                 color: Colors.white54, size: 30),
                            const Text(
                              'Húzz fel/le a videók között',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                              ),
                            ),
                            if (_hasMoreData) ...[
                              const SizedBox(height: 8),
                              const Text(
                                '∞ Végtelen scroll',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                ],
              )
            : Center(
                child: video.isLoading 
                    ? const CircularProgressIndicator(color: Colors.purple)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, color: Colors.white54, size: 50),
                          const SizedBox(height: 10),
                          Text(
                            'Videó betöltési hiba',
                            style: const TextStyle(color: Colors.white54, fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              video.initialize().then((_) {
                                if (mounted) setState(() {});
                              });
                            },
                            child: const Text('Újrapróbálás'),
                          ),
                        ],
                      ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.purple),
                    SizedBox(height: 20),
                    Text(
                      'Videók betöltése...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              )
            : _videos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, color: Colors.white, size: 50),
                        const SizedBox(height: 20),
                        const Text(
                          'Nem sikerült betölteni a videókat',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                              _currentOffset = 0;
                              _hasMoreData = true;
                            });
                            _loadInitialVideos();
                          },
                          child: const Text('Újrapróbálás'),
                        ),
                      ],
                    ),
                  )
                : PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    onPageChanged: _onPageChanged,
                    itemCount: _videos.length,
                    itemBuilder: (context, index) {
                      return _buildVideoPlayer(index);
                    },
                  ),
      ),
    );
  }
}