import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter TikTok Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyTikTokWidget(),
    );
  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }
}

// Videó adatok modellje - Csak a Lumeei adatbázis mezőivel
class VideoData {
  final String id;
  final String chapter;
  final String description;
  final String pictureURL;
  final String title;
  final String videoURL;

  VideoData({
    required this.id,
    required this.chapter,
    required this.description,
    required this.pictureURL,
    required this.title,
    required this.videoURL,
  });

  factory VideoData.fromJson(String key, Map<dynamic, dynamic> json) {
    return VideoData(
      id: json['id']?.toString() ?? key,
      chapter: json['chapter']?.toString() ?? '',
      description: json['description']?.toString() ?? 'NULL',
      pictureURL: json['picture_URL']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled',
      videoURL: json['video_URL']?.toString() ?? '',
    );
  }

  // Helper getters for UI display
  String get displayDescription {
    if (description == "NULL" || description.isEmpty) {
      return ''; // Don't show anything if NULL
    }
    return description;
  }

  String get username => '@lumeei_official';
  String get timeAgo => 'Recently';
  String get likeCount => '0';
  String get commentCount => '0';
  String get audioName => 'Lumeei Story';
  String get location => chapter.isNotEmpty ? chapter : 'Mesék';
}

class MyTikTokWidget extends StatefulWidget {
  const MyTikTokWidget({super.key});

  static String routeName = 'mytiktok';
  static String routePath = '/mytiktok';

  @override
  State<MyTikTokWidget> createState() => _MyTikTokWidgetState();
}

