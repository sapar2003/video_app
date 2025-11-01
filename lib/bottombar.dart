import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video/image.dart';
import 'package:video/login_page.dart';
import 'package:video/videolist_page.dart';


class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;
  SharedPreferences? prefs;

  final List<Widget> _pages = [
    VideoListPage(),
    const CustomImage(),
  ];

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    _loadToken();
  }

  Future<void> _loadToken() async {
    prefs = await SharedPreferences.getInstance();
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ulgamdan çykmak'),
          content: const Text('Hakykatdanam ulgamdan çykmak isleýänizmi?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Bes et'),
            ),
            TextButton(
              onPressed: () async {
                prefs = await SharedPreferences.getInstance();
                prefs!.clear();
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ));
              },
              child: const Text('Ulgamdan çykmak'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0 || _selectedIndex == 1
          ? _pages[_selectedIndex]
          : Container(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        showUnselectedLabels: false,
        showSelectedLabels: false,
        onTap: (index) {
          if (index == 1) {
            _showLogoutDialog(context);
          } else {
            setState(() {
              _selectedIndex = index;
              if (index == 2) _selectedIndex = 1;
            });
          }
        },
        backgroundColor: Colors.yellow.shade900,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: "My Videos",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: "Logout",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.videocam),
            label: "Record Video",
          ),
        ],
      ),
    );
  }
}
