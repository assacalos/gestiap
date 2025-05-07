import 'package:flutter/material.dart';
import 'package:gestiap/features/comptable/data/models/facture_model.dart';
import 'package:gestiap/features/comptable/providers/facture_provider.dart';
import 'package:provider/provider.dart';

class FactureStatusPage extends StatefulWidget {
  final InvoiceModel invoice;

  const FactureStatusPage({Key? key, required this.invoice}) : super(key: key);

  @override
  _FactureStatusPageState createState() => _FactureStatusPageState();
}

class _FactureStatusPageState extends State<FactureStatusPage> {
  final TextEditingController _commentaireRejetController =
      TextEditingController(); // Pour le commentaire de rejet

  @override
  void dispose() {
    _commentaireRejetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final factureProvider = Provider.of<InvoiceProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statut de la Facture'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Numéro de Facture: ${widget.invoice.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text('Statut actuel: ${widget.invoice.status}'),
                const SizedBox(height: 20),
                // Afficher les boutons d'action en fonction du statut actuel
                _buildStatusActions(factureProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusActions(InvoiceProvider factureProvider) {
    switch (widget.invoice.status) {
      case 'Brouillon':
        return ElevatedButton(
          onPressed: () async {
            await factureProvider.submitInvoice(widget.invoice.id);
            Navigator.of(context).pop(); // Retour à la page précédente
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Facture soumise pour validation.'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          child: const Text('Soumettre au patron'),
        );
      case 'Soumise':
        return Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                await factureProvider.validateInvoice(widget.invoice.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Facture validée.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Valider la facture'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _commentaireRejetController,
              decoration: const InputDecoration(
                labelText: 'Motif du rejet (obligatoire)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                if (_commentaireRejetController.text.trim().isNotEmpty) {
                  await factureProvider.rejectInvoice(
                    widget.invoice.id,
                    _commentaireRejetController.text.trim(),
                  );
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Facture rejetée.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez entrer un motif de rejet.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Rejeter la facture'),
            ),
          ],
        );
      case 'Validée':
      case 'Rejetée':
        return const Text(
          'Aucune action requise.',
        ); // Ou un message plus informatif
      default:
        return const Text('Statut inconnu.');
    }
  }
}
