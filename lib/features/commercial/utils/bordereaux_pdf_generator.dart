import 'dart:io';
import 'package:intl/intl.dart';
import 'package:gestiap/features/commercial/providers/bordereaux/bordereaux_provider.dart';
import 'package:gestiap/features/commercial/views/pages/bordereaux/bordereaux_form.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:gestiap/features/commercial/data/models/bordereaux_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:open_file/open_file.dart';

class BordereauPdfGenerator {
  static Future<List<int>> generatePdf(BordereauModel bordereau) async {
    final pdf = pw.Document();

    // Charger le logo
    final imageData = await rootBundle.load('assets/logoaleb.png');
    final imageBytes = imageData.buffer.asUint8List();
    final logoImage = pw.MemoryImage(imageBytes);

    // Charger la police Unicode
    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final roboto = pw.Font.ttf(fontData);

    //commercial@example.com
    //patron@example.com

    final dateFormatted = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(bordereau.createdAt);

    pdf.addPage(
      pw.MultiPage(
        build:
            (context) => [
              pw.Center(
                child: pw.Text(
                  'BORDEREAU DE LIVRAISON',
                  style: pw.TextStyle(
                    font: roboto,
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Date : $dateFormatted',
                    style: pw.TextStyle(font: roboto),
                  ),
                  pw.Image(logoImage, height: 60),
                ],
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'ID : ${bordereau.id}',
                    style: pw.TextStyle(font: roboto),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Client : ${bordereau.clientEntreprise}',
                        style: pw.TextStyle(font: roboto),
                      ),
                      pw.Text(
                        'Adresse : ${bordereau.clientAdresse}',
                        style: pw.TextStyle(font: roboto),
                      ),
                      pw.Text(
                        'Email : ${bordereau.clientEmail}',
                        style: pw.TextStyle(font: roboto),
                      ),
                      pw.Text(
                        'Contact : ${bordereau.clientContact}',
                        style: pw.TextStyle(font: roboto),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Center(
                child: pw.Text(
                  bordereau.intitule,
                  style: pw.TextStyle(
                    font: roboto,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Table.fromTextArray(
                headers: [
                  'Réf',
                  'Désignation',
                  'Quantité',
                  'État',
                ], // Ajout de la colonne 'État'
                data:
                    bordereau.articles.map((item) {
                      // Convertir l'état en une chaîne lisible
                      String etatLivraison = '';
                      switch (item.status) {
                        case BordereauModel.statusPendingValidation:
                          etatLivraison = 'En attente';
                          break;
                        case BordereauModel.statusValidated:
                          etatLivraison = 'Livré';
                          break;
                        case BordereauModel.statusRejected:
                          etatLivraison = 'Annulé';
                          break;
                        default:
                          etatLivraison = 'Inconnu';
                      }

                      return [
                        item.ref ?? '',
                        item.description,
                        item.quantity.toString(),
                        etatLivraison, // Utilisation de la chaîne convertie
                      ];
                    }).toList(),
                headerStyle: pw.TextStyle(
                  font: roboto,
                  fontWeight: pw.FontWeight.bold,
                ),
                cellStyle: pw.TextStyle(font: roboto),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'État de livraison global : ${bordereau.etatLivraison}',
                style: pw.TextStyle(font: roboto),
              ),
              pw.Text(
                'Délai de garantie : ${bordereau.delaiGarantie}',
                style: pw.TextStyle(font: roboto),
              ),
              pw.Text(
                'Date de livraison : ${DateFormat('dd/MM/yyyy').format(bordereau.dateLivraison)}',
                style: pw.TextStyle(font: roboto),
              ),
              pw.SizedBox(height: 32),
              pw.Align(
                alignment: pw.Alignment.bottomRight,
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Cachet de l\'entreprise',
                      style: pw.TextStyle(font: roboto),
                    ),
                    pw.SizedBox(height: 50),
                    pw.Container(
                      width: 100,
                      height: 50,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(width: 1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
      ),
    );

    final output = await getTemporaryDirectory();
    /*    final file = File("${output.path}/bordereau_${bordereau.id}.pdf");
    await file.writeAsBytes(await pdf.save()); */
    return await pdf.save();
  }
}
