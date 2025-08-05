// lib/views/tickets/ticket_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omeamobile/blocs/tickets/ticket_bloc.dart';
import 'package:omeamobile/blocs/tickets/ticket_event.dart';
import 'package:omeamobile/blocs/tickets/ticket_state.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TicketBloc>().add(TicketFetchAllRequested());
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
          if (state is TicketActionSuccess) {
            SnackBarHelper.showSuccess(
              context: context,
              message: state.message,
            );
          } else if (state is TicketError) {
            SnackBarHelper.showError(
              context: context,
              message: state.message,
              actionLabel: 'Réessayer',
              onActionPressed: () {
                context.read<TicketBloc>().add(TicketFetchAllRequested());
              },
            );
          }
        },
        builder: (context, state) {
          if (state is TicketLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Ticket> allTickets = [];
          bool isActionLoading = false;

          if (state is TicketLoaded) {
            allTickets = state.allTickets;
          } else if (state is TicketActionLoading) {
            allTickets = state.allTickets;
            isActionLoading = true;
          } else if (state is TicketActionSuccess) {
            allTickets = state.allTickets;
          } else if (state is TicketError) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<TicketBloc>().add(TicketFetchAllRequested());
              },
              child: const Center(
                child: Text('Erreur lors du chargement des tickets'),
              ),
            );
          }

          if (allTickets.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<TicketBloc>().add(TicketFetchAllRequested());
              },
              child: const Center(child: Text('Aucun ticket disponible.')),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<TicketBloc>().add(TicketFetchAllRequested());
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
        },
      ),
    );
  }

  Widget _buildTicketListItem(
    BuildContext context,
    Ticket ticket,
    bool isActionLoading,
  ) {
    Color priorityColor;
    String statusText;
    Color statusBgColor;
    Color statusTextColor;
    String buttonText = '';
    Function()? onPressedButton;

    switch (ticket.priority) {
      case TicketPriority.low:
        priorityColor = Colors.green;
        break;
      case TicketPriority.medium:
        priorityColor = Colors.orange;
        break;
      case TicketPriority.high:
        priorityColor = Colors.red;
        break;
      case TicketPriority.critical:
        priorityColor = Colors.red.shade900;
        break;
    }

    switch (ticket.status) {
      case TicketStatus.pending:
        statusText = 'PENDING';
        statusBgColor = Colors.blue.shade100;
        statusTextColor = Colors.blue.shade700;
        buttonText = 'Prendre en charge';
        onPressedButton = () {
          context.read<TicketBloc>().add(
            TicketTakeChargeRequested(ticketId: ticket.id),
          );
        };
        break;
      case TicketStatus.inProgress:
        statusText = 'IN_PROGRESS';
        statusBgColor = Colors.orange.shade100;
        statusTextColor = Colors.orange.shade700;
        buttonText = 'Terminer';
        onPressedButton = () {
          context.read<TicketBloc>().add(
            TicketCompleteInterventionRequested(ticketId: ticket.id),
          );
        };
        break;
      case TicketStatus.completed:
        statusText = 'COMPLETED';
        statusBgColor = Colors.green.shade100;
        statusTextColor = Colors.green.shade700;
        buttonText = 'Détails';
        onPressedButton = () {
          // Naviguer vers les détails du ticket
        };
        break;
      case TicketStatus.cancelled:
        statusText = 'CANCELLED';
        statusBgColor = Colors.grey.shade300;
        statusTextColor = Colors.grey.shade700;
        buttonText = 'Détails';
        onPressedButton = () {};
        break;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusTextColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              ticket.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
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
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${ticket.scheduledTime.hour}:${ticket.scheduledTime.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const Spacer(),
                if (buttonText.isNotEmpty)
                  SizedBox(
                    height: 30,
                    child: ElevatedButton(
                      onPressed: isActionLoading ? null : onPressedButton,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: statusTextColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      child: Text(buttonText),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
