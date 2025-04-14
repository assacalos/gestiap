import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:gestiap/core/constants/app_constants.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final Function(int) onTabChange;
  final int initialIndex;

  CustomBottomNavigationBar({
    required this.onTabChange,
    required this.initialIndex,
  });

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  late int _currentPageIndex;

  @override
  void initState() {
    super.initState();
    _currentPageIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: EdgeInsets.fromLTRB(25, 10, 25, 20),
      child: GNav(
        onTabChange: (value) {
          setState(() {
            _currentPageIndex = value;
          });
          widget.onTabChange(value);
        },
        selectedIndex: _currentPageIndex,
        gap: 8,
        tabActiveBorder: Border.all(color: Colors.black, width: 1),
        tabs: [
          GButton(icon: Icons.home, text: 'Home'),
          GButton(icon: Icons.settings, text: 'Paramètres'),
        ],
      ),
    );
  }
}

class CustomTitle extends StatelessWidget {
  final String title;

  CustomTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  String userName = "Utilisateur";
  String userImageUrl = "https://via.placeholder.com/150"; // Image par défaut

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userName = user.displayName ?? "Utilisateur";
        userImageUrl = user.photoURL ?? "https://via.placeholder.com/150";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(userImageUrl),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "Bienvenue 👋",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.search, color: Colors.black),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.notifications, color: Colors.black),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
