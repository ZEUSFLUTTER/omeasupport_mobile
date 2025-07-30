class Rapport {
  final int id;
  final int ticketId;
  final int clientId;
  final int technicienId;
  final String duree;
  final String solution;
  final double prix;
  final String statut;
  final DateTime? dateIntervention;
  final String? rapportText; // Assuming 'rapport' in backend is text
  final DateTime createdAt;
  final DateTime updatedAt;

  Rapport({
    required this.id,
    required this.ticketId,
    required this.clientId,
    required this.technicienId,
    required this.duree,
    required this.solution,
    required this.prix,
    required this.statut,
    this.dateIntervention,
    this.rapportText,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Rapport.fromJson(Map<String, dynamic> json) {
    return Rapport(
      id: json['id'],
      ticketId: json['ticket_id'],
      clientId: json['client_id'],
      technicienId: json['technicien_id'],
      duree: json['duree'],
      solution: json['solution'],
      prix: (json['prix'] as num).toDouble(),
      statut: json['statut'],
      dateIntervention:
          json['date_intervention'] != null
              ? DateTime.parse(json['date_intervention'])
              : null,
      rapportText: json['rapport'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_id': ticketId,
      'client_id': clientId,
      'technicien_id': technicienId,
      'duree': duree,
      'solution': solution,
      'prix': prix,
      'statut': statut,
      'date_intervention': dateIntervention?.toIso8601String().split('T').first,
      'rapport': rapportText,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
