import 'package:apptvshow/home.dart';
import 'package:apptvshow/screen/moviesapp.dart';
import 'package:apptvshow/screen/tvapp.dart';
import 'package:apptvshow/userSettings.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class MyApp1 extends StatelessWidget {
  final String userId;
  
  const MyApp1({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(userId: userId),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String userId;

  const MyHomePage({Key? key, required this.userId}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class TemakorService {
  final databaseRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://lumeei-test-default-rtdb.europe-west1.firebasedatabase.app',
  ).ref();

  Future<Map<String, dynamic>> fetchTemakorok() async {
    final snapshot = await databaseRef.child('temakorok').get();
    if (snapshot.exists) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    } else {
      throw Exception('A temakorok nem található');
    }
  }
}

class _MyHomePageState extends State<MyHomePage> {
  late PageController _pageController;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: selectedIndex);

    final temakorService = TemakorService();
    temakorService.fetchTemakorok().then((data) {
      print('Temakorok adatok: $data');
    }).catchError((error) {
      print('Hiba a temakorok beolvasásakor: $error');
    });
  }

  void onButtonPressed(int index) {
    setState(() {
      selectedIndex = index;
    });
    _pageController.animateToPage(
      selectedIndex,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutQuad,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black38,
      body: DoubleBackToCloseApp(
        snackBar: const SnackBar(
          content: Text('Nyomd meg újra a kilépéshez'),
        ),
        child: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: _listOfWidget(widget.userId),
        ),
      ),
      bottomNavigationBar: _buildCustomNavBar(),
    );
  }

  Widget _buildCustomNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.black38,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_outlined, 0),
          _buildNavItem(Icons.sports_esports_outlined, 1),
          _buildNavItem(Icons.circle_notifications_outlined, 2),
          _buildNavItem(Icons.account_circle_outlined, 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        onButtonPressed(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.pinkAccent : Colors.white,
            size: isSelected ? 30 : 24,
          ),
        ],
      ),
    );
  }
}

List<Widget> _listOfWidget(String userId) => <Widget>[
  Home(userId: userId),
  TvApp(),
  MoviesApp(),
  Usersettings(),
];
