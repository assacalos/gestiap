import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountInfoScreen extends StatefulWidget {
  @override
  _AccountInfoScreenState createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  User? _currentUser;
  String? _displayName;
  String? _email;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      _displayName = _currentUser!.displayName;
      _email = _currentUser!.email;
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Informations du compte')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Nom d\'utilisateur : ${_displayName ?? "Non défini"}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Email : ${_email ?? "Non défini"}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Logique pour modifier le mot de passe
                        _showChangePasswordDialog(context);
                      },
                      child: Text('Modifier le mot de passe'),
                    ),
                    // Ajoutez d'autres informations ou actions liées au compte ici
                  ],
                ),
              ),
    );
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final _formKey = GlobalKey<FormState>();
    final _passwordController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modifier le mot de passe'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Nouveau mot de passe'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un mot de passe';
                }
                if (value.length < 6) {
                  return 'Le mot de passe doit contenir au moins 6 caractères';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Modifier'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (_currentUser != null) {
                    try {
                      await _currentUser!.updatePassword(
                        _passwordController.text,
                      );
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Mot de passe mis à jour avec succès'),
                        ),
                      );
                    } catch (e) {
                      String errorMessage =
                          'Erreur lors de la mise à jour du mot de passe';
                      if (e is FirebaseAuthException) {
                        errorMessage = e.message ?? errorMessage;
                      }
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(errorMessage)));
                    }
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}
