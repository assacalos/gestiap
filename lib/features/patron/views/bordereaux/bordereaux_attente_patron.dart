import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/features/commercial/data/models/bordereaux_model.dart';
import 'package:gestiap/features/commercial/providers/bordereaux/bordereaux_provider.dart';

class PendingBordereauxList extends StatefulWidget {
  const PendingBordereauxList({super.key});

  @override
  State<PendingBordereauxList> createState() => _PendingBordereauxListState();
}

class _PendingBordereauxListState extends State<PendingBordereauxList> {
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
  Widget build(BuildContext context) {
    final provider = Provider.of<BordereauxProvider>(context);
    final pending =
        provider.bordereaux
            .where((b) => b.status == BordereauModel.statusPendingValidation)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bordereaux en Attente"),
        backgroundColor: Colors.amber,
      ),
      body:
          pending.isEmpty
              ? const Center(child: Text("Aucun bordereau en attente."))
              : ListView.builder(
                itemCount: pending.length,
                itemBuilder: (context, index) {
                  final b = pending[index];
                  return Card(
                    margin: const EdgeInsets.all(12),
                    child: ListTile(
                      title: Text("Bordereau #${b.id} - ${b.clientEntreprise}"),
                      subtitle: Text("Email: ${b.clientEmail}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                            onPressed: () => _validateBordereau(b),
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () => _showRejectDialog(b),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }

  void _validateBordereau(BordereauModel b) async {
    final provider = Provider.of<BordereauxProvider>(context, listen: false);
    await provider.validateBordereau(b.id, context);
  }

  void _showRejectDialog(BordereauModel b) {
    _rejectionReasonController.clear();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Rejeter Bordereau"),
            content: TextField(
              controller: _rejectionReasonController,
              decoration: const InputDecoration(labelText: "Motif du rejet"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Annuler"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final commentaire = _rejectionReasonController.text.trim();
                  if (commentaire.isEmpty) return;

                  final provider = Provider.of<BordereauxProvider>(
                    context,
                    listen: false,
                  );
                  await provider.rejectBordereau(b.id, commentaire, context);

                  Navigator.pop(context);
                },
                child: const Text("Rejeter"),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }
}
