import 'package:flutter/material.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart';
import 'package:gestiap/features/commercial/data/models/client_model.dart';
import 'package:gestiap/features/commercial/data/models/proforma_model.dart';
import 'package:gestiap/features/commercial/providers/clients/clients_provider.dart';
import 'package:gestiap/features/commercial/views/pages/clients/client_modifier_form.dart';
import 'package:gestiap/features/commercial/views/pages/clients/clients_page.dart';
import 'package:gestiap/features/commercial/views/pages/clients/liste_clients_page.dart';
import 'package:gestiap/features/commercial/views/pages/proforma/liste_proforma_page.dart';
import 'package:gestiap/features/commercial/views/pages/proforma/proforma_form_page.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/features/commercial/providers/proformas/proforma_provider.dart';
import 'package:gestiap/providers/auth_provider.dart'; // Assurez-vous que ce chemin est correct
import 'package:google_fonts/google_fonts.dart'; // Importez le package google_fonts

/* class ClientStatusClients extends StatefulWidget {
  const ClientStatusClients({super.key});
  @override
  _ClientStatusClientsState createState() => _ClientStatusClientsState();
}

class _ClientStatusClientsState extends State<ClientStatusClients> {
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Charger les clients au démarrage de la page.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AppAuthProvider>(
        context,
        listen: false,
      ); // Récupérez l'AuthProvider
      if (authProvider.user != null) {
        // Vérifiez si l'utilisateur est connecté
        Provider.of<ClientProvider>(
          context,
          listen: false,
        ).loadClients(); // Charger les clients
      } else {
        // Gérez le cas où l'utilisateur n'est pas connecté
        // Affichez un message à l'utilisateur, redirigez-le vers la page de connexion, etc.
        print(
          "Utilisateur non connecté au démarrage de la page ClientStatusClients",
        ); // Pour débogage
        // Vous pouvez afficher un SnackBar ou naviguer vers la page de connexion ici.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez vous connecter pour accéder à cette page.'),
            duration: Duration(seconds: 5),
          ),
        );
        // Exemple de navigation vers la page de connexion (assurez-vous d'ajuster cela à votre application)
        // Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ClientProvider>(
      builder: (context, clientProvider, child) {
        if (clientProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (clientProvider.errorMessage != null) {
          return Scaffold(
            body: Center(child: Text("Error: ${clientProvider.errorMessage}")),
            // Vous pouvez ajouter un bouton pour réessayer de charger les données.
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Gestion des Clients',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.blue,
            titleTextStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Tableau de Bord Clients',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: Colors.blue[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                _buildDashboardButton(
                  context: context,
                  label: 'Clients Validés',
                  onPressed: () {
                    _navigateToClientList(
                      context,
                      'Validés', // Utilisez une constante ou un String pour le statut
                    );
                  },
                  icon: Icons.check_circle_outline,
                  backgroundColor: Colors.green[100],
                  textColor: Colors.green[800],
                ),
                const SizedBox(height: 20),
                _buildDashboardButton(
                  context: context,
                  label: 'Clients Soumis',
                  onPressed: () {
                    _navigateToClientList(context, 'Soumis');
                  },
                  icon: Icons.pending_actions,
                  backgroundColor: Colors.amber[100],
                  textColor: Colors.amber[800],
                ),
                const SizedBox(height: 20),
                _buildDashboardButton(
                  context: context,
                  label: 'Clients Rejetés',
                  onPressed: () {
                    _navigateToClientList(context, 'Rejeté');
                  },
                  icon: Icons.cancel_outlined,
                  backgroundColor: Colors.red[100],
                  textColor: Colors.red[800],
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
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ClientForm()),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildDashboardButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: backgroundColor ?? Colors.blue,
        foregroundColor: textColor ?? Colors.white,
      ),
      icon: icon != null ? Icon(icon, size: 28) : const SizedBox.shrink(),
      label: Text(label, style: const TextStyle(fontFamily: 'Roboto')),
    );
  }

  void _navigateToClientList(BuildContext context, String status) async {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);

    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez vous connecter pour accéder à la liste des clients.',
          ),
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    final clientProvider = Provider.of<ClientProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await clientProvider.refreshClientsByStatus(status);

    Navigator.of(context).pop(); // Fermer le loading

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ClientsPage(
              key: UniqueKey(),
              status: status,
              clients: clientProvider.clients,
            ),
      ),
    );
  }
} */

class ClientDashboardPage extends StatefulWidget {
  const ClientDashboardPage({super.key});
  @override
  _ClientDashboardPageState createState() => _ClientDashboardPageState();
}

