// lib/models/user_model.dart

// 1. IMPORTANT: Import the UserRole enum
import 'package:omeamobile/controllers/auth_controller.dart'; // Or wherever your UserRole enum is defined

class User {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String pays;
  final String ville;
<<<<<<< HEAD
  // 2. Change the type of 'role' from String to UserRole enum
  final UserRole role; // 'client' ou 'technician'
=======
  final String role;
>>>>>>> divor
  final String? photoProfileUrl;

  User({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.pays,
    required this.ville,
    required this.role,
    this.photoProfileUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // 3. Parse the role string from JSON into the UserRole enum
    UserRole parsedRole;
    final String roleString = json['role'] as String; // Get the raw string

    // Use a switch statement or if-else for robust parsing
    switch (roleString.toLowerCase()) {
      // Convert to lowercase for safety
      case 'client':
        parsedRole = UserRole.client;
        break;
      case 'technician':
        parsedRole = UserRole.technician;
        break;
      default:
        // Handle unexpected roles gracefully
        print(
          'User.fromJson: Rôle inconnu reçu de l\'API: $roleString. Par défaut, client.',
        );
        parsedRole = UserRole.client; // Fallback to client or throw an error
      // If you want to strictly enforce roles, you could throw:
      // throw ArgumentError('Role non valide reçu de l\'API: $roleString');
    }

    return User(
      id: json['id'] as int,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String,
      telephone: json['telephone'] as String,
      pays: json['pays'] as String,
      ville: json['ville'] as String,
<<<<<<< HEAD
      role: parsedRole, // Assign the parsed enum value here
=======
      role: json['role'] as String,
>>>>>>> divor
      photoProfileUrl: json['photo_profile'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
      'pays': pays,
      'ville': ville,
      // 4. Convert UserRole enum back to string for API calls (if needed)
      'role':
          role
              .toString()
              .split('.')
              .last, // Convert enum to string (e.g., UserRole.client -> 'client')
      'photo_profile': photoProfileUrl,
    };
  }
}
