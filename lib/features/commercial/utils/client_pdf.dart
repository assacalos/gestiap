/* import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestiap/core/services/auth_service.dart';
import 'package:gestiap/features/commercial/data/models/client_model.dart';
import 'package:gestiap/core/constants/app_constants.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart';
import 'package:gestiap/providers/auth_provider.dart';
import 'package:gestiap/features/commercial/services/clients/client_service.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle, ByteData;
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/proforma_model.dart'; // Assurez-vous que le chemin est correct
import 'dart:typed_data'; // Import pour Uint8List


class PdfService {
  static Future<void> exportClientsToPdf(List<Client> clients) async {
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
      build: (context) {
        return pw.Table.fromTextArray(
          headers: ['Nom', 'Adresse', 'Email', 'Contact'],
          data: clients.map((c) => [c.nom, c.adresse, c.email, c.telephone]).toList(),
        );
      },
    ));

    final file = File('clients_export.pdf');
    await file.writeAsBytes(await pdf.save());
    // Utilise `path_provider` pour gérer le chemin sur Android/iOS
  }
}
 */
