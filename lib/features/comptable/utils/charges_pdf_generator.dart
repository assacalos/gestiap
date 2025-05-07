import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:gestiap/features/comptable/data/models/charge_model.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';

Future<void> generateDepensePdf(ChargesModel depense) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Détails de la Dépense',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Description: ${depense.description}'),
            pw.Text('Date: ${DateFormat('dd/MM/yyyy').format(depense.date)}'),
            pw.Text('Montant: ${depense.montant.toStringAsFixed(2)}'),
            pw.Text('Catégorie: ${depense.categorie}'),
            if (depense.fournisseurNom != null)
              pw.Text('Fournisseur: ${depense.fournisseurNom}'),
            if (depense.reference != null)
              pw.Text('Référence: ${depense.reference}'),
            if (depense.methodePaiement != null)
              pw.Text('Méthode de Paiement: ${depense.methodePaiement}'),
            if (depense.pieceJustificativeUrl != null)
              pw.Text('Pièce Justificative: ${depense.pieceJustificativeUrl}'),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}
