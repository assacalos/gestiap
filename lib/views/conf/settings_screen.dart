import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'package:url_launcher/url_launcher.dart'; // Pour ouvrir des URL
import 'package:gestiap/views/conf/info_account_page.dart';

class SettingsScreen extends StatelessWidget {
  Future<void> _logout(BuildContext context) async {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    await authProvider.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  /*  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(
      url,
    ); //Utilise le package url_launcher pour ouvrir l'URL de votre politique de confidentialité dans un navigateur externe
    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(uri).showSnackBar(
        SnackBar(content: Text('Impossible d\'ouvrir le lien : $url')),
      );
    }
  } */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Paramètres')),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Informations du compte'),
            onTap: () {
              // Naviguer vers l'écran d'informations du compte
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AccountInfoScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
            trailing: Switch(
              value:
                  true, // Remplacez par la logique pour récupérer l'état des notifications
              onChanged: (bool value) {
                // Logique pour activer/désactiver les notifications
                print('Notifications activées : $value');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Notifications mises à jour')),
                );
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Langue'),
            onTap: () {
              // Afficher une boîte de dialogue pour choisir la langue
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Choisir la langue'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          title: Text('Français'),
                          onTap: () {
                            // Logique pour changer la langue en français
                            print('Langue : Français');
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Langue changée en Français'),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: Text('Anglais'),
                          onTap: () {
                            // Logique pour changer la langue en anglais
                            print('Langue : Anglais');
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Langue changée en Anglais'),
                              ),
                            );
                          },
                        ),
                        // Ajoutez d'autres langues ici
                      ],
                    ),
                  );
                },
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Confidentialité'),
            onTap: () {
              // Ouvrir la page de politique de confidentialité
              //_launchURL('https://votre-politique-de-confidentialite.com'); // Remplacez par votre URL
            },
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('À propos'),
            onTap: () {
              // Naviguer vers l'écran "À propos" de l'application
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutScreen()),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Se déconnecter', style: TextStyle(color: Colors.red)),
            onTap: () {
              // Afficher une boîte de dialogue de confirmation avant la déconnexion
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Se déconnecter ?'),
                    content: Text(
                      'Êtes-vous sûr de vouloir vous déconnecter ?',
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Annuler'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: Text('Se déconnecter'),
                        onPressed: () {
                          _logout(context);
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class AccountInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Informations du compte')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Nom d\'utilisateur : [Nom de l\'utilisateur]',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text('Email : [Adresse email]', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Logique pour modifier le mot de passe
                print('Modifier le mot de passe');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Fonctionnalité de modification du mot de passe',
                    ),
                  ),
                );
              },
              child: Text('Modifier le mot de passe'),
            ),
            // Ajoutez d'autres informations ou actions liées au compte
          ],
        ),
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('À propos de l\'application')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Nom de l\'application : GESTAP',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Version : 1.0.0', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text(
              'Développé par : Votre Nom/Entreprise',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Description :',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Ceci est une description de votre application GESTAP...',
              style: TextStyle(fontSize: 16),
            ),
            // Ajoutez d'autres informations comme les mentions légales, etc.
          ],
        ),
      ),
    );
  }
}
