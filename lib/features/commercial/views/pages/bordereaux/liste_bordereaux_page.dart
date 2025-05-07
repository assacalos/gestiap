import 'package:flutter/material.dart';
import 'package:gestiap/features/commercial/data/models/bordereaux_model.dart';
import 'package:gestiap/features/commercial/providers/bordereaux/bordereaux_provider.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart';
import 'package:gestiap/features/commercial/utils/bordereaux_pdf_generator.dart';
import 'package:gestiap/features/commercial/views/pages/bordereaux/bordereaux_detail_page.dart';
import 'package:gestiap/features/commercial/views/pages/bordereaux/bordereaux_form.dart';
import 'package:open_file/open_file.dart';

class ListeBordereauxPage extends StatefulWidget {
  final String status;
  const ListeBordereauxPage({super.key, required this.status});
  @override
  _ListeBordereauxPageState createState() => _ListeBordereauxPageState();
}

class _ListeBordereauxPageState extends State<ListeBordereauxPage> {
  int _currentPageIndex = 0;
  String get status => widget.status;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BordereauxProvider>(
        context,
        listen: false,
      ).loadBordereaux(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bordereaux ${status.capitalize()}')),
      body: Consumer<BordereauxProvider>(
        builder: (context, bordereauProvider, child) {
          final List<BordereauModel> filteredBordereaux =
              bordereauProvider.bordereaux
                  .where(
                    (bordereau) =>
                        bordereau.status.toLowerCase() == status.toLowerCase(),
                  )
                  .toList();

          if (bordereauProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (filteredBordereaux.isEmpty) {
            return Center(
              child: Text(
                'Aucun bordereau avec le statut "${status.capitalize()}".',
              ),
            );
          } else {
            return ListView.builder(
              itemCount: filteredBordereaux.length,
              itemBuilder: (context, index) {
                final BordereauModel bordereau = filteredBordereaux[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      'Bordereau #${bordereau.id.substring(0, 8)}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Client: ${bordereau.clientName}'),
                        Text(
                          'Date: ${bordereau.createdAt.toLocal().formatDate()}',
                        ),
                        Text('Statut: ${bordereau.status.capitalize()}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.visibility,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => BordereauDetailsPage(
                                      bordereau: bordereau,
                                    ),
                              ),
                            );
                          },
                        ),
                        if (bordereau.status.toLowerCase() !=
                            BordereauModel.statusValidated.toLowerCase())
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => BordereauFormPage(
                                        bordereauToEdit: bordereau,
                                      ),
                                ),
                              );
                            },
                          ),
                        if (bordereau.status.toLowerCase() !=
                            BordereauModel.statusValidated.toLowerCase())
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _showDeleteConfirmationDialog(
                                context,
                                bordereau,
                                Provider.of<BordereauxProvider>(
                                  context,
                                  listen: false,
                                ),
                              );
                            },
                          ),
                        IconButton(
                          icon: const Icon(
                            Icons.picture_as_pdf,
                            color: Colors.green,
                          ),
                          onPressed: () async {
                            try {
                              final pdfFile =
                                  await BordereauPdfGenerator.generatePdf(
                                    bordereau,
                                  );
                              OpenFile.open(pdfFile.path);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error generating PDF: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  BordereauDetailsPage(bordereau: bordereau),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        onTabChange: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        initialIndex: _currentPageIndex,
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    BordereauModel bordereau,
    BordereauxProvider bordereauProvider,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Êtes-vous sûr de vouloir supprimer le bordereau #${bordereau.id.substring(0, 8)} ?',
                ),
                const Text('Cette action est irréversible.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Supprimer'),
              onPressed: () {
                bordereauProvider.deleteBordereau(bordereau.id, context);
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bordereau supprimé.')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

extension DateFormatter on DateTime {
  String formatDate() {
    return "${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/${year}";
  }
}
