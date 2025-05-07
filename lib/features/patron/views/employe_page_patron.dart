import 'package:flutter/material.dart';
import 'package:gestiap/features/rh/data/models/employes_model.dart';
import 'package:gestiap/features/rh/providers/employe_provider.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart'; //Pour les CustomBottomNavigationBar

class EmployesPage extends StatefulWidget {
  const EmployesPage({Key? key}) : super(key: key);

  @override
  _EmployesPageState createState() => _EmployesPageState();
}

class _EmployesPageState extends State<EmployesPage> {
  int _currentPageIndex = 0;
  // Pas besoin d'un ChangeNotifierProvider ici, il doit être au-dessus dans l'arbre des widgets
  @override
  void initState() {
    super.initState();
    // La logique d'initialisation du provider doit être dans le main.dart ou un parent
    final employesProvider = Provider.of<EmployeProvider>(
      context,
      listen: false,
    );
    employesProvider
        .getEmployes(); // Charger les employés au démarrage de la page.
  }

  @override
  Widget build(BuildContext context) {
    // Consolider l'accès au EmployesProvider
    final employesProvider = Provider.of<EmployeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Employés'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // Utilisation d'une Column pour organiser les éléments de la page
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Liste des Employés',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Affichage de la liste des employés
            Expanded(
              // Utilisation de Expanded pour que la ListView occupe l'espace restant
              child: _buildEmployeeList(employesProvider),
            ),
            const SizedBox(height: 20),
            //Bouton d'ajout d'employé
            ElevatedButton(
              onPressed: () {
                _showAddEmployeeDialog(context, employesProvider);
              },
              child: const Text('Ajouter un employé'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        onTabChange: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        initialIndex: _currentPageIndex,
      ), // Assurez-vous que CustomBottomNavigationBar est correctement défini
    );
  }

