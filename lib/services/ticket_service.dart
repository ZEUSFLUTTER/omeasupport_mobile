// lib/services/ticket_service.dart

import 'package:omeamobile/models/ticket_model.dart';
import 'package:omeamobile/services/api_service.dart';
import 'package:intl/intl.dart';

class TicketService {
  final ApiService _apiService;

  TicketService(this._apiService);

  Future<List<Ticket>> getTickets({String? status, String? type}) async {
    final result = await _apiService.getTickets(status: status, type: type);

    if (result['success'] == true && result['data'] is List) {
      return (result['data'] as List)
          .map((json) => Ticket.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(result['message'] ?? 'Failed to fetch tickets');
    }
  }

<<<<<<< HEAD
=======
  /// Creates a new ticket.
>>>>>>> divor
  Future<Ticket> createTicket({
    required String typeProbleme,
    required String description,
    required String adresse,
<<<<<<< HEAD
    required DateTime dateRdv,
=======
    required String dateRdv,
>>>>>>> divor
    List<String>? photosBase64,
  }) async {
    final DateFormat formatter = DateFormat("yyyy-MM-dd HH:mm:ss");
    final String formattedDateRdv = formatter.format(dateRdv.toUtc());

    print('Formatted date_rdv being sent: $formattedDateRdv');

    final result = await _apiService.createTicket(
      typeProbleme: typeProbleme,
      description: description,
      adresse: adresse,
<<<<<<< HEAD
      dateRdv: formattedDateRdv,
      photosBase64: photosBase64,
    );

    // MODIFICATION HERE:
    // Check for 'status' == true and 'ticket' != null from the Laravel response.
    if (result['status'] == true && result['ticket'] != null) {
      return Ticket.fromJson(result['ticket'] as Map<String, dynamic>);
=======
      dateRdv: dateRdv, // Passe la date et l'heure telles quelles
      photosBase64: photosBase64,
    );

    if (result['success'] == true && result['data'] != null) {
      // CORRECTION: ApiService mappe maintenant correctement les données
      final ticketData = result['data'] as Map<String, dynamic>;
      return Ticket.fromJson(ticketData);
>>>>>>> divor
    } else {
      String errorMessage = result['message'] ?? 'Failed to create ticket';
      if (result['errors'] != null) {
        (result['errors'] as Map<String, dynamic>).forEach((key, value) {
          if (value is List) {
            errorMessage += '\n${value.join(', ')}';
          }
        });
      }
      throw Exception(errorMessage);
    }
  }

  Future<bool> startIntervention(int ticketId) async {
    final result = await _apiService.startIntervention(ticketId.toString());
    // Assuming Laravel returns {'status': true} for success
    if (result['status'] == true) {
      return true;
    } else {
      throw Exception(result['message'] ?? 'Failed to start intervention');
    }
  }

  Future<bool> completeIntervention(int ticketId) async {
    final result = await _apiService.completeIntervention(ticketId.toString());
    // Assuming Laravel returns {'status': true} for success
    if (result['status'] == true) {
      return true;
    } else {
      throw Exception(result['message'] ?? 'Failed to complete intervention');
    }
  }

  Future<bool> takeChargeOfTicket(int ticketId) async {
    final result = await _apiService.takeChargeOfTicket(ticketId.toString());
    // Assuming Laravel returns {'status': true} for success
    if (result['status'] == true) {
      return true;
    } else {
      throw Exception(result['message'] ?? 'Failed to take charge of ticket');
    }
  }
<<<<<<< HEAD
=======

  /// Soumet un rapport pour un ticket donné.
  Future<Map<String, dynamic>> submitRapport({
    required String ticketId,
    required Map<String, dynamic> rapportData,
  }) async {
    final result = await _apiService.put(
      '/tickets/$ticketId/rapport',
      data: rapportData,
    );
    if (result['status'] == true) {
      return result;
    } else {
      throw Exception(
        result['message'] ?? 'Erreur lors de l\'envoi du rapport',
      );
    }
  }
>>>>>>> divor
}
