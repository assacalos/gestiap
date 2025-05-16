/* import 'package:flutter/material.dart';
import 'package:gestiap/features/technicien/data/models/stock_model.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Assurez-vous que le chemin est correct

class StockScannerScreen extends StatefulWidget {
  @override
  _StockScannerScreenState createState() => _StockScannerScreenState();
}

class _StockScannerScreenState extends State<StockScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? qrResult;
  bool _isProcessing = false;

  @override
  void reassemble() {
    super.reassemble();
    controller!.pauseCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scanner Code QR Stock')),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(key: qrKey, onQRViewCreated: _onQRViewCreated),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child:
                  (qrResult != null)
                      ? Text(
                        'Code Produit Scanné: $qrResult',
                        style: TextStyle(fontSize: 18),
                      )
                      : Text('Scannez le code produit'),
            ),
          ),
          if (qrResult != null && !_isProcessing)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () => _gererStock(qrResult!, 'entree'),
                    child: Text('Entrée Stock'),
                  ),
                  ElevatedButton(
                    onPressed: () => _gererStock(qrResult!, 'sortie'),
                    child: Text('Sortie Stock'),
                  ),
                ],
              ),
            ),
          if (_isProcessing) Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrResult = scanData.code;
        controller.pauseCamera(); // Mettre en pause la caméra après la lecture
      });
    });
  }

  Future<void> _gererStock(String codeProduit, String typeOperation) async {
    setState(() {
      _isProcessing = true;
    });
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance
              .collection('stock')
              .where('codeProduit', isEqualTo: codeProduit)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot stockDoc = querySnapshot.docs.first;
        StockItem item = StockItem.fromMap(
          stockDoc.data() as Map<String, dynamic>,
          stockDoc.id,
        );
        int currentQuantity = int.tryParse(item.quantiteEnStock ?? '0') ?? 0;
        int nouvelleQuantite;

        // Afficher un dialogue pour demander la quantité à ajouter/retirer
        int? quantiteModifiee = await _afficherDialogueQuantite(context);

        if (quantiteModifiee != null && quantiteModifiee > 0) {
          if (typeOperation == 'entree') {
            nouvelleQuantite = currentQuantity + quantiteModifiee;
          } else if (typeOperation == 'sortie') {
            if (currentQuantity >= quantiteModifiee) {
              nouvelleQuantite = currentQuantity - quantiteModifiee;
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Quantité en stock insuffisante pour la sortie.',
                  ),
                ),
              );
              setState(() {
                _isProcessing = false;
              });
              controller?.resumeCamera();
              return;
            }
          } else {
            setState(() {
              _isProcessing = false;
            });
            controller?.resumeCamera();
            return;
          }

          await FirebaseFirestore.instance
              .collection('stock')
              .doc(stockDoc.id)
              .update({'quantiteEnStock': nouvelleQuantite.toString()});

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Stock mis à jour: $nouvelleQuantite')),
          );
          setState(() {
            qrResult =
                null; // Réinitialiser le résultat pour permettre un nouveau scan
            _isProcessing = false;
          });
          controller?.resumeCamera(); // Reprendre la caméra après l'opération
        } else {
          setState(() {
            _isProcessing = false;
          });
          controller?.resumeCamera();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Article avec ce code produit non trouvé dans le stock.',
            ),
          ),
        );
        setState(() {
          _isProcessing = false;
        });
        controller?.resumeCamera();
      }
    } catch (e) {
      print('Erreur lors de la gestion du stock: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour du stock.')),
      );
      setState(() {
        _isProcessing = false;
      });
      controller?.resumeCamera();
    }
  }

  Future<int?> _afficherDialogueQuantite(BuildContext context) async {
    TextEditingController _quantiteController = TextEditingController();
    return showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Entrer la quantité'),
          content: TextField(
            controller: _quantiteController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Quantité'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Valider'),
              onPressed: () {
                int? quantite = int.tryParse(_quantiteController.text);
                Navigator.of(context).pop(quantite);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
 */
