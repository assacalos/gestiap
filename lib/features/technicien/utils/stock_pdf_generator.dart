import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:gestiap/features/technicien/data/models/stock_model.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart'; // Importez pour PdfPageFormat

Future<void> generateStockItemPdf(StockItem item) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Détails de l\'article de stock',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Code Produit: ${item.codeProduit}'),
            pw.Text('Description: ${item.description}'),
            pw.Text('Prix Vente Unitaire: ${item.prixVenteUnitaire}'),
            pw.Text('Quantité Entrée: ${item.quantiteEntree}'),
            pw.Text('Prix Achat Unitaire: ${item.prixAchatUnitaire}'),
            pw.Text(
              'Date d\'ajout: ${DateFormat('dd/MM/yyyy HH:mm').format(item.dateAjout.toLocal())}',
            ),
            // Vous pouvez ajouter d'autres détails ici
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}
