// lib/views/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omeamobile/controllers/blocs/auth/auth_bloc.dart';
import 'package:omeamobile/controllers/blocs/auth/auth_event.dart';
import 'package:omeamobile/controllers/blocs/auth/auth_state.dart';
import 'package:omeamobile/utils/snackbar_helper.dart';
import 'package:omeamobile/views/auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil'), centerTitle: false),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
              (Route<dynamic> route) => false,
            );
            SnackBarHelper.showInfo(
              context: context,
              message: 'Vous avez été déconnecté avec succès',
            );
          }
        },
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Center(child: Text('Erreur: Utilisateur non connecté.'));
          }

          final user = state.user;

          return SingleChildScrollView(
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
                  user.role.capitalize(),
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 32),
                _buildSettingsSection(context),
                const SizedBox(height: 32),
                _buildSupportSection(context),
                const SizedBox(height: 40),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            authState is AuthLoading
                                ? null
                                : () {
                                  context.read<AuthBloc>().add(AuthLogoutRequested());
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
                    );
                  },
                ),
              ],
            ),
          );
        },
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

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}