class _ClientDashboardPageState extends State<ClientDashboardPage> {
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Charger les clients au démarrage de la page.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AppAuthProvider>(
        context,
        listen: false,
      ); // Récupérez l'AuthProvider
      final clientProvider = Provider.of<ClientProvider>(
        context,
        listen: false,
      );
      if (authProvider.user != null) {
        // Vérifiez si l'utilisateur est connecté
        Provider.of<ClientProvider>(
          context,
          listen: false,
        ).loadClients(); // Charger les clients
      } else {
        // Gérez le cas où l'utilisateur n'est pas connecté
        // Affichez un message à l'utilisateur, redirigez-le vers la page de connexion, etc.
        print(
          "Utilisateur non connecté au démarrage de la page ClientDashboardPage",
        ); // Pour débogage
        // Vous pouvez afficher un SnackBar ou naviguer vers la page de connexion ici.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez vous connecter pour accéder à cette page.'),
            duration: Duration(seconds: 5),
          ),
        );
        // Exemple de navigation vers la page de connexion (assurez-vous d'ajuster cela à votre application)
        // Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ClientProvider>(
      builder: (context, clientProvider, child) {
        if (clientProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (clientProvider.errorMessage != null) {
          return Scaffold(
            body: Center(child: Text("Error: ${clientProvider.errorMessage}")),
            // Vous pouvez ajouter un bouton pour réessayer de charger les données.
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Gestion des Clients',
              style: TextStyle(fontWeight: FontWeight.w600),
            ), // Titre plus marqué
            centerTitle: true, // Centre le titre
            elevation: 0, // Supprime l'ombre par défaut de l'AppBar
            backgroundColor: Colors.blue, // Ajoute une couleur d'arrière-plan
            titleTextStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white, // Couleur du texte du titre
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0), // Augmente le padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Tableau de Bord Clients', // Titre plus descriptif
                  style: TextStyle(
                    fontSize: 24, // Augmente la taille de la police
                    fontWeight: FontWeight.bold, // Met en gras
                    fontFamily: 'Poppins',
                    color: Colors.blue[800], // Couleur personnalisée
                  ),
                  textAlign: TextAlign.center, // Centre le titre
                ),
                const SizedBox(height: 30), // Augmente l'espacement
                _buildDashboardButton(
                  context: context,
                  label: 'Clients Validés',
                  onPressed: () {
                    _navigateToClientList(
                      context,
                      Client.statusValidated,
                      clientProvider,
                    );
                  },
                  icon: Icons.check_circle_outline, // Ajoute une icône
                  backgroundColor: Colors.green[100],
                  textColor: Colors.green[800],
                ),
                const SizedBox(height: 20), // Augmente l'espacement
                _buildDashboardButton(
                  context: context,
                  label: 'Clients Soumis',
                  onPressed: () {
                    _navigateToClientList(
                      context,
                      Client.statusPendingValidation,
                      clientProvider,
                    );
                  },
                  icon: Icons.pending_actions, // Ajoute une icône
                  backgroundColor: Colors.amber[100],
                  textColor: Colors.amber[800],
                ),
                const SizedBox(height: 20), // Augmente l'espacement
                _buildDashboardButton(
                  context: context,
                  label: 'Clients Rejetés',
                  onPressed: () {
                    _navigateToClientList(
                      context,
                      Client.statusRejected,
                      clientProvider,
                    );
                  },
                  icon: Icons.cancel_outlined, // Ajoute une icône
                  backgroundColor: Colors.red[100],
                  textColor: Colors.red[800],
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
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              // Naviguer vers le formulaire d'ajout de client
              // Assurez-vous que AddClientScreen est correctement défini
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ClientFormPage()),
              ).then((value) {
                // Recharger la liste des clients après l'ajout
                if (value == true) {
                  // Rafraîchir la liste seulement si un nouveau client a été ajouté
                  clientProvider.loadClients();
                }
              });
            },
            tooltip: 'Ajouter un client', // Tooltip pour plus d'accessibilité
          ),
        );
      },
    );
  }

  Widget _buildDashboardButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
    IconData? icon, // Ajoute un paramètre pour l'icône
    Color? backgroundColor, // Ajoute un paramètre pour la couleur de fond
    Color? textColor,
  }) {
    return ElevatedButton.icon(
      // Utilise ElevatedButton.icon
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18), // Ajuste le padding
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ), // Augmente la taille et l'épaisseur de la police
        elevation: 8, // Ajoute de l'ombre
        shape: RoundedRectangleBorder(
          // Arrondit les bords
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor:
            backgroundColor ??
            Colors
                .blue, // Utilise la couleur de fond par défaut si non spécifiée
        foregroundColor:
            textColor ?? Colors.white, // Couleur du texte et de l'icône
      ),
      icon:
          icon != null
              ? Icon(icon, size: 28)
              : const SizedBox.shrink(), // Ajoute l'icône si elle est fournie

      label: Text(
        label,
        style: const TextStyle(fontFamily: 'Roboto'),
      ), // Le texte du bouton
    );
  }

  void _navigateToClientList(
    BuildContext context,
    String status,
    ClientProvider clientProvider,
  ) {
    final authProvider = Provider.of<AppAuthProvider>(
      context,
      listen: false,
    ); // Get AuthProvider

    if (authProvider.user != null) {
      // Check if user is logged in
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ListeClientPage(
                key: UniqueKey(),
                status: status,
                clients:
                    clientProvider.clients
                        .where((client) => client.status == status)
                        .toList(),
              ),
        ),
      );
    } else {
      // Handle the case where the user is not logged in
      print(
        "Utilisateur non connecté avant de naviguer vers la liste Proforma",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez vous connecter pour accéder à la liste des proforma.',
          ),
          duration: Duration(seconds: 5),
        ),
      );
      //  Navigator.of(context).pushReplacementNamed('/login'); // Navigate to login
    }
  }
}
