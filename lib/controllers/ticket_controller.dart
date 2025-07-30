// lib/controllers/ticket_controller.dart

import 'package:flutter/material.dart';
import 'package:omeamobile/models/ticket_model.dart';
import 'package:omeamobile/services/api_service.dart';

class TicketController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _errorMessage;
  List<Ticket> _allTickets = [];
  List<Ticket> _todaysTickets = [];
  List<Ticket> _pendingTickets = [];
  List<Ticket> _completedTickets = [];
  Ticket? _activeTicket; // Le "TICKET ACTIF" sur le dashboard

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Ticket> get allTickets => _allTickets;
  List<Ticket> get todaysTickets => _todaysTickets;
  List<Ticket> get pendingTickets => _pendingTickets;
  List<Ticket> get completedTickets => _completedTickets;
  Ticket? get activeTicket => _activeTicket;

  TicketController() {
    // Peut charger les tickets au démarrage si nécessaire
    // ou les écrans appelleront les méthodes de chargement.
  }

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Récupérer tous les tickets
      final allTicketsResult = await _apiService.getTickets();
      if (allTicketsResult['success'] == true) {
        _allTickets = allTicketsResult['tickets'] as List<Ticket>;
      } else {
        _errorMessage = allTicketsResult['message'];
        _isLoading = false;
        notifyListeners();
        return;
      }


      _todaysTickets = _allTickets.where((t) => t.scheduledTime.day == DateTime.now().day && t.status != TicketStatus.completed).toList();
      _pendingTickets = _allTickets.where((t) => t.status == TicketStatus.pending).toList();
      _completedTickets = _allTickets.where((t) => t.status == TicketStatus.completed && t.scheduledTime.day == DateTime.now().day).toList();
      _activeTicket = _allTickets.firstWhere(
        (t) => t.status == TicketStatus.inProgress,
        orElse: () => Ticket(
          id: '', title: '', location: '', clientName: '', scheduledTime: DateTime.now(),
          status: TicketStatus.pending, priority: TicketPriority.low, description: ''
        ) 
      );


    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des données: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllTickets() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.getTickets();
      if (result['success'] == true) {
        _allTickets = result['tickets'] as List<Ticket>;
      } else {
        _errorMessage = result['message'];
      }
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des tickets: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> startIntervention(String ticketId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _apiService.startIntervention(ticketId);
      if (result['success'] == true) {
        await fetchDashboardData(); 
        return true;
      } else {
        _errorMessage = result['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> completeIntervention(String ticketId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _apiService.completeIntervention(ticketId);
      if (result['success'] == true) {
        await fetchDashboardData();
        return true;
      } else {
        _errorMessage = result['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> takeChargeOfTicket(String ticketId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _apiService.takeChargeOfTicket(ticketId);
      if (result['success'] == true) {
        await fetchAllTickets(); // Recharger tous les tickets pour voir le changement
        return true;
      } else {
        _errorMessage = result['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}