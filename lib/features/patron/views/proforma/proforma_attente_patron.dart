import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/features/commercial/data/models/proforma_model.dart';
import 'package:gestiap/features/commercial/providers/proformas/proforma_provider.dart';
import 'package:gestiap/features/commercial/views/pages/proforma/proforma_detail_page.dart';
import 'package:google_fonts/google_fonts.dart';

class PendingProformaList extends StatelessWidget {
  const PendingProformaList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Proformas en Attente',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ), // Applique la police Poppins
        ),
        centerTitle: true,
        backgroundColor: Colors.blue, // Consistent app bar color
        elevation: 0,
      ),
      body: Consumer<QuoteProvider>(
        builder: (context, proformaProvider, child) {
          final pendingProformas =
              proformaProvider.quotes
                  .where((q) => q.status == QuoteModel.statusPendingValidation)
                  .toList();

          if (proformaProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ), // Consistent progress indicator color
            );
          }

          if (pendingProformas.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Aucune proforma en attente de validation.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Roboto', // Applique la police Roboto
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: pendingProformas.length,
            itemBuilder: (context, index) {
              final proforma = pendingProformas[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ), // Increased horizontal margin
                elevation: 6, // Slightly increased elevation
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    12,
                  ), // Rounded corners for cards
                ),
                child: InkWell(
                  // Use InkWell for ripple effect on tap
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                ProformaDetailsPage(proforma: proforma),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ), // Padding inside InkWell
                    child: Row(
                      // Use a Row for better layout
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Proforma # ${proforma.id} - ${proforma.clientName}',
                                style: TextStyle(
                                  fontFamily: 'Roboto', // Apply Roboto
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue[800], // Use a darker shade
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Soumis le: ${proforma.createdAt.toLocal()}',
                                style: TextStyle(
                                  fontFamily: 'Roboto', // Apply Roboto
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          // Moved action buttons to a separate row
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              onPressed: () {
                                Provider.of<QuoteProvider>(
                                  context,
                                  listen: false,
                                ).validateQuote(proforma.id);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) =>
                                          _buildRejectDialog(context, proforma),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Extract the dialog building to a separate method
  AlertDialog _buildRejectDialog(BuildContext context, QuoteModel proforma) {
    final rejectionReasonController = TextEditingController(); // Add controller

    return AlertDialog(
      title: const Text(
        'Reject Proforma',
        style: TextStyle(fontFamily: 'Poppins'),
      ),
      content: TextField(
        controller: rejectionReasonController, // Use the controller here
        decoration: const InputDecoration(
          labelText: 'Rejection Reason',
          labelStyle: TextStyle(fontFamily: 'Roboto'),
        ),
        style: const TextStyle(fontFamily: 'Roboto'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(fontFamily: 'Roboto')),
        ),
        TextButton(
          onPressed: () {
            final reason = rejectionReasonController.text.trim();
            if (reason.isNotEmpty) {
              Provider.of<QuoteProvider>(
                context,
                listen: false,
              ).rejectQuote(proforma.id, reason);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Reject', style: TextStyle(fontFamily: 'Roboto')),
        ),
      ],
    );
  }
}
