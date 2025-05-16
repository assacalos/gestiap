import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/features/commercial/data/models/bordereaux_model.dart';
import 'package:gestiap/features/commercial/providers/bordereaux/bordereaux_provider.dart';
import 'package:gestiap/features/commercial/views/pages/bordereaux/bordereaux_detail_page.dart';

class RejectedBordereauxList extends StatefulWidget {
  const RejectedBordereauxList({super.key});

  @override
  State<RejectedBordereauxList> createState() => _RejectedBordereauxListState();
}

class _RejectedBordereauxListState extends State<RejectedBordereauxList> {
  final TextEditingController _rejectionReasonController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<BordereauxProvider>(context, listen: false);
      await provider.loadAllBordereaux();
    });
  }

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bordereauxProvider = Provider.of<BordereauxProvider>(context);
    final rejectedBordereaux =
        bordereauxProvider.bordereaux
            .where((b) => b.status == BordereauModel.statusRejected)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bordereaux Rejetés',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        elevation: 0,
      ),
      body:
          rejectedBordereaux.isEmpty
              ? const Center(
                child: Text("Aucun bordereau rejeté pour le moment."),
              )
              : ListView.builder(
                itemCount: rejectedBordereaux.length,
                itemBuilder: (context, index) {
                  final bordereau = rejectedBordereaux[index];
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
                                (_) =>
                                    BordereauDetailsPage(bordereau: bordereau),
                          ),
                        );
                      },
                      title: Text(
                        'Bordereau #${bordereau.id} - ${bordereau.clientEntreprise}',
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
                            'Rejeté le: ${bordereau.createdAt.toLocal()}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (bordereau.commentaire != null &&
                              bordereau.commentaire!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                "Motif: ${bordereau.commentaire}",
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
                        onPressed: () => _showRejectDialog(context, bordereau),
                      ),
                    ),
                  );
                },
              ),
    );
  }

  Future<void> _showRejectDialog(
    BuildContext context,
    BordereauModel bordereau,
  ) async {
    _rejectionReasonController.text = bordereau.commentaire ?? '';

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
                  final comment = _rejectionReasonController.text.trim();
                  if (comment.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Le motif est obligatoire."),
                      ),
                    );
                    return;
                  }
                  await Provider.of<BordereauxProvider>(
                    context,
                    listen: false,
                  ).rejectBordereau(bordereau.id, comment, context);
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
