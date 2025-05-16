import 'package:flutter/material.dart';
import 'package:gestiap/features/commercial/data/models/bordereaux_model.dart';
import 'package:intl/intl.dart';

class BordereauDetailsPage extends StatelessWidget {
  final BordereauModel bordereau;

  const BordereauDetailsPage({super.key, required this.bordereau});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Détails du Bordereau #${bordereau.id}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ID: ${bordereau.id}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text('Intitulé: ${bordereau.intitule}'),
            Text('Client: ${bordereau.clientEntreprise}'),
            Text('Email: ${bordereau.clientEmail}'),
            Text('Contact: ${bordereau.clientContact}'),
            Text('Adresse: ${bordereau.clientAdresse}'),
            Text(
              'Date de création: ${DateFormat('dd/MM/yyyy HH:mm').format(bordereau.createdAt.toLocal())}',
            ),
            Text(
              'Date de livraison: ${DateFormat('dd/MM/yyyy').format(bordereau.dateLivraison.toLocal())}',
            ),
            Text('État de livraison: ${bordereau.etatLivraison}'),
            Text('Délai de garantie: ${bordereau.delaiGarantie}'),
            Text('Devis ID: ${bordereau.devisId}'),
            Text('Statut: ${bordereau.status}'),
            const SizedBox(height: 15),
            const Text(
              'Articles:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (bordereau.articles.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bordereau.articles.length,
                itemBuilder: (context, index) {
                  final item = bordereau.articles[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${item.description} (x${item.quantity})'),
                        Text('Ref: ${item.ref}'),
                      ],
                    ),
                  );
                },
              )
            else
              const Text('Aucun article dans ce bordereau.'),
            // Vous n'avez pas de total HT/TTC directement dans le modèle.
            // Si vous avez besoin de les afficher, vous devrez probablement
            // les recalculer ici ou les ajouter à votre modèle.
            // Exemple de calcul (si les prix unitaires étaient disponibles dans ArticleLivraison) :
            /*
            const SizedBox(height: 15),
            Text(
              'Total HT: ${bordereau.articles.fold<double>(0, (sum, item) => sum + (item.unitPrice * item.quantity)).toStringAsFixed(2)}',
            ),
            Text(
              'Total TTC: ${bordereau.articles.fold<double>(0, (sum, item) => sum + (item.unitPrice * item.quantity) * (1 + tauxTVA)).toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            */
            // Ajoutez ici d'autres informations spécifiques au bordereau que vous souhaitez afficher
          ],
        ),
      ),
    );
  }
}