  // Méthode pour construire la liste des employés
  Widget _buildEmployeeList(EmployeProvider employesProvider) {
    if (employesProvider.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      ); // Afficher un loader pendant le chargement
    } else if (employesProvider.employes.isEmpty) {
      return const Center(
        child: Text('Aucun employé trouvé.'),
      ); // Message si la liste est vide.
    } else {
      return ListView.builder(
        itemCount: employesProvider.employes.length,
        itemBuilder: (context, index) {
          final EmployeModel employe = employesProvider.employes[index];
          return _buildEmployeeListItem(employe, employesProvider);
        },
      );
    }
  }

  // Méthode pour construire chaque élément de la liste
  Widget _buildEmployeeListItem(
    EmployeModel employe,
    EmployeProvider employesProvider,
  ) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${employe.nom} ${employe.prenom}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Email: ${employe.email}'),
                Text('Téléphone: ${employe.telephone}'),
                Text('Poste: ${employe.poste}'),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    _showEditEmployeeDialog(
                      context,
                      employesProvider.employes, // Passer la liste des employés
                      employe,
                      employesProvider,
                    ); // Passer la liste et l'employé à éditer
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeleteEmployeeDialog(
                      context,
                      employe.id,
                      employesProvider,
                    ); // Passer l'ID de l'employé à supprimer
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Méthode pour afficher la boîte de dialogue d'ajout d'employé
  void _showAddEmployeeDialog(
    BuildContext context,
    EmployeProvider employesProvider,
  ) {
    final _formKey = GlobalKey<FormState>();
    String nom = '';
    String prenom = '';
    String email = '';
    String telephone = '';
    String poste = '';
    String departement = ''; // Ajout d'un champ pour le département
    DateTime dateEmbauche =
        DateTime.now(); // Initialiser la date d'embauche à aujourd'hui

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter un employé'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                //Wrap en SingleChildScrollView pour eviter les problemes de clavier
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Nom'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un nom';
                      }
                      return null;
                    },
                    onSaved: (value) => nom = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Prénom'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un prénom';
                      }
                      return null;
                    },
                    onSaved: (value) => prenom = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un email';
                      }
                      // Vous pouvez ajouter une validation d'email plus robuste ici
                      return null;
                    },
                    onSaved: (value) => email = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Téléphone'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un numéro de téléphone';
                      }
                      return null;
                    },
                    onSaved: (value) => telephone = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Poste'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un poste';
                      }
                      return null;
                    },
                    onSaved: (value) => poste = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Département'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un département';
                      }
                      return null;
                    },
                    onSaved: (value) => departement = value!,
                  ),
                  // Champ pour la date d'embauche
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Date d\'embauche',
                    ),
                    readOnly: true,
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: dateEmbauche,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != dateEmbauche) {
                        setState(() {
                          dateEmbauche = picked;
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer une date d\'embauche';
                      }
                      return null;
                    },
                    onSaved: (value) => dateEmbauche = DateTime.parse(value!),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final newEmploye = EmployeModel(
                    id: DateTime.now().toString(), // Générer un ID unique
                    nom: nom,
                    prenom: prenom,
                    email: email,
                    telephone: telephone,
                    poste: poste,
                    departement: departement,
                    dateEmbauche: dateEmbauche,
                  );
                  employesProvider.addEmploye(
                    newEmploye,
                  ); // Utiliser la méthode du provider
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Employé ajouté avec succès!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  // Méthode pour afficher la boîte de dialogue de modification d'employé
  void _showEditEmployeeDialog(
    BuildContext context,
    List<EmployeModel> employees, // Passer la liste des employés
    EmployeModel employeAModifier,
    EmployeProvider employesProvider,
  ) {
    final _formKey = GlobalKey<FormState>();
    String nom = employeAModifier.nom;
    String prenom = employeAModifier.prenom;
    String email = employeAModifier.email;
    String telephone = employeAModifier.telephone;
    String poste = employeAModifier.poste;
    String departement =
        employeAModifier.departement; // Garder le même département
    DateTime dateEmbauche =
        employeAModifier.dateEmbauche; // Garder la même date d'embauche

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier un employé'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    initialValue: employeAModifier.nom,
                    decoration: const InputDecoration(labelText: 'Nom'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un nom';
                      }
                      return null;
                    },
                    onSaved: (value) => nom = value!,
                  ),
                  TextFormField(
                    initialValue: employeAModifier.prenom,
                    decoration: const InputDecoration(labelText: 'Prénom'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un prénom';
                      }
                      return null;
                    },
                    onSaved: (value) => prenom = value!,
                  ),
                  TextFormField(
                    initialValue: employeAModifier.email,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un email';
                      }
                      // Vous pouvez ajouter une validation d'email plus robuste ici
                      return null;
                    },
                    onSaved: (value) => email = value!,
                  ),
                  TextFormField(
                    initialValue: employeAModifier.telephone,
                    decoration: const InputDecoration(labelText: 'Téléphone'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un numéro de téléphone';
                      }
                      return null;
                    },
                    onSaved: (value) => telephone = value!,
                  ),
                  TextFormField(
                    initialValue: employeAModifier.poste,
                    decoration: const InputDecoration(labelText: 'Poste'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un poste';
                      }
                      return null;
                    },
                    onSaved: (value) => poste = value!,
                  ),
                  TextFormField(
                    initialValue: employeAModifier.departement,
                    decoration: const InputDecoration(labelText: 'Département'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un département';
                      }
                      return null;
                    },
                    onSaved: (value) => employeAModifier.departement = value!,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  // Mettre à jour l'employé
                  final updatedEmploye = EmployeModel(
                    id: employeAModifier.id, // Garder le même ID
                    nom: nom,
                    prenom: prenom,
                    email: email,
                    telephone: telephone,
                    poste: poste,
                    departement:
                        departement, //employeAModifier.departement, // Garder le même département
                    dateEmbauche:
                        employeAModifier
                            .dateEmbauche, // Garder la même date d'embauche
                  );
                  employesProvider.updateEmploye(
                    updatedEmploye,
                  ); // Utiliser la méthode update du provider

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Employé modifié avec succès!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  // Méthode pour afficher la boîte de dialogue de confirmation de suppression
  void _showDeleteEmployeeDialog(
    BuildContext context,
    String employeeId,
    EmployeProvider employesProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer un employé'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer cet employé ?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                employesProvider.deleteEmploye(
                  employeeId,
                ); // Utiliser la méthode delete du provider
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Employé supprimé avec succès!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
}
