// lib/utils/string_extensions.dart
// Créer ce fichier pour avoir l'extension disponible globalement

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
  
  String capitalizeWords() {
    return split(' ').map((word) => word.capitalize()).join(' ');
  }
  
  String formatRole() {
    switch (toLowerCase()) {
      case 'client':
        return 'Client';
      case 'technician':
        return 'Technicien';
      default:
        return capitalize();
    }
  }
}