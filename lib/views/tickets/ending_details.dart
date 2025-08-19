import 'package:flutter/material.dart';
import 'package:omeamobile/models/ticket_model.dart';

class EndingDetailsScreen extends StatelessWidget {
  final Ticket ticket;
  final Map<String, dynamic>? rapport;
  const EndingDetailsScreen({Key? key, required this.ticket, this.rapport})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Détails finaux Ticket #${ticket.id}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                rapport == null
                    ? const Center(child: Text('Aucun rapport disponible.'))
                    : ListView(
                      children: [
                        Text(
                          'Ticket #${rapport!['ticket_id']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('Client ID: ${rapport!['client_id']}'),
                        Text('Technicien ID: ${rapport!['technicien_id']}'),
                        Text('Solution: ${rapport!['solution']}'),
                        Text('Durée: ${rapport!['duree']}'),
                        Text('Prix: ${rapport!['prix']}'),
                        Text('Statut: ${rapport!['statut']}'),
                        Text('Date: ${rapport!['date_intervention']}'),
                        Text('Heure début: ${rapport!['heure_debut']}'),
                        Text('Heure fin: ${rapport!['heure_fin']}'),
                      ],
                    ),
          ),
        ),
      ),
    );
  }
}
