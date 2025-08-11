// lib/models/technician_dashboard_model.dart

import 'package:omeamobile/models/ticket_model.dart';

class TechnicianDashboardData {
  final DashboardSummary dashboardSummary;
  final Ticket? activeTicket;
  final List<Ticket> recentTickets;
  final List<Ticket> allTickets;

  TechnicianDashboardData({
    required this.dashboardSummary,
    this.activeTicket,
    required this.recentTickets,
    required this.allTickets,
  });

  factory TechnicianDashboardData.fromJson(Map<String, dynamic> json) {
    return TechnicianDashboardData(
      dashboardSummary: DashboardSummary.fromJson(json['dashboard_summary'] ?? {}),
      activeTicket: json['active_ticket'] != null 
          ? _parseTicketFromBackend(json['active_ticket'] as Map<String, dynamic>)
          : null,
      recentTickets: (json['recent_tickets'] as List<dynamic>? ?? [])
          .map((item) => _parseTicketFromBackend(item as Map<String, dynamic>))
          .toList(),
      allTickets: (json['all_tickets'] as List<dynamic>? ?? [])
          .map((item) => _parseTicketFromBackend(item as Map<String, dynamic>))
          .toList(),
    );
  }

  static Ticket _parseTicketFromBackend(Map<String, dynamic> json) {
    // Helper pour convertir les données du backend Laravel vers le modèle Ticket Flutter
    TicketStatus parseStatus(String? statusStr) {
      if (statusStr == null) return TicketStatus.pending;
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
          return TicketStatus.pending;
      }
    }

    TicketPriority parsePriority(String? priorityStr) {
      if (priorityStr == null) return TicketPriority.medium;
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
      title: json['title'] as String? ?? json['type_probleme'] as String? ?? 'Sans titre',
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? json['adresse'] as String? ?? '',
      clientName: json['assigned_to'] as String? ?? json['client_name'] as String? ?? 'Client inconnu',
      scheduledTime: _parseScheduledTime(json),
      status: parseStatus(json['status'] as String?),
      priority: parsePriority(json['priority'] as String?),
      distance: json['distance'] != null ? (json['distance'] as num).toDouble() : null,
      technicianName: json['technician_name'] as String?,
      photoBase64: json['photo_base64'] as String?,
    );
  }

  static DateTime _parseScheduledTime(Map<String, dynamic> json) {
    // Essayer d'abord avec date_rdv (format complet)
    if (json['date_rdv'] != null) {
      try {
        return DateTime.parse(json['date_rdv'] as String);
      } catch (e) {
        // Fallback
      }
    }
    
    // Essayer avec scheduled_time
    if (json['scheduled_time'] != null) {
      try {
        return DateTime.parse(json['scheduled_time'] as String);
      } catch (e) {
        // Fallback
      }
    }
    
    // Si on a juste une heure (format "HH:mm")
    if (json['time'] != null) {
      try {
        final timeStr = json['time'] as String;
        final parts = timeStr.split(':');
        if (parts.length >= 2) {
          final now = DateTime.now();
          return DateTime(
            now.year,
            now.month, 
            now.day,
            int.parse(parts[0]),
            int.parse(parts[1]),
          );
        }
      } catch (e) {
        // Fallback
      }
    }
    
    // Fallback sur l'heure actuelle
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'dashboard_summary': dashboardSummary.toJson(),
      'active_ticket': activeTicket?.toJson(),
      'recent_tickets': recentTickets.map((ticket) => ticket.toJson()).toList(),
      'all_tickets': allTickets.map((ticket) => ticket.toJson()).toList(),
    };
  }
}

class DashboardSummary {
  final int ticketsToday;
  final int pendingTickets;
  final int completedTickets;
  final double distanceTraveled;

  DashboardSummary({
    required this.ticketsToday,
    required this.pendingTickets,
    required this.completedTickets,
    required this.distanceTraveled,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      ticketsToday: json['tickets_today'] as int? ?? 0,
      pendingTickets: json['pending_tickets'] as int? ?? 0,
      completedTickets: json['completed_tickets'] as int? ?? 0,
      distanceTraveled: (json['distance_traveled'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tickets_today': ticketsToday,
      'pending_tickets': pendingTickets,
      'completed_tickets': completedTickets,
      'distance_traveled': distanceTraveled,
    };
  }
}