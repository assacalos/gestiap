import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: Text('Notifications')),
      body:
          currentUser != null
              ? StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('notifications')
                        .where('recipientId', isEqualTo: currentUser.uid)
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Une erreur s\'est produite'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('Aucune notification'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final notification = snapshot.data!.docs[index];
                      final data = notification.data() as Map<String, dynamic>;
                      final type = data['type'];
                      final senderId = data['senderId'];
                      final timestamp =
                          (data['timestamp'] as Timestamp).toDate();
                      final documentId = data['documentId'];
                      final isRead = data['isRead'] ?? false;

                      // Marquer la notification comme lue lors de l'affichage
                      if (!isRead) {
                        FirebaseFirestore.instance
                            .collection('notifications')
                            .doc(notification.id)
                            .update({'isRead': true});
                      }

                      String message = '';
                      switch (type) {
                        case 'proforma_soumis':
                          message =
                              'Le commercial $senderId a soumis un proforma ($documentId)';
                          break;
                        case 'bordereau_soumis':
                          message =
                              'Le commercial $senderId a soumis un bordereau ($documentId)';
                          break;
                        case 'facture_soumise':
                          message =
                              'Le commercial $senderId a soumis une facture ($documentId)';
                          break;
                        default:
                          message = 'Nouvelle notification';
                      }

                      return ListTile(
                        title: Text(message),
                        subtitle: Text(
                          'Le ${DateFormat('dd/MM/yyyy HH:mm').format(timestamp)}',
                        ),
                        // Ajoutez ici une logique pour naviguer vers le document associé si nécessaire
                        onTap: () {
                          // Exemple de navigation basée sur le type et l'ID du document
                          if (type == 'proforma_soumis') {
                            // Navigator.push(...) vers l'écran du proforma
                          }
                        },
                        tileColor: isRead ? Colors.grey[200] : null,
                      );
                    },
                  );
                },
              )
              : Center(
                child: Text(
                  'Vous devez être connecté pour voir les notifications',
                ),
              ),
    );
  }
}
