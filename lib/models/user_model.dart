// lib/models/user_model.dart

class User {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String pays;
  final String ville;
  final String role;
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
    return User(
      id: json['id'] as int,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String,
      telephone: json['telephone'] as String,
      pays: json['pays'] as String,
      ville: json['ville'] as String,
      role: json['role'] as String,
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
      'role': role,
      'photo_profile':
          photoProfileUrl, // Convertir de retour pour l'API si besoin
    };
  }
}
