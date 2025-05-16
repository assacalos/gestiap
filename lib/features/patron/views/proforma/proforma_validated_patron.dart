import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/features/commercial/data/models/proforma_model.dart';
import 'package:gestiap/features/commercial/providers/proformas/proforma_provider.dart';
import 'package:gestiap/features/commercial/views/pages/proforma/proforma_detail_page.dart';
import 'package:google_fonts/google_fonts.dart';

class ProformaValideePatron extends StatefulWidget {
  const ProformaValideePatron({super.key});

  @override
  _ProformaValideePatronState createState() => _ProformaValideePatronState();
}

class _ProformaValideePatronState extends State<ProformaValideePatron> {
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Make the callback async
      final quoteProvider = Provider.of<QuoteProvider>(context, listen: false);
      await quoteProvider
          .loadAllQuotes(); // Await the loading of clients.  CRUCIAL
      // Print the clients to the console
      print("Loaded proforma in Valide: ${quoteProvider.quotes}");
    });
  }

  @override
  Widget build(BuildContext context) {
    final proformaProvider = Provider.of<QuoteProvider>(context);
    final validatedProformas =
        proformaProvider.quotes
            .where((q) => q.status == QuoteModel.statusValidated)
            .toList();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading:
            true, // Pour ne pas afficher de bouton de retour par défaut dans un TabBarView
        title: Text(
          'Proformas Validées',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body:
          validatedProformas
                  .isEmpty // Utilise validatedClients ici
              ? const Center(
                child: Text("Aucun proforma validé pour le moment."),
              )
              : ListView.builder(
                itemCount:
                    validatedProformas
                        .length, // Utilise validatedClients.length ici
                itemBuilder: (context, index) {
                  final quotes =
                      validatedProformas[index]; // Utilise validatedClients[index] ici
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    ProformaDetailsPage(proforma: quotes),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Proforma # ${quotes.id}',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.green[800],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Client: ${quotes.clientName}',
                              style: GoogleFonts.roboto(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            /* Text(
                          'Validée le: ${proforma.validationDate?.toLocal().toString().split(' ')[0] ?? 'N/A'}',
                          style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey[600]),
                        ), */
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
