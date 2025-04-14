import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/features/commercial/data/models/bordereaux_model.dart';
import 'package:gestiap/features/commercial/views/providers/bordereaux_provider.dart';
import 'package:gestiap/features/commercial/views/pages/bordereaux_detail_page.dart';

class PendingBordereauxList extends StatelessWidget {
  const PendingBordereauxList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BordereauxProvider>(
      builder: (context, bordereauxProvider, child) {
        final pendingBordereaux =
            bordereauxProvider.bordereaux
                .where(
                  (b) => b.status == BordereauModel.statusPendingValidation,
                )
                .toList();

        if (bordereauxProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (pendingBordereaux.isEmpty) {
          return const Center(
            child: Text('Aucun bordereau en attente de validation.'),
          );
        }

        return ListView.builder(
          itemCount: pendingBordereaux.length,
          itemBuilder: (context, index) {
            final bordereau = pendingBordereaux[index];
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(
                  'Bordereau #${bordereau.id} - ${bordereau.clientName}',
                ),
                subtitle: Text('Soumis le: ${bordereau.createdAt.toLocal()}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () {
                        Provider.of<BordereauxProvider>(
                          context,
                          listen: false,
                        ).validateBordereau(bordereau.id);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        Provider.of<BordereauxProvider>(
                          context,
                          listen: false,
                        ).rejectBordereau(bordereau.id);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              BordereauDetailsPage(bordereau: bordereau),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
