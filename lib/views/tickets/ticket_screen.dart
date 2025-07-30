// lib/views/tickets/tickets_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:omeamobile/controllers/ticket_controller.dart';
import 'package:omeamobile/models/ticket_model.dart';
import 'package:omeamobile/views/dashboard/technician_dashboard_screen.dart'; // Pour _buildTicketListItem

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
      Provider.of<TicketController>(context, listen: false).fetchAllTickets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ticketController = Provider.of<TicketController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tickets'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list), // Icône de filtre
            onPressed: () {
              // Gérer l'action de filtrage
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ticketController.fetchAllTickets(),
        child:
            ticketController.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ticketController.allTickets.isEmpty
                ? const Center(child: Text('Aucun ticket disponible.'))
                : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: ticketController.allTickets.length,
                  itemBuilder: (context, index) {
                    final ticket = ticketController.allTickets[index];
                    // Réutilise le _buildTicketListItem du Dashboard pour la cohérence
                    // Assurez-vous que cette fonction est accessible ou copiée/adaptée.
                    // Pour l'instant, je vais la rendre statique ou la réécrire ici.
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildTicketListItem(
                        context,
                        ticket,
                        ticketController,
                      ),
                    );
                  },
                ),
      ),
    );
  }

  // Copie de _buildTicketListItem du TechnicianDashboardScreen pour éviter les dépendances circulaires
  // Dans un projet plus grand, ce serait un widget séparé dans `lib/views/widgets/ticket_list_item.dart`
  Widget _buildTicketListItem(
    BuildContext context,
    Ticket ticket,
    TicketController controller,
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
        onPressedButton = () async {
          final success = await controller.takeChargeOfTicket(ticket.id);
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ticket pris en charge !')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(controller.errorMessage ?? 'Erreur.')),
            );
          }
        };
        break;
      case TicketStatus.inProgress:
        statusText = 'IN_PROGRESS';
        statusBgColor = Colors.orange.shade100;
        statusTextColor = Colors.orange.shade700;
        buttonText = 'Terminer';
        onPressedButton = () async {
          final success = await controller.completeIntervention(ticket.id);
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Intervention terminée !')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(controller.errorMessage ?? 'Erreur.')),
            );
          }
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
                    height: 30, // Hauteur réduite pour les boutons des listes
                    child: ElevatedButton(
                      onPressed: controller.isLoading ? null : onPressedButton,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            statusTextColor, // Couleur du bouton basée sur le statut
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
