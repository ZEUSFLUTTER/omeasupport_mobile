// lib/views/auth/register_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:omeamobile/controllers/auth_controller.dart';
import 'package:omeamobile/views/auth/login_screen.dart'; // Import LoginScreen
import 'package:omeamobile/utils/app_colors.dart';
// Assuming User and UserRole are defined here

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _paysController = TextEditingController();
  final TextEditingController _villeController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  UserRole _selectedRole = UserRole.technician; // Default to Technician

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _telephoneController.dispose();
    _paysController.dispose();
    _villeController.dispose();
    super.dispose();
  }

  void _performRegistration() async {
    if (_formKey.currentState!.validate()) {
      final authController = Provider.of<AuthController>(
        context,
        listen: false,
      );

      final success = await authController.register(
        _nomController.text.trim(),
        _prenomController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _confirmPasswordController.text.trim(),
        _telephoneController.text.trim(),
        _paysController.text.trim(),
        _villeController.text.trim(),
        _selectedRole,
      );

      if (!mounted) {
        return;
      }

      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscription réussie ! Veuillez vous connecter.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authController.errorMessage ?? 'Erreur d\'inscription',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: const Icon(
                    Icons.app_registration,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Créer un Compte OmeaSupport',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  'Rejoignez notre plateforme de support technique',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Section de sélection du rôle (Technicien/Client)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _selectedRole = UserRole.technician;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor:
                              _selectedRole == UserRole.technician
                                  ? Theme.of(context).primaryColor
                                  : Colors.white,
                          side: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                        ),
                        child: Text(
                          'Technicien',
                          style: TextStyle(
                            color:
                                _selectedRole == UserRole.technician
                                    ? Colors.white
                                    : Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _selectedRole = UserRole.client;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor:
                              _selectedRole == UserRole.client
                                  ? Theme.of(context).primaryColor
                                  : Colors.white,
                          side: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                          ),
                        ),
                        child: Text(
                          'Client',
                          style: TextStyle(
                            color:
                                _selectedRole == UserRole.client
                                    ? Colors.white
                                    : Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Message d'erreur
                Consumer<AuthController>(
                  builder: (context, authController, child) {
                    if (authController.errorMessage != null) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade400),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red.shade700,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  authController.errorMessage!,
                                  style: TextStyle(color: Colors.red.shade700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                TextFormField(
                  controller: _nomController,
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre nom';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _prenomController,
                  decoration: const InputDecoration(
                    labelText: 'Prénom',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre prénom';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Adresse e-mail',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre e-mail';
                    }
                    if (!value.contains('@')) {
                      return 'E-mail invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _telephoneController,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre numéro de téléphone';
                    }
                    // Optional: Add more specific phone number validation
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _paysController,
                  decoration: const InputDecoration(
                    labelText: 'Pays',
                    prefixIcon: Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre pays';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _villeController,
                  decoration: const InputDecoration(
                    labelText: 'Ville',
                    prefixIcon: Icon(Icons.location_city_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre ville';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre mot de passe';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le mot de passe',
                    prefixIcon: const Icon(Icons.lock_reset),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez confirmer votre mot de passe';
                    }
                    if (value != _passwordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Consumer<AuthController>(
                  builder: (context, authController, child) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            authController.isLoading
                                ? null
                                : _performRegistration,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child:
                            authController.isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text(
                                  'S\'inscrire',
                                  style: TextStyle(fontSize: 18),
                                ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Go back to login screen
                  },
                  child: Text.rich(
                    TextSpan(
                      text: 'Vous avez déjà un compte ? ',
                      style: TextStyle(color: Colors.grey[700]),
                      children: [
                        TextSpan(
                          text: 'Connectez-vous',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text.rich(
                  TextSpan(
                    text: 'En vous inscrivant, vous acceptez nos ',
                    style: TextStyle(color: Colors.grey),
                    children: [
                      TextSpan(
                        text: 'conditions d\'utilisation',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        // You can add an onTap here for a link
                      ),
                      TextSpan(text: ' et notre '),
                      TextSpan(
                        text: 'politique de confidentialité',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        // You can add an onTap here for a link
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
