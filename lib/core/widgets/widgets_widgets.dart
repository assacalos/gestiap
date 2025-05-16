import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gestiap/views/conf/notifications_screen.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/providers/auth_provider.dart';
import 'package:gestiap/views/auth/login_screen.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:gestiap/core/constants/app_constants.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart';
import 'package:gestiap/views/conf/settings_screen.dart';

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

  /* void _handleScanDocument(BuildContext context) async {
    try {
      // Ouvre la caméra pour scanner un document
      var scannedDocument = await scan.scan();

      if (scannedDocument != null) {
        print('Document scanné : $scannedDocument');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document scanné avec succès !')),
        );
        // Traitement du document scanné ici
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Aucun document scanné.')));
      }
    } catch (e) {
      print('Erreur lors du scan : $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur lors du scan : $e')));
    }
  } */

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
          if (value != 2) {
            // Empêcher la navigation si c'est le bouton de scan
            widget.onTabChange(value);
            if (value == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            }
          }
        },
        selectedIndex: _currentPageIndex,
        gap: 8,
        tabActiveBorder: Border.all(color: Colors.black, width: 1),
        tabs: [
          GButton(icon: Icons.home, text: 'Home'),
          GButton(icon: Icons.settings, text: 'Paramètres'),
          GButton(
            // Notre bouton de scan personnalisé
            icon: Icons.scanner,
            text: 'Scanner',
            //   onPressed: () => _handleScanDocument(context),
          ),
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
  //final String? title;

  //CustomAppBar({this.title});
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  String userName = "Utilisateur";
  String userImageUrl = "https://via.placeholder.com/150"; // Image par défaut
  int _notificationCount = 0;
  late StreamSubscription<QuerySnapshot>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _subscribeToNotifications();
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
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

  void _subscribeToNotifications() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _notificationSubscription = FirebaseFirestore.instance
          .collection('notifications')
          .where('recipientId', isEqualTo: currentUser.uid)
          .where('isRead', isEqualTo: false)
          .snapshots()
          .listen((snapshot) {
            setState(() {
              _notificationCount = snapshot.docs.length;
            });
          });
    }
  }

  /* Future<void> _logout(BuildContext context) async {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    await authProvider.logout();
    // Après la déconnexion, redirigez l'utilisateur vers l'écran de connexion
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  } */

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
              /* IconButton(
                icon: Icon(Icons.logout, color: Colors.black),
                onPressed: () => _logout(context),
              ), */
              IconButton(
                icon: Icon(Icons.search, color: Colors.black),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.notifications, color: Colors.black),
                onPressed: () {
                  // Naviguer vers l'écran des notifications et marquer les notifications comme lues
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationsScreen(),
                    ),
                  ).then((_) {
                    // Rafraîchir le nombre de notifications (elles devraient être lues maintenant)
                    setState(() {
                      _notificationCount =
                          0; // Optimistic update, NotificationsScreen should handle marking as read
                    });
                  });
                },
              ),
              if (_notificationCount > 0)
                Positioned(
                  right: 5,
                  top: 5,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Center(
                      child: Text(
                        '$_notificationCount',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
