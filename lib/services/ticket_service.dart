// lib/services/ticket_service.dart
// This service acts as an abstraction layer for ticket-related API calls,
// utilizing the core ApiService for HTTP communication.

import 'package:omeamobile/models/ticket_model.dart'; // Make sure this is the adjusted model
import 'package:omeamobile/services/api_service.dart';

class TicketService {
  final ApiService _apiService; // Use the existing ApiService instance

  TicketService(this._apiService); // Constructor to inject ApiService

  /// Fetches a list of tickets, optionally filtered by status or type.
  Future<List<Ticket>> getTickets({String? status, String? type}) async {
    final result = await _apiService.getTickets(status: status, type: type);

    if (result['success'] == true && result['data'] is List) {
      return (result['data'] as List)
          .map((json) => Ticket.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      // You can throw an exception or return an empty list based on your error handling strategy
      throw Exception(result['message'] ?? 'Failed to fetch tickets');
    }
  }

  /// Creates a new ticket.
  /// This method directly uses the `createTicket` from ApiService.
  Future<Ticket> createTicket({
    required String typeProbleme,
    required String description,
    required String adresse,
    required DateTime dateRdv, // Accept DateTime, convert to String for API
    List<String>? photosBase64,
  }) async {
    final result = await _apiService.createTicket(
      typeProbleme: typeProbleme,
      description: description,
      adresse: adresse,
      dateRdv:
          dateRdv.toIso8601String().split('T').first, // Format to YYYY-MM-DD
      photosBase64: photosBase64,
    );

    if (result['success'] == true && result['data'] != null) {
      return Ticket.fromJson(result['data'] as Map<String, dynamic>);
    } else {
      String errorMessage = result['message'] ?? 'Failed to create ticket';
      if (result['errors'] != null) {
        // Concatenate validation errors
        (result['errors'] as Map<String, dynamic>).forEach((key, value) {
          errorMessage += '\n${value.join(', ')}';
        });
      }
      throw Exception(errorMessage);
    }
  }

  /// Starts an intervention for a given ticket ID.
  Future<bool> startIntervention(int ticketId) async {
    final result = await _apiService.startIntervention(ticketId.toString());
    if (result['success'] == true) {
      return true;
    } else {
      throw Exception(result['message'] ?? 'Failed to start intervention');
    }
  }

  /// Completes an intervention for a given ticket ID.
  Future<bool> completeIntervention(int ticketId) async {
    final result = await _apiService.completeIntervention(ticketId.toString());
    if (result['success'] == true) {
      return true;
    } else {
      throw Exception(result['message'] ?? 'Failed to complete intervention');
    }
  }

  /// Takes charge of a ticket.
  Future<bool> takeChargeOfTicket(int ticketId) async {
    final result = await _apiService.takeChargeOfTicket(ticketId.toString());
    if (result['success'] == true) {
      return true;
    } else {
      throw Exception(result['message'] ?? 'Failed to take charge of ticket');
    }
  }



}
