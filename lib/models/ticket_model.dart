// lib/models/ticket.dart

enum TicketStatus { pending, inProgress, assign, completed, cancelled }

enum TicketPriority { low, medium, high, critical }

class Ticket {
  final String id;
  final String title;
  final String description; // Pas toujours visible dans les cards, mais utile
  final String location;
  final String clientName;
  final String clientId; // Ajouté pour l'id du client
  final DateTime scheduledTime;
  final TicketStatus status;
  final TicketPriority priority;
  final double? distance; // Optionnel pour le tableau de bord
  final String? technicianName;
  final String? photoBase64; // Si un technicien est assigné
  final Map<String, dynamic>? rapport; // Ajout rapport

  Ticket({
    required this.id,
    required this.title,
    this.description = '', // Valeur par défaut vide
    required this.location,
    required this.clientName,
    required this.clientId,
    required this.scheduledTime,
    required this.status,
    required this.priority,
    this.distance,
    this.technicianName,
    this.photoBase64,
    this.rapport,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    // Helper pour convertir String en Enum
    TicketStatus _parseStatus(String statusStr) {
      switch (statusStr.toLowerCase()) {
        case 'pending':
          return TicketStatus.pending;
        case 'assign':
          return TicketStatus.assign;
        case 'in_progress':
          return TicketStatus.inProgress;
        case 'completed':
          return TicketStatus.completed;
        case 'cancelled':
          return TicketStatus.cancelled;
        default:
          return TicketStatus.pending; // Fallback
      }
    }

    TicketPriority _parsePriority(String priorityStr) {
      switch (priorityStr.toLowerCase()) {
        case 'low':
          return TicketPriority.low;
        case 'medium':
          return TicketPriority.medium;
        case 'high':
          return TicketPriority.high;
        case 'critical':
          return TicketPriority.critical;
        default:
          return TicketPriority.medium;
      }
    }

    return Ticket(
      id: json['id'].toString(),
      title: json['type_probleme'] as String? ?? 'Sans titre',
      description: json['description'] as String? ?? '',
      location: json['adresse'] as String? ?? '',
      clientName: json['client_name'] as String? ?? 'Client inconnu',
      clientId: json['user_id']?.toString() ?? '',
      scheduledTime: DateTime.parse(json['date_rdv'] as String),
      status: _parseStatus(json['statut'] as String? ?? 'pending'),
      priority: _parsePriority(json['priority'] as String? ?? 'medium'),
      distance:
          json['distance'] != null
              ? (json['distance'] as num).toDouble()
              : null,
      technicianName: json['technician_name'] as String?,
      photoBase64: json['photo_base64'] as String?,
      rapport: json['rapport'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'client_name': clientName,
      'client_id': clientId,
      'scheduled_time': scheduledTime.toIso8601String(),
      'status': status.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'distance': distance,
      'technician_name': technicianName,
      'photo_base64': photoBase64,
      'rapport': rapport,
    };
  }
}
