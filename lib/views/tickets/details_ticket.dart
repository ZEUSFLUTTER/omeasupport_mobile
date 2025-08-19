import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:omeamobile/models/ticket_model.dart';
import 'package:omeamobile/services/api_service.dart';

class DetailsTicketScreen extends StatefulWidget {
  final Ticket ticket;
  const DetailsTicketScreen({Key? key, required this.ticket}) : super(key: key);

  @override
  State<DetailsTicketScreen> createState() => _DetailsTicketScreenState();
}

class _DetailsTicketScreenState extends State<DetailsTicketScreen> {
  bool _isDeleting = false;

  Color _statusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.inProgress:
        return Colors.orange;
      case TicketStatus.completed:
        return Colors.green;
      case TicketStatus.pending:
        return Colors.blueGrey;
      case TicketStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusText(TicketStatus status) {
    switch (status) {
      case TicketStatus.inProgress:
        return 'En cours';
      case TicketStatus.completed:
        return 'Terminé';
      case TicketStatus.pending:
        return 'En attente';
      case TicketStatus.cancelled:
        return 'Annulé';
      default:
        return 'Inconnu';
    }
  }

  Future<void> _deleteTicket() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Supprimer le ticket'),
            content: const Text(
              'Voulez-vous vraiment supprimer ce ticket ? Cette action est irréversible.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Supprimer'),
              ),
            ],
          ),
    );
    if (confirm != true) return;
    setState(() {
      _isDeleting = true;
    });
    final result = await ApiService().deleteTicket(widget.ticket.id.toString());
    setState(() {
      _isDeleting = false;
    });
    if (result['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Ticket supprimé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // On revient à l'écran précédent
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Erreur lors de la suppression'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticket = widget.ticket;
    return Scaffold(
      appBar: AppBar(
        title: Text('Détail du ticket #${ticket.id}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Supprimer',
            onPressed: _isDeleting ? null : _deleteTicket,
          ),
        ],
      ),
      body:
          _isDeleting
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (ticket.status == TicketStatus.completed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.payment),
                            label: const Text('Payer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () async {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder:
                                    (ctx) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                              );
                              final result = await ApiService().getPaymentLink(
                                ticket.id,
                              );
                              Navigator.of(context).pop(); // Remove loading
                              if (result['success'] == true &&
                                  result['url'] != null) {
                                showDialog(
                                  context: context,
                                  builder:
                                      (ctx) => AlertDialog(
                                        title: const Text('Lien de paiement'),
                                        content: SelectableText(result['url']),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.of(ctx).pop(),
                                            child: const Text('Fermer'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              final url = result['url'];
                                              Navigator.of(ctx).pop();
                                              // ignore: deprecated_member_use
                                              await Future.delayed(
                                                const Duration(
                                                  milliseconds: 100,
                                                ),
                                              );
                                              // Use url_launcher if available
                                            },
                                            child: const Text('Ouvrir'),
                                          ),
                                        ],
                                      ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      result['message'] ??
                                          'Erreur lors de la génération du lien de paiement',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    ticket.title,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _statusColor(
                                      ticket.status,
                                    ).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _statusText(ticket.status),
                                    style: TextStyle(
                                      color: _statusColor(ticket.status),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  ticket.scheduledTime != null
                                      ? '${ticket.scheduledTime.day.toString().padLeft(2, '0')}/'
                                          '${ticket.scheduledTime.month.toString().padLeft(2, '0')}/'
                                          '${ticket.scheduledTime.year} à '
                                          '${ticket.scheduledTime.hour.toString().padLeft(2, '0')}:${ticket.scheduledTime.minute.toString().padLeft(2, '0')}'
                                      : 'Non planifié',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.person_outline,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Technicien : ${ticket.technicianName ?? 'Non assigné'}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    ticket.location ??
                                        ticket.location ??
                                        'Adresse non renseignée',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          ticket.description ?? 'Aucune description',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (ticket.photoBase64 != null &&
                        ticket.photoBase64!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Photo',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              base64Decode(ticket.photoBase64!),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 200,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    const Divider(height: 32),
                    Card(
                      color: Colors.grey[50],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'ID du ticket : ',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  '#${ticket.id}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            if (ticket.title != null ||
                                ticket.title != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Text(
                                    'Type de problème : ',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  Text(
                                    ticket.title ?? ticket.title ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
