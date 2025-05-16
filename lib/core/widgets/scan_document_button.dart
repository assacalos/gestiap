/* import 'package:flutter/material.dart';
import 'package:flutter_document_scanner/flutter_document_scanner.dart';

class ScanDocumentButton extends StatelessWidget {
  final VoidCallback? onDocumentScanned;

  const ScanDocumentButton({super.key, this.onDocumentScanned});

  Future<void> _scanDocument(BuildContext context) async {
    final scannedDocument = await FlutterDocumentScanner.open();
    if (scannedDocument != null) {
      // Traitez le document scanné ici. `scannedDocument` contient le chemin du fichier.
      print('Document scanné : ${scannedDocument.path}');
      if (onDocumentScanned != null) {
        onDocumentScanned!(); // Notifiez le parent si un callback est fourni
      }
      // Vous pouvez naviguer vers une autre page pour afficher/modifier le document,
      // l'envoyer à un serveur, etc.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document scanné avec succès !')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Aucun document scanné.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _scanDocument(context),
      child: const Icon(Icons.scanner),
      tooltip: 'Scanner un document',
    );
  }
}
 */
