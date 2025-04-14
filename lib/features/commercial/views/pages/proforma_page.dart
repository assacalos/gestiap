/* import 'package:flutter/material.dart';
import 'package:gestiap/features/commercial/utils/quote_pdf_generator.dart';
import 'package:gestiap/features/commercial/views/providers_ou_blocs/devis_bloc.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:gestiap/core/widgets/widgets_widgets.dart';
import 'package:gestiap/core/constants/app_constants.dart';
import 'package:gestiap/features/commercial/data/models/client_model.dart';
import 'package:gestiap/features/commercial/views/pages/devis_page.dart';
import 'package:gestiap/features/commercial/views/pages/devis_form_page.dart';

class QuotesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestion des devis')),
      body: Consumer<QuoteProvider>(
        builder: (context, provider, child) {
          print("Nombre de devis: ${provider.quotes.length}");
          if (provider.quotes.isEmpty) {
            return Center(child: Text('Aucun devis disponible'));
          }
          return ListView.builder(
            itemCount: provider.quotes.length,
            itemBuilder: (context, index) {
              final quote = provider.quotes[index];
              return Card(
                child: ListTile(
                  title: Text(quote.clientName),
                  subtitle: Row(
                    children: [
                      Text('${quote.amount}€'),
                      SizedBox(width: 10),
                      Chip(
                        label: Text(quote.status),
                        backgroundColor:
                            quote.status == "Validé"
                                ? Colors.green[100]
                                : Colors.orange[100],
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.picture_as_pdf, color: Colors.blue),
                        onPressed: () {
                          generateQuotePdf(widget.devisToEdit!);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      DevisFormPage(devisToEdit: quote),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: Text("Confirmation"),
                                  content: Text("Supprimer ce devis ?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text("Annuler"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        provider.deleteQuote(quote.id);
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        "Supprimer",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DevisFormPage()),
          );
        },
      ),
    );
  }
}
 */
