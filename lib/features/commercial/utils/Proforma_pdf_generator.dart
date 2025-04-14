import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle, ByteData;
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/proforma_model.dart'; // Assurez-vous que le chemin est correct
import 'dart:typed_data'; // Import pour Uint8List

Future<pw.Font> loadCustomFont() async {
  final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
  final Uint8List uint8List = fontData.buffer.asUint8List();
  return pw.Font.ttf(ByteData.view(uint8List.buffer));
}

Future<void> generateQuotePdf(QuoteModel quote) async {
  final pdf = pw.Document();
  final font = await loadCustomFont();

  final clientSnapshot =
      await FirebaseFirestore.instance
          .collection('clients')
          .doc(quote.clientId)
          .get();

  if (!clientSnapshot.exists) {
    print("Client non trouvé.");
    return;
  }

  final clientData = clientSnapshot.data()!;
  final clientName = clientData['entreprise'] ?? '';
  final clientAddress = clientData['adresse'] ?? '';
  final clientPhone = clientData['telephone'] ?? '';
  final clientEmail = clientData['email'] ?? '';

  pdf.addPage(
    pw.MultiPage(
      build:
          (context) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Proforma N° ${quote.id}',
                style: pw.TextStyle(fontSize: 22, font: font),
              ),
            ),
            pw.Text(
              'Date : ${DateFormat('dd/MM/yyyy').format(quote.createdAt.toLocal())}',
              style: pw.TextStyle(font: font),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'ALEB',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                font: font,
              ),
            ),
            pw.Text(
              'Adresse : 123 Rue de l\'Exemple, Paris, France',
              style: pw.TextStyle(font: font),
            ),
            pw.Text('email@aleb.com', style: pw.TextStyle(font: font)),
            pw.Text(
              'Téléphone : +33 1 23 45 67 89',
              style: pw.TextStyle(fontSize: 12, font: font),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Client : $clientName', style: pw.TextStyle(font: font)),
            pw.Text(
              'Adresse : $clientAddress',
              style: pw.TextStyle(font: font),
            ),
            pw.Text(
              'Téléphone : $clientPhone',
              style: pw.TextStyle(font: font),
            ),
            pw.Text('Email : $clientEmail', style: pw.TextStyle(font: font)),
            pw.Divider(),
            pw.Text(
              'Description du Proforma :',
              style: pw.TextStyle(font: font),
            ),
            pw.Text(quote.description, style: pw.TextStyle(font: font)),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers:
                  ['Description', 'Quantité', 'Prix Unitaire', 'Total']
                      .map(
                        (e) => pw.Text(
                          e,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            font: font,
                          ),
                        ),
                      )
                      .toList(),
              data:
                  quote.items.map((item) {
                    final total = item.quantity * item.unitPrice;
                    return [
                      pw.Text(
                        item.description,
                        style: pw.TextStyle(font: font),
                      ),
                      pw.Text(
                        item.quantity.toString(),
                        style: pw.TextStyle(font: font),
                      ),
                      pw.Text(
                        '${item.unitPrice.toStringAsFixed(2)} €',
                        style: pw.TextStyle(font: font),
                      ),
                      pw.Text(
                        '${total.toStringAsFixed(2)} €',
                        style: pw.TextStyle(font: font),
                      ),
                    ];
                  }).toList(),
              cellAlignment: pw.Alignment.centerLeft,
            ),
            pw.SizedBox(height: 20),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'Total HT : ${quote.totalHT.toStringAsFixed(2)} FCFA',
                    style: pw.TextStyle(font: font),
                  ),
                  pw.Text(
                    'Remise : ${quote.remise.toStringAsFixed(2)}%',
                    style: pw.TextStyle(font: font),
                  ),
                  pw.Text(
                    'Total TTC : ${quote.totalTTC.toStringAsFixed(2)} FCFA',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      font: font,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 30),
            pw.Text(
              'Cachet et signature de l\'entreprise',
              style: pw.TextStyle(fontStyle: pw.FontStyle.italic, font: font),
            ),
          ],
    ),
  );

  await Printing.layoutPdf(onLayout: (format) => pdf.save());
}
