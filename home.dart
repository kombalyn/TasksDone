import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const LumeeiApp());
}

class LumeeiApp extends StatelessWidget {
  const LumeeiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LUMEEI',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'SF Pro Display',
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedTab = 0;
  int selectedNavItem = 0;

  final List<String> tabs = ['Long', 'Short', 'Talk'];
  final List<String> secondaryTabs = ['Filter+', '5. osztály'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildStatusBar(),
              _buildHeader(),
              _buildTabs(),
              _buildSecondaryTabs(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildFeaturedCard(),
                      _buildContentSections(),
                      const SizedBox(height: 80), // Space for bottom nav
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
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
      children: List.generate(4, (index) {
        return Container(
          width: 3,
          height: 4.0 + (index * 2),
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
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
            width: 19,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          Positioned(
            right: -3,
            top: 3,
            child: Container(
              width: 2,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(1),
                  bottomRight: Radius.circular(1),
                ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(tabs.length, (index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedTab = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: selectedTab == index
                    ? Colors.black.withOpacity(0.3)
                    : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                tabs[index],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSecondaryTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: secondaryTabs.map((tab) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              tab,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFeaturedCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFff6b9d),
            Color(0xFFc44569),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Próbáld ki\nJátékainkat is',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Folyamatosan bővülő játékainkat',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.games,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSections() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildSection('Piramisok', [
            ContentItem('Gízai Nagy Piramis', '5. osztály, 11 lecke'),
            ContentItem('Egyiptomi Piramisok', 'Történelem'),
            ContentItem('Maja Piramisok', 'Régészet'),
          ]),
          _buildSection('Történelem', [
            ContentItem('Athéni Akropolisz', 'Ókori Görögország'),
            ContentItem('Középkori Lovagok', 'Feudalizmus'),
            ContentItem('Római Birodalom', 'Császárkor'),
          ]),
          _buildSection('Irodalom', [
            ContentItem('Petőfi Sándor', 'Magyar költészet'),
            ContentItem('Arany János', 'Balladák'),
            ContentItem('Mesék és mondák', 'Néphagyomány'),
          ]),
          _buildSection('Matematika', [
            ContentItem('Törtek', 'Alapműveletek'),
            ContentItem('Geometria', 'Síkidomok'),
            ContentItem('Szöveges feladatok', 'Problémamegoldás'),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<ContentItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length + 1,
            itemBuilder: (context, index) {
              if (index == items.length) {
                return _buildMoreButton();
              }
              return _buildContentItem(items[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContentItem(ContentItem item) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening: ${item.title}'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        width: 120,
        height: 80,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 9,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreButton() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loading more content...'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        width: 60,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: const Icon(
          Icons.arrow_forward,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final navItems = [
      NavItem(Icons.home, 'Terv'),
      NavItem(Icons.phone_android, 'Elemek'),
      NavItem(Icons.edit, 'Szöveg'),
      NavItem(Icons.movie, 'Filmtekeres'),
      NavItem(Icons.person, 'Arculat'),
      NavItem(Icons.cloud_upload, 'Feltöltések'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(navItems.length, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedNavItem = index;
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      navItems[index].icon,
                      color: selectedNavItem == index
                          ? const Color(0xFFff6b9d)
                          : Colors.white.withOpacity(0.6),
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      navItems[index].label,
                      style: TextStyle(
                        color: selectedNavItem == index
                            ? const Color(0xFFff6b9d)
                            : Colors.white.withOpacity(0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class ContentItem {
  final String title;
  final String subtitle;

  ContentItem(this.title, this.subtitle);
}

class NavItem {
  final IconData icon;
  final String label;

  NavItem(this.icon, this.label);
}