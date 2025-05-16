import 'package:flutter/material.dart';
import 'package:gestiap/features/commercial/data/models/proforma_model.dart';
import 'package:gestiap/features/commercial/providers/proformas/proforma_provider.dart';
import 'package:gestiap/features/commercial/views/pages/proforma/proforma_detail_page.dart';
import 'package:provider/provider.dart';

class RejectedProformasList extends StatefulWidget {
  const RejectedProformasList({super.key});

  @override
  State<RejectedProformasList> createState() => _RejectedProformasListState();
}

class _RejectedProformasListState extends State<RejectedProformasList> {
  final TextEditingController _rejectionReasonController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<QuoteProvider>(context, listen: false);
      await provider.loadAllQuotes();
    });
  }

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quotesProvider = Provider.of<QuoteProvider>(context);
    final rejectedProformas =
        quotesProvider.quotes
            .where((q) => q.status == QuoteModel.statusRejected)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Devis Rejetés',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        elevation: 0,
      ),
      body:
          rejectedProformas.isEmpty
              ? const Center(child: Text("Aucun devis rejeté pour le moment."))
              : ListView.builder(
                itemCount: rejectedProformas.length,
                itemBuilder: (context, index) {
                  final devis = rejectedProformas[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ProformaDetailsPage(proforma: devis),
                          ),
                        );
                      },
                      title: Text(
                        'Devis #${devis.id} - ${devis.clientName}',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.red[800],
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            'Rejeté le: ${devis.createdAt.toLocal()}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text("Email: ${devis.clientId}"),
                          if (devis.commentaire != null &&
                              devis.commentaire!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                "Motif: ${devis.commentaire}",
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit_note, color: Colors.blue),
                        onPressed: () => _showRejectDialog(context, devis),
                      ),
                    ),
                  );
                },
              ),
    );
  }

  Future<void> _showRejectDialog(BuildContext context, QuoteModel devis) async {
    _rejectionReasonController.text = devis.commentaire ?? '';

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Modifier le motif de rejet"),
            content: TextField(
              controller: _rejectionReasonController,
              decoration: const InputDecoration(
                labelText: "Motif du rejet",
                hintText: "Entrez la raison du rejet...",
              ),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Annuler"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final motif = _rejectionReasonController.text.trim();
                  if (motif.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Le motif est obligatoire."),
                      ),
                    );
                    return;
                  }

                  await Provider.of<QuoteProvider>(
                    context,
                    listen: false,
                  ).rejectQuote(devis.id, motif);

                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Confirmer"),
              ),
            ],
          ),
    );
  }
}
