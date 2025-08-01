import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class ColorApp {
  static const bgHome = Color.fromARGB(255, 100, 34, 184);
}

/// Redesigned LUMEEI app with fixed header elements
class LumeeiRedesignedWidget extends StatefulWidget {
  const LumeeiRedesignedWidget({super.key});

  static String routeName = 'lumeei_redesigned';
  static String routePath = '/lumeeiRedesigned';

  @override
  State<LumeeiRedesignedWidget> createState() => _LumeeiRedesignedWidgetState();
}

class _LumeeiRedesignedWidgetState extends State<LumeeiRedesignedWidget> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocusNode = FocusNode();
  String? _selectedGrade;
  String? _selectedSubject;
  String? _selectedDuration;

  @override
  void dispose() {
    _textController.dispose();
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: ColorApp.bgHome,
        body: SafeArea(
          child: Column(
            children: [
              // Fixed header elements
              _buildStatusBar(),
              _buildHeader(),
              _buildTabs(),
              
              // Scrollable content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildSearchBar(context),
                      Expanded(child: _buildContent(context)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '09:00 AM',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              _buildSignalBars(),
              const SizedBox(width: 6),
              const Text(
                '5G',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              _buildBattery(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignalBars() {
    return Row(
      children: List.generate(4, (index) => Container(
        width: 3,
        height: 4 + (index * 2).toDouble(),
        margin: const EdgeInsets.only(right: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(1),
        ),
      )),
    );
  }

  Widget _buildBattery() {
    return Container(
      width: 24,
      height: 12,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 1),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Stack(
        children: [
          Container(
            width: 18,
            height: 8,
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          Positioned(
            right: -2,
            top: 3,
            child: Container(
              width: 2,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'LUMEEI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.search,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenWidth < 550;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // First row of tabs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 0.28 * screenWidth,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.white60,
                  ),
                  child: Text(
                    "Long",
                    style: GoogleFonts.openSans(
                      color: Colors.black,
                      fontSize: isSmallScreen ? 16 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 0.28 * screenWidth,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.white60,
                  ),
                  child: Text(
                    "Short",
                    style: GoogleFonts.openSans(
                      color: Colors.black,
                      fontSize: isSmallScreen ? 16 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 0.28 * screenWidth,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.white60,
                  ),
                  child: Text(
                    "Talk",
                    style: GoogleFonts.openSans(
                      color: Colors.black,
                      fontSize: isSmallScreen ? 16 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.016),
          
          // Second row of filter tabs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 0.28 * screenWidth,
                height: 0.04 * screenHeight,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.white.withOpacity(0.3),
                  ),
                  child: Text(
                    "Filter",
                    style: GoogleFonts.openSans(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 0.28 * screenWidth,
                height: 0.04 * screenHeight,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.white.withOpacity(0.3),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          "5. osztály",
                          style: GoogleFonts.openSans(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 11 : 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Remove filter functionality
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            Icons.close_rounded,
                            size: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 0.28 * screenWidth,
                height: 0.04 * screenHeight,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.white.withOpacity(0.3),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          "Történelem",
                          style: GoogleFonts.openSans(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 11 : 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Remove filter functionality
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            Icons.close_rounded,
                            size: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: FadeInUp(
        child: TextField(
          controller: _textController,
          focusNode: _textFieldFocusNode,
          decoration: InputDecoration(
            hintText: 'Search audio lessons...',
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
          ),
          style: GoogleFonts.poppins(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFeaturedSection(context),
          const SizedBox(height: 16),
          _buildAudioList(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection(BuildContext context) {
    return FadeInUp(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Audio',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1F24),
                ),
              ),
              TextButton(
                onPressed: () => print('View all pressed'),
                child: Text(
                  'View All',
                  style: GoogleFonts.poppins(
                    color: ColorApp.bgHome,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ColorApp.bgHome, ColorApp.bgHome.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Math Adventures',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Grade 3 • Addition & Subtraction',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Join Captain Numbers on an exciting journey through basic math operations!',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white70,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.play_circle_filled, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '15 min',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.headphones,
                      color: ColorApp.bgHome,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioList(BuildContext context) {
    final audioLessons = [
      {
        'title': 'Science Sounds: Animal Kingdom',
        'grade': 'Grade 2 • Life Science',
        'description': 'Discover amazing animal sounds and learn about different species in their natural habitats.',
        'duration': '12 min',
        'rating': 4.5,
        'icon': Icons.volume_up,
        'iconColor': ColorApp.bgHome,
        'bgColor': const Color(0xFFE8F5E8),
      },
      {
        'title': 'Story Time: The Magic Forest',
        'grade': 'Grade 1 • Reading Comprehension',
        'description': 'A delightful fairy tale that teaches children about friendship and courage.',
        'duration': '18 min',
        'rating': 4.8,
        'icon': Icons.menu_book,
        'iconColor': Colors.green,
        'bgColor': const Color(0xFFFFF3E0),
      },
      {
        'title': 'Geography Explorer: World Capitals',
        'grade': 'Grade 4 • Social Studies',
        'description': 'Take a virtual trip around the world and learn about famous capital cities.',
        'duration': '22 min',
        'rating': 4.3,
        'icon': Icons.public,
        'iconColor': Colors.orange,
        'bgColor': const Color(0xFFF3E5F5),
      },
      {
        'title': 'Musical Math: Counting Songs',
        'grade': 'Grade 1 • Mathematics',
        'description': 'Learn to count from 1 to 100 with catchy songs and rhythmic patterns.',
        'duration': '8 min',
        'rating': 4.7,
        'icon': Icons.music_note,
        'iconColor': Colors.purple,
        'bgColor': const Color(0xFFE8F5E8),
      },
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: audioLessons.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final lesson = audioLessons[index];
        return ZoomIn(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: lesson['bgColor'] as Color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      lesson['icon'] as IconData,
                      color: lesson['iconColor'] as Color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson['title'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1F24),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          lesson['grade'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lesson['description'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: Colors.grey.shade600,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  lesson['duration'] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                RatingBarIndicator(
                                  rating: lesson['rating'] as double,
                                  itemBuilder: (context, index) => const Icon(
                                    Icons.star,
                                    color: Color(0xFFFFD700),
                                  ),
                                  itemCount: 5,
                                  itemSize: 12,
                                  unratedColor: Colors.grey.shade300,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  lesson['rating'].toString(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: ColorApp.bgHome,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
                      onPressed: () => print('Play ${lesson['title']} pressed'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}