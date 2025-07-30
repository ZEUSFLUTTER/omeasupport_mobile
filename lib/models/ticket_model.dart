// lib/models/ticket.dart

enum TicketStatus {
  pending,
  inProgress,
  completed,
  cancelled,
  // Ajoutez d'autres statuts si nécessaire
}

enum TicketPriority { low, medium, high, critical }

class Ticket {
  final String id;
  final String title;
  final String description; // Pas toujours visible dans les cards, mais utile
  final String location;
  final String clientName;
  final DateTime scheduledTime;
  final TicketStatus status;
  final TicketPriority priority;
  final double? distance; // Optionnel pour le tableau de bord
  final String? technicianName; // Si un technicien est assigné

  Ticket({
    required this.id,
    required this.title,
    this.description = '', // Valeur par défaut vide
    required this.location,
    required this.clientName,
    required this.scheduledTime,
    required this.status,
    required this.priority,
    this.distance,
    this.technicianName,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    // Helper pour convertir String en Enum
    TicketStatus _parseStatus(String statusStr) {
      switch (statusStr.toLowerCase()) {
        case 'pending':
          return TicketStatus.pending;
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
          return TicketPriority.medium; // Fallback
      }
    }

    return Ticket(
      id: json['id'].toString(), // Assurez-vous que l'ID est un String
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      location: json['location'] as String,
      clientName:
          json['client_name'] as String, // Assurez-vous que l'API renvoie ceci
      scheduledTime: DateTime.parse(json['scheduled_time'] as String),
      status: _parseStatus(json['status'] as String),
      priority: _parsePriority(json['priority'] as String),
      distance:
          json['distance'] != null
              ? (json['distance'] as num).toDouble()
              : null,
      technicianName: json['technician_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'client_name': clientName,
      'scheduled_time': scheduledTime.toIso8601String(),
      'status': status.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'distance': distance,
      'technician_name': technicianName,
    };
  }
}
