/* import 'package:docutain_sdk/docutain_sdk.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:path/path.dart';

Future<void> scanAndSaveDocument(BuildContext context) async {
  try {
    // Scanner le document avec Docutain
    final result = await DocutainSdk.startDocumentScanner(
      multiPage: false,
      exportFormat: ExportFormat.JPG,
    );

    if (result?.images != null && result!.images!.isNotEmpty) {
      final File imageFile = result.images!.first;
      final fileName = basename(imageFile.path);

      // Référence dans Firebase Storage
      final ref = FirebaseStorage.instance.ref().child(
        "scanned_documents/$fileName",
      );

      // Upload
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Enregistrement dans Firestore (optionnel)
      await FirebaseFirestore.instance.collection('documents_scannes').add({
        'url': downloadUrl,
        'timestamp': Timestamp.now(),
        'nom': fileName,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Document enregistré avec succès !')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Aucun document scanné.')));
    }
  } catch (e) {
    print("Erreur : $e");
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
  }
}
 */