class _MyTikTokWidgetState extends State<MyTikTokWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  PageController pageController = PageController();
  int currentVideoIndex = 0;
  
  List<VideoData> videos = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadVideosFromFirebase();
  }

  Future<void> _loadVideosFromFirebase() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final DatabaseReference ref = FirebaseDatabase.instance.ref();
      
      // Get data from root of your Firebase database
      final DatabaseEvent event = await ref.once();

      if (event.snapshot.exists && event.snapshot.value != null) {
        final data = event.snapshot.value;
        List<VideoData> loadedVideos = [];

        print('Firebase data: $data'); // Debug print

        if (data is Map) {
          data.forEach((key, value) {
            if (value is Map) {
              try {
                // Check if this entry has the expected Lumeei structure
                if (value['id'] != null && value['video_URL'] != null) {
                  final video = VideoData.fromJson(key.toString(), Map<dynamic, dynamic>.from(value));
                  loadedVideos.add(video);
                  print('Added video: ${video.title}'); // Debug print
                }
              } catch (e) {
                print('Error parsing video $key: $e');
              }
            }
          });
        }

        if (loadedVideos.isNotEmpty) {
          // Sort by id or title if you want a specific order
          loadedVideos.sort((a, b) => a.id.compareTo(b.id));
          
          setState(() {
            videos = loadedVideos;
            isLoading = false;
            errorMessage = '';
          });
          print('Loaded ${loadedVideos.length} videos from Firebase');
        } else {
          setState(() {
            videos = [];
            isLoading = false;
            errorMessage = 'No valid videos found in database';
          });
        }
      } else {
        setState(() {
          videos = [];
          isLoading = false;
          errorMessage = 'Database is empty or unreachable';
        });
      }
    } catch (e) {
      print('Firebase error: $e');
      setState(() {
        videos = [];
        errorMessage = 'Error connecting to Firebase: $e';
        isLoading = false;
      });
    }
  }

  void _useFallbackVideos() {
    setState(() {
      videos = [
        VideoData(
          id: '1',
          imageUrl: 'https://picsum.photos/1080/1920?random=1',
          videoUrl: '',
          username: '@creative_artist',
          timeAgo: '2 hours ago',
          description: 'Amazing sunset timelapse from the rooftop! 🌅 What do you think about this view? #sunset #timelapse #beautiful',
          audioName: 'Original Audio',
          location: 'Downtown',
          likeCount: '12.5K',
          commentCount: '892',
          profileImageUrl: 'https://picsum.photos/500/500?random=11',
        ),
        VideoData(
          id: '2',
          imageUrl: 'https://picsum.photos/1080/1920?random=2',
          videoUrl: '',
          username: '@nature_lover',
          timeAgo: '4 hours ago',
          description: 'Forest walk in the morning 🌲🌿 The sounds of nature are so peaceful #nature #forest #morning #peaceful',
          audioName: 'Nature Sounds',
          location: 'Forest Park',
          likeCount: '8.3K',
          commentCount: '456',
          profileImageUrl: 'https://picsum.photos/500/500?random=12',
        ),
        VideoData(
          id: '3',
          imageUrl: 'https://picsum.photos/1080/1920?random=3',
          videoUrl: '',
          username: '@food_explorer',
          timeAgo: '6 hours ago',
          description: 'Making homemade pasta from scratch! 🍝👨‍🍳 Recipe in my bio! #cooking #pasta #homemade #recipe',
          audioName: 'Cooking Music',
          location: 'Kitchen',
          likeCount: '15.7K',
          commentCount: '1.2K',
          profileImageUrl: 'https://picsum.photos/500/500?random=13',
        ),
      ];
      isLoading = false;
      errorMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.black,
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Loading videos from Firebase...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (videos.isEmpty && errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Unable to load videos',
                style: GoogleFonts.lexend(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                style: GoogleFonts.lexend(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    errorMessage = '';
                  });
                  _loadVideosFromFirebase();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (videos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.video_library_outlined,
              color: Colors.white,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No videos found',
              style: GoogleFonts.lexend(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check your Firebase database',
              style: GoogleFonts.lexend(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return PageView.builder(
      controller: pageController,
      scrollDirection: Axis.vertical,
      itemCount: videos.length,
      onPageChanged: (index) {
        setState(() {
          currentVideoIndex = index;
        });
      },
      itemBuilder: (context, index) {
        return VideoPlayerWidget(
          videoData: videos[index],
          currentIndex: index,
          totalVideos: videos.length,
          isVisible: currentVideoIndex == index, // Pass visibility state
        );
      },
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final VideoData videoData;
  final int currentIndex;
  final int totalVideos;
  final bool isVisible; // To know when this video is currently visible

  const VideoPlayerWidget({
    super.key,
    required this.videoData,
    required this.currentIndex,
    required this.totalVideos,
    this.isVisible = false,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  double ratingBarValue = 0.0;
  bool isLiked = false;
  bool isSaved = false;
  bool isPlaying = false;
  
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;
  bool _hasError = false;
  bool _showThumbnail = true;

  @override
  void initState() {
    super.initState();
    if (widget.videoData.videoURL.isNotEmpty) {
      _initializeVideo();
    }
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Auto-play when this video becomes visible
    if (widget.isVisible && !oldWidget.isVisible) {
      _playVideo();
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _pauseVideo();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoData.videoURL),
      );
      
      await _videoController!.initialize();
      
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        aspectRatio: _videoController!.value.aspectRatio,
        autoPlay: false,
        looping: true,
        showControls: false, // We'll use custom controls
        allowFullScreen: false,
        allowMuting: true,
        showControlsOnInitialize: false,
      );
      
      _videoController!.addListener(() {
        if (mounted) {
          setState(() {
            isPlaying = _videoController!.value.isPlaying;
          });
        }
      });
      
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
          _hasError = false;
        });
      }
    } catch (e) {
      print('Video initialization error: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isVideoInitialized = false;
        });
      }
    }
  }

  void _togglePlayPause() {
    if (_videoController != null && _isVideoInitialized) {
      setState(() {
        if (_videoController!.value.isPlaying) {
          _videoController!.pause();
          isPlaying = false;
        } else {
          _videoController!.play();
          _showThumbnail = false; // Hide thumbnail when playing
          isPlaying = true;
        }
      });
    }
  }

  void _playVideo() {
    if (_videoController != null && _isVideoInitialized) {
      _videoController!.play();
      setState(() {
        isPlaying = true;
        _showThumbnail = false;
      });
    }
  }

  void _pauseVideo() {
    if (_videoController != null && _isVideoInitialized) {
      _videoController!.pause();
      setState(() {
        isPlaying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // Background video/image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: Stack(
              children: [
          // Background video/image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: Stack(
              children: [
                // Video player or thumbnail
                if (_isVideoInitialized && !_hasError && !_showThumbnail)
                  // Actual video player
                  SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoController!.value.size.width,
                        height: _videoController!.value.size.height,
                        child: Chewie(controller: _chewieController!),
                      ),
                    ),
                  )
                else
                  // Thumbnail image (fallback or when video is paused)
                  CachedNetworkImage(
                    fadeInDuration: const Duration(milliseconds: 0),
                    fadeOutDuration: const Duration(milliseconds: 0),
                    imageUrl: widget.videoData.pictureURL,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: Icon(
                          Icons.error,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                
                // Video loading indicator
                if (!_isVideoInitialized && !_hasError && widget.videoData.videoURL.isNotEmpty)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Loading video...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Gradient overlay
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Color(0x33000000),
                        Colors.transparent
                      ],
                      stops: [0, 0.7, 1],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                // Main content
                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 56, 16, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'For You',
                            style: GoogleFonts.lexend(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            children: [
                              _buildIconButton(
                                icon: Icons.refresh,
                                onPressed: () {
                                  // Reload videos from Firebase
                                  if (mounted) {
                                    final parent = context.findAncestorStateOfType<_MyTikTokWidgetState>();
                                    parent?._loadVideosFromFirebase();
                                  }
                                },
                              ),
                              const SizedBox(width: 16),
                              _buildIconButton(
                                icon: Icons.search_rounded,
                                onPressed: () {
                                  print('Search pressed');
                                },
                              ),
                              const SizedBox(width: 16),
                              _buildIconButton(
                                icon: Icons.more_vert,
                                onPressed: () {
                                  print('More pressed');
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Bottom content
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Left side - video info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // User info
                                Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                      child: CachedNetworkImage(
                                        imageUrl: widget.videoData.profileImageUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          color: Colors.grey[700],
                                        ),
                                        errorWidget: (context, url, error) =>
                                        const Icon(Icons.person, color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.videoData.username,
                                          style: GoogleFonts.lexend(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          widget.videoData.timeAgo,
                                          style: GoogleFonts.lexend(
                                            fontSize: 12,
                                            color: const Color(0xCCFFFFFF),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Video description - show title and chapter info
                                Container(
                                  width: 280,
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Title
                                      Text(
                                        widget.videoData.title,
                                        maxLines: 2,
                                        style: GoogleFonts.lexend(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          height: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Chapter info
                                      if (widget.videoData.chapter.isNotEmpty)
                                        Text(
                                          widget.videoData.chapter,
                                          style: GoogleFonts.lexend(
                                            fontSize: 14,
                                            color: const Color(0xCCFFFFFF),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      const SizedBox(height: 4),
                                      // Description if available
                                      if (widget.videoData.description != widget.videoData.title && 
                                          widget.videoData.description.isNotEmpty)
                                        Text(
                                          widget.videoData.description,
                                          maxLines: 2,
                                          style: GoogleFonts.lexend(
                                            fontSize: 15,
                                            color: Colors.white,
                                            height: 1.3,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Audio and chapter info
                                Row(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.play_circle_outline,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Lumeei Story',
                                          style: GoogleFonts.lexend(
                                            fontSize: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 16),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.book_outlined,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            widget.videoData.chapter.isNotEmpty 
                                                ? widget.videoData.chapter 
                                                : 'Mesék',
                                            style: GoogleFonts.lexend(
                                              fontSize: 12,
                                              color: Colors.white,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Right side - action buttons
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Like button
                              _buildActionButton(
                                icon: isLiked ? Icons.favorite : Icons.favorite_border,
                                label: widget.videoData.likeCount,
                                color: isLiked ? Colors.red : Colors.white,
                                onPressed: () {
                                  setState(() {
                                    isLiked = !isLiked;
                                  });
                                },
                              ),
                              const SizedBox(height: 24),
                              // Comment button
                              _buildActionButton(
                                icon: Icons.chat_bubble_outline,
                                label: widget.videoData.commentCount,
                                onPressed: () {
                                  print('Comment pressed');
                                },
                              ),
                              const SizedBox(height: 24),
                              // Share button
                              _buildActionButton(
                                icon: Icons.share,
                                label: 'Share',
                                onPressed: () {
                                  print('Share pressed');
                                },
                              ),
                              const SizedBox(height: 24),
                              // Rating
                              Column(
                                children: [
                                  RatingBar.builder(
                                    onRatingUpdate: (newValue) {
                                      setState(() {
                                        ratingBarValue = newValue;
                                      });
                                    },
                                    itemBuilder: (context, index) => const Icon(
                                      Icons.star,
                                      color: Colors.orange,
                                    ),
                                    direction: Axis.horizontal,
                                    initialRating: ratingBarValue,
                                    unratedColor: const Color(0x66FFFFFF),
                                    itemCount: 5,
                                    itemSize: 24,
                                    glowColor: Colors.orange,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Save button
                              _buildActionButton(
                                icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                                label: 'Save',
                                color: isSaved ? Colors.yellow : Colors.white,
                                onPressed: () {
                                  setState(() {
                                    isSaved = !isSaved;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Progress indicator (right side)
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 4,
              height: 200,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: const Color(0x33FFFFFF),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Column(
                children: List.generate(widget.totalVideos, (index) {
                  return Expanded(
                    child: Container(
                      width: 4,
                      margin: const EdgeInsets.symmetric(vertical: 1),
                      decoration: BoxDecoration(
                        color: index == widget.currentIndex 
                            ? Colors.white 
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          // Play/Pause button (center)
          Center(
            child: GestureDetector(
              onTap: _togglePlayPause,
              child: AnimatedOpacity(
                opacity: (!isPlaying || _showThumbnail) ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.6),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    _hasError 
                        ? Icons.error 
                        : !_isVideoInitialized 
                            ? Icons.download 
                            : isPlaying 
                                ? Icons.pause 
                                : Icons.play_arrow,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
          // Video counter indicator (top right)
          Positioned(
            top: 100,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0x66000000),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${widget.currentIndex + 1}/${widget.totalVideos}',
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0x33000000),
        ),
        child: Icon(
          icon,
          color: color ?? Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0x33000000),
            ),
            child: Icon(
              icon,
              color: color ?? Colors.white,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.lexend(
            fontSize: 12,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}