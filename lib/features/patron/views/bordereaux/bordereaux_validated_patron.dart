import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart'; // Assurez-vous que ce chemin est correct
import 'package:gestiap/features/commercial/data/models/bordereaux_model.dart'; // Assurez-vous que ce chemin est correct
import 'package:gestiap/features/commercial/providers/bordereaux/bordereaux_provider.dart';
import 'package:gestiap/features/commercial/views/pages/bordereaux/bordereaux_detail_page.dart';
import 'package:gestiap/features/commercial/views/pages/bordereaux/liste_bordereaux_page.dart'; // Assurez-vous que ce chemin est correct
import 'package:gestiap/features/patron/views/bordereaux/bordereaux_attente_patron.dart'; // Assurez-vous que ce chemin est correct
import 'package:google_fonts/google_fonts.dart';

class ValidatedBordereauxList extends StatefulWidget {
  const ValidatedBordereauxList({super.key});

  @override
  _ValidatedBordereauxListState createState() =>
      _ValidatedBordereauxListState();
}

class _ValidatedBordereauxListState extends State<ValidatedBordereauxList> {
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Make the callback async
      final bordereauxProvider = Provider.of<BordereauxProvider>(
        context,
        listen: false,
      );
      await bordereauxProvider
          .loadAllBordereaux(); // Await the loading of clients.  CRUCIAL
      // Print the clients to the console
      print("Loaded bordereaux in Valide: ${bordereauxProvider.bordereaux}");
    });
  }

  @override
  Widget build(BuildContext context) {
    final bordereauxProvider = Provider.of<BordereauxProvider>(context);
    final validatedBordereaux =
        bordereauxProvider.bordereaux
            .where((b) => b.status == BordereauModel.statusValidated)
            .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bordereaux Validés',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Consumer<BordereauxProvider>(
        builder: (context, bordereauxProvider, child) {
          final validatedBordereaux =
              bordereauxProvider.bordereaux
                  .where((b) => b.status == BordereauModel.statusValidated)
                  .toList();

          if (bordereauxProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }

          if (validatedBordereaux.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Aucun bordereau validé.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: validatedBordereaux.length,
            itemBuilder: (context, index) {
              final bordereau = validatedBordereaux[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bordereau #${bordereau.id} - ${bordereau.clientEntreprise}',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.green[800],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Validé le: ${bordereau.createdAt.toLocal()}',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
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
}
