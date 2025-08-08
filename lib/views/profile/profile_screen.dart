// lib/views/profile/profile_screen.dart

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:omeamobile/controllers/blocs/auth/auth_bloc.dart';
import 'package:omeamobile/controllers/blocs/auth/auth_event.dart';
import 'package:omeamobile/controllers/blocs/auth/auth_state.dart';
import 'package:omeamobile/controllers/blocs/profile/profile_bloc.dart';
import 'package:omeamobile/controllers/blocs/profile/profile_event.dart';
import 'package:omeamobile/controllers/blocs/profile/profile_state.dart';
import 'package:omeamobile/utils/snackbar_helper.dart';
import 'package:omeamobile/views/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onSynchronize;
  const ProfileScreen({super.key, this.onSynchronize});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  // Méthode helper pour capitaliser une chaîne
  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return "${text[0].toUpperCase()}${text.substring(1)}";
  }

  // Méthode helper pour formater le rôle
  String _formatRole(String role) {
    switch (role.toLowerCase()) {
      case 'client':
        return 'Client';
      case 'technician':
        return 'Technicien';
      default:
        return _capitalize(role);
    }
  }

  Future<void> _showImagePickerDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choisir une photo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Prendre une photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choisir depuis la galerie'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthAuthenticated &&
                      state.user.photoProfileUrl != null) {
                    return ListTile(
                      leading: const Icon(Icons.delete, color: Colors.red),
                      title: const Text('Supprimer la photo'),
                      onTap: () {
                        Navigator.pop(context);
                        _removeProfileImage();
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        // Convertir l'image en base64
        final Uint8List imageBytes = await pickedFile.readAsBytes();
        final String base64Image = base64Encode(imageBytes);

        // Dispatch l'événement pour mettre à jour la photo de profil
        context.read<ProfileBloc>().add(
          ProfileImageUpdateRequested(imageBase64: base64Image),
        );
      }
    } catch (e) {
      SnackBarHelper.showError(
        context: context,
        message: 'Erreur lors de la sélection de l\'image: ${e.toString()}',
      );
    }
  }

  Future<void> _removeProfileImage() async {
    context.read<ProfileBloc>().add(ProfileImageRemoveRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil'), centerTitle: false),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthUnauthenticated) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
                SnackBarHelper.showInfo(
                  context: context,
                  message: 'Vous avez été déconnecté avec succès',
                );
              }
            },
          ),
          BlocListener<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is ProfileImageUpdated) {
                SnackBarHelper.showSuccess(
                  context: context,
                  message: 'Photo de profil mise à jour avec succès',
                );
                // Déclencher une mise à jour du profil utilisateur dans AuthBloc
                context.read<AuthBloc>().add(AuthProfileUpdateRequested());
              } else if (state is ProfileImageRemoved) {
                SnackBarHelper.showSuccess(
                  context: context,
                  message: 'Photo de profil supprimée avec succès',
                );
                context.read<AuthBloc>().add(AuthProfileUpdateRequested());
              } else if (state is ProfileError) {
                SnackBarHelper.showError(
                  context: context,
                  message: state.message,
                );
              }
            },
          ),
        ],
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is! AuthAuthenticated) {
              return const Center(
                child: Text('Erreur: Utilisateur non connecté.'),
              );
            }

            final user = state.user;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  _buildProfileImage(context, user.photoProfileUrl),
                  const SizedBox(height: 16),
                  Text(
                    '${user.prenom} ${user.nom}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _formatRole(user.role),
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),
                  _buildProfileInfoSection(context, user),
                  const SizedBox(height: 24),
                  _buildSettingsSection(context),
                  const SizedBox(height: 24),
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
                                    context.read<AuthBloc>().add(
                                      AuthLogoutRequested(),
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
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileImage(BuildContext context, String? photoProfileUrl) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) {
        final bool isUpdating = profileState is ProfileImageUpdating;

        return Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  width: 3,
                ),
              ),
              child: ClipOval(
                child:
                    photoProfileUrl != null && photoProfileUrl.isNotEmpty
                        ? Image.network(
                          photoProfileUrl,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 120,
                              height: 120,
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 120,
                              height: 120,
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: Theme.of(context).primaryColor,
                              ),
                            );
                          },
                        )
                        : Container(
                          width: 120,
                          height: 120,
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
              ),
            ),
            if (isUpdating)
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: isUpdating ? null : _showImagePickerDialog,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileInfoSection(BuildContext context, user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations personnelles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.phone, 'Téléphone', user.telephone),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.location_on,
              'Localisation',
              '${user.ville}, ${user.pays}',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.work, 'Rôle', _formatRole(user.role)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
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
            Icons.edit_outlined,
            'Modifier le profil',
            () {
              // Navigation vers l'écran d'édition du profil
            },
          ),
          const Divider(height: 0),
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
            widget.onSynchronize ?? () {},
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
