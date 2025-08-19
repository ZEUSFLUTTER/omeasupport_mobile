// lib/views/tickets/ticket_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omeamobile/controllers/blocs/tickets/ticket_bloc.dart';
import 'package:omeamobile/controllers/blocs/tickets/ticket_event.dart';
import 'package:omeamobile/controllers/blocs/tickets/ticket_state.dart';
import 'package:omeamobile/models/ticket_model.dart';
import 'package:omeamobile/utils/snackbar_helper.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  @override
  void initState() {
    super.initState();
    // Utilisation de addPostFrameCallback pour éviter les conflits de build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TicketBloc>().add(TicketFetchAllRequested());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tickets'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Gérer l'action de filtrage
            },
          ),
        ],
      ),
      body: BlocConsumer<TicketBloc, TicketState>(
        listener: (context, state) {
          if (state is TicketError) {
            SnackBarHelper.showError(
              context: context,
              message: state.message,
              actionLabel: 'Réessayer',
              onActionPressed: () {
                if (mounted) {
                  context.read<TicketBloc>().add(TicketFetchAllRequested());
                }
              },
            );
          }
        },
        builder: (context, state) {
          // Gestion du state Loading
          if (state is TicketLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Chargement des tickets...'),
                ],
              ),
            );
          }

          // Extraction des tickets selon le type de state
          List<Ticket> allTickets = [];
          bool isActionLoading = false;

          if (state is TicketLoaded) {
            allTickets = state.allTickets;
          } else if (state is TicketActionLoading) {
            allTickets = state.allTickets;
            isActionLoading = true;
          } else if (state is TicketCreated) {
            allTickets = state.allTickets;
          } else if (state is TicketError) {
            // En cas d'erreur, on affiche une interface de retry
            return _buildErrorView(context, state.message);
          }

          // Si pas de tickets
          if (allTickets.isEmpty) {
            return _buildEmptyView(context);
          }

          // Affichage de la liste des tickets
          return _buildTicketsList(context, allTickets, isActionLoading);
        },
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String errorMessage) {
    return RefreshIndicator(
      onRefresh: () async {
        if (mounted) {
          context.read<TicketBloc>().add(TicketFetchAllRequested());
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Erreur de chargement',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500]),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    if (mounted) {
                      context.read<TicketBloc>().add(TicketFetchAllRequested());
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        if (mounted) {
          context.read<TicketBloc>().add(TicketFetchAllRequested());
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucun ticket disponible',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tirez vers le bas pour actualiser',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketsList(
    BuildContext context,
    List<Ticket> allTickets,
    bool isActionLoading,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        if (mounted) {
          context.read<TicketBloc>().add(TicketFetchAllRequested());
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: allTickets.length,
        itemBuilder: (context, index) {
          final ticket = allTickets[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildTicketListItem(context, ticket, isActionLoading),
          );
        },
      ),
    );
  }

  Widget _buildTicketListItem(
    BuildContext context,
    Ticket ticket,
    bool isActionLoading,
  ) {
    // Détermination de la couleur de priorité
    Color priorityColor = _getPriorityColor(ticket.priority);

    // Détermination du statut et des couleurs
    final statusConfig = _getStatusConfig(ticket.status);

    // Détermination du bouton d'action
    final buttonConfig = _getButtonConfig(ticket.status, ticket.id);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec priorité et statut
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        ticket.priority
                            .toString()
                            .split('.')
                            .last
                            .toUpperCase(),
                        style: TextStyle(
                          color: priorityColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '#${ticket.id}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusConfig.bgColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    statusConfig.text,
                    style: TextStyle(
                      color: statusConfig.textColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Titre du ticket
            Text(
              ticket.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Informations du client
            Row(
              children: [
                Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  ticket.clientName,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Localisation
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    ticket.location,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Heure et bouton d'action
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatTime(ticket.scheduledTime),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const Spacer(),
                if (buttonConfig != null)
                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      onPressed:
                          isActionLoading ? null : buttonConfig.onPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonConfig.color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      child:
                          isActionLoading
                              ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Text(buttonConfig.text),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(TicketPriority priority) {
    switch (priority) {
      case TicketPriority.low:
        return Colors.green;
      case TicketPriority.medium:
        return Colors.orange;
      case TicketPriority.high:
        return Colors.red;
      case TicketPriority.critical:
        return Colors.red.shade900;
    }
  }

  _StatusConfig _getStatusConfig(TicketStatus status) {
    switch (status) {
      case TicketStatus.pending:
        return _StatusConfig(
          text: 'PENDING',
          bgColor: Colors.blue.shade100,
          textColor: Colors.blue.shade700,
        );
      case TicketStatus.assign:
        return _StatusConfig(
          text: 'ASSIGNÉ',
          bgColor: Colors.blue.shade100,
          textColor: Colors.blue.shade700,
        );
      case TicketStatus.inProgress:
        return _StatusConfig(
          text: 'IN_PROGRESS',
          bgColor: Colors.orange.shade100,
          textColor: Colors.orange.shade700,
        );
      case TicketStatus.completed:
        return _StatusConfig(
          text: 'COMPLETED',
          bgColor: Colors.green.shade100,
          textColor: Colors.green.shade700,
        );
      case TicketStatus.cancelled:
        return _StatusConfig(
          text: 'CANCELLED',
          bgColor: Colors.grey.shade300,
          textColor: Colors.grey.shade700,
        );
    }
  }

  _ButtonConfig? _getButtonConfig(TicketStatus status, String ticketId) {
    switch (status) {
      case TicketStatus.pending:
        return _ButtonConfig(
          text: 'Prendre en charge',
          color: Colors.blue.shade700,
          onPressed: () {
            if (mounted) {
              context.read<TicketBloc>().add(
                TicketTakeChargeRequested(ticketId: ticketId),
              );
            }
          },
        );
      case TicketStatus.assign:
        return _ButtonConfig(
          text: 'Commencer',
          color: Colors.blue.shade700,
          onPressed: () {
            if (mounted) {
              context.read<TicketBloc>().add(
                TicketStartInterventionRequested(ticketId: ticketId),
              );
            }
          },
        );
      case TicketStatus.inProgress:
        return _ButtonConfig(
          text: 'Terminer',
          color: Colors.orange.shade700,
          onPressed: () {
            if (mounted) {
              context.read<TicketBloc>().add(
                TicketCompleteInterventionRequested(ticketId: ticketId),
              );
            }
          },
        );
      case TicketStatus.completed:
        return _ButtonConfig(
          text: 'Détails',
          color: Colors.green.shade700,
          onPressed: () {},
        );
      case TicketStatus.cancelled:
        return null; // Pas de bouton pour les tickets annulés
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

// Classes helper pour la configuration
class _StatusConfig {
  final String text;
  final Color bgColor;
  final Color textColor;

  _StatusConfig({
    required this.text,
    required this.bgColor,
    required this.textColor,
  });
}

class _ButtonConfig {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  _ButtonConfig({
    required this.text,
    required this.color,
    required this.onPressed,
  });
}
