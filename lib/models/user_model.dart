// lib/models/user_model.dart

class User {
  final int id;
  final String nom; // Changé de 'name'
  final String prenom; // Nouveau champ
  final String email;
  final String telephone; // Nouveau champ
  final String pays; // Nouveau champ
  final String ville; // Nouveau champ
  final String role; // 'client' ou 'technician'
  final String? photoProfileUrl; // Changé de 'profilePictureUrl', nullable

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
      nom: json['nom'] as String, // Assurez-vous que Laravel renvoie 'nom'
      prenom:
          json['prenom'] as String, // Assurez-vous que Laravel renvoie 'prenom'
      email: json['email'] as String,
      telephone:
          json['telephone']
              as String, // Assurez-vous que Laravel renvoie 'telephone'
      pays: json['pays'] as String, // Assurez-vous que Laravel renvoie 'pays'
      ville:
          json['ville'] as String, // Assurez-vous que Laravel renvoie 'ville'
      role: json['role'] as String,
      // 'photo_profile' est le nom de colonne Laravel, 'photoProfileUrl' est votre propriété Flutter
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
