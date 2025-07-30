// lib/views/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:omeamobile/controllers/auth_controller.dart';
import 'package:omeamobile/views/auth/login_screen.dart'; // Pour la redirection après déconnexion

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final user = authController.currentUser;

    if (user == null) {
      // Gérer le cas où l'utilisateur n'est pas connecté
      return const Center(child: Text('Erreur: Utilisateur non connecté.'));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profil'), centerTitle: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 60,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(
                Icons.person,
                size: 60,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.nom,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              user.role
                  .toString()
                  .split('.')
                  .last
                  .capitalize(), // Ex: "Technicien"
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 32),
            _buildSettingsSection(context),
            const SizedBox(height: 32),
            _buildSupportSection(context),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    authController.isLoading
                        ? null
                        : () async {
                          await authController.logout();
                          // Rediriger vers l'écran de connexion après déconnexion
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Déconnexion réussie.'),
                            ),
                          );
                        },
                icon: const Icon(Icons.logout),
                label: const Text('Déconnexion'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          _buildProfileListItem(
            context,
            Icons.notifications_none,
            'Notifications',
            () {
              // Action pour Notifications
            },
          ),
          const Divider(height: 0),
          _buildProfileListItem(
            context,
            Icons.settings_outlined,
            'Préférences',
            () {
              // Action pour Préférences
            },
          ),
          const Divider(height: 0),
          _buildProfileListItem(
            context,
            Icons.sync_outlined,
            'Synchronisation',
            () {
              // Action pour Synchronisation
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          _buildProfileListItem(context, Icons.help_outline, 'Aide', () {
            // Action pour Aide
          }),
          const Divider(height: 0),
          _buildProfileListItem(
            context,
            Icons.error_outline,
            'Signaler un problème',
            () {
              // Action pour Signaler un problème
            },
          ),
          const Divider(height: 0),
          _buildProfileListItem(context, Icons.info_outline, 'À propos', () {
            // Action pour À propos
          }),
        ],
      ),
    );
  }

  Widget _buildProfileListItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}

// Extension pour capitaliser les strings, utile pour l'affichage des rôles
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
