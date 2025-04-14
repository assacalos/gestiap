import 'package:gestiap/features/comptable/data/models/fournisseurs_model.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

Future<void> generateFournisseurPdf(FournisseurModel fournisseur) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Informations du Fournisseur',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Nom: ${fournisseur.nom}'),
            if (fournisseur.entreprise != null)
              pw.Text('Entreprise: ${fournisseur.entreprise}'),
            if (fournisseur.adresse != null)
              pw.Text('Adresse: ${fournisseur.adresse}'),
            if (fournisseur.contact != null)
              pw.Text('Contact: ${fournisseur.contact}'),
            if (fournisseur.email != null)
              pw.Text('Email: ${fournisseur.email}'),
            if (fournisseur.informationsBancaires != null)
              pw.Text(
                'Informations Bancaires: ${fournisseur.informationsBancaires}',
              ),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}
