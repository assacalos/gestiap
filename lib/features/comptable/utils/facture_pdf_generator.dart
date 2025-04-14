import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:gestiap/features/comptable/data/models/facture_model.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';

Future<void> generateInvoicePdf(InvoiceModel invoice) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'FACTURE',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Référence: ${invoice.reference ?? 'N/A'}'),
            pw.Text(
              'Date de création: ${DateFormat('dd/MM/yyyy').format(invoice.dateCreation)}',
            ),
            if (invoice.dateEcheance != null)
              pw.Text(
                'Date d\'échéance: ${DateFormat('dd/MM/yyyy').format(invoice.dateEcheance!)}',
              ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Client:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text('Nom: ${invoice.clientName}'),
            pw.SizedBox(height: 20),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FixedColumnWidth(80),
                1: const pw.FixedColumnWidth(200),
                2: const pw.FixedColumnWidth(100),
                3: const pw.FixedColumnWidth(100),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Text(
                      'Quantité',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Description',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Prix Unitaire HT',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Montant HT',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
                ...invoice.items.map((item) {
                  final montantHT = item.quantity * item.unitPrice;
                  return pw.TableRow(
                    children: [
                      pw.Text(item.quantity.toString()),
                      pw.Text(item.description),
                      pw.Text(item.unitPrice.toStringAsFixed(2)),
                      pw.Text(montantHT.toStringAsFixed(2)),
                    ],
                  );
                }).toList(),
                pw.TableRow(
                  children: [
                    pw.SizedBox(),
                    pw.SizedBox(),
                    pw.Text(
                      'Total HT',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      invoice.totalHT.toStringAsFixed(2),
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.SizedBox(),
                    pw.SizedBox(),
                    pw.Text(
                      'Total TTC',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      invoice.totalTTC.toStringAsFixed(2),
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
                if (invoice.montantPaye != null)
                  pw.TableRow(
                    children: [
                      pw.SizedBox(),
                      pw.SizedBox(),
                      pw.Text(
                        'Montant Payé',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        invoice.montantPaye!.toStringAsFixed(2),
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                if (invoice.montantPaye != null &&
                    invoice.totalTTC > invoice.montantPaye!)
                  pw.TableRow(
                    children: [
                      pw.SizedBox(),
                      pw.SizedBox(),
                      pw.Text(
                        'Reste à Payer',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        (invoice.totalTTC - invoice.montantPaye!)
                            .toStringAsFixed(2),
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
              ],
            ),
            pw.SizedBox(height: 30),
            pw.Text('Statut: ${invoice.status}'),
            pw.SizedBox(height: 30),
            pw.Text(
              'Merci pour votre confiance.',
              style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
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
