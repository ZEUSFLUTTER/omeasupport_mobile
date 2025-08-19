import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:omeamobile/models/ticket_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omeamobile/controllers/blocs/technician_dashboard/technician_dashboard_event.dart';
import 'package:omeamobile/controllers/blocs/technician_dashboard/technician_dashboard_bloc.dart';

class RapportScreen extends StatefulWidget {
  final Ticket ticket;
  final String heureDebut;
  final String heureFin;
  const RapportScreen({
    Key? key,
    required this.ticket,
    required this.heureDebut,
    required this.heureFin,
  }) : super(key: key);

  @override
  State<RapportScreen> createState() => _RapportScreenState();
}

class _RapportScreenState extends State<RapportScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _solutionController = TextEditingController();
  final TextEditingController _dureeController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
  String _statut = 'completed';
  bool _submitted = false;
  Map<String, dynamic>? _rapportData;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _submitted = true;
        _rapportData = {
          'ticket_id': widget.ticket.id,
          'client_id': widget.ticket.clientId,
          'technicien_id': widget.ticket.technicianName ?? '',
          'solution': _solutionController.text,
          'duree': _dureeController.text,
          'prix': _prixController.text,
          'statut': _statut,
          'date_intervention': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'heure_debut': widget.heureDebut,
          'heure_fin': widget.heureFin,
        };
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rapport enregistré avec succès.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _solutionController.dispose();
    _dureeController.dispose();
    _prixController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rapport Ticket #${widget.ticket.id}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _submitted ? _buildSuccessView() : _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Solution', style: TextStyle(fontWeight: FontWeight.bold)),
          TextFormField(
            controller: _solutionController,
            decoration: InputDecoration(
              hintText: "Décrivez la solution apportée",
            ),
            validator:
                (value) =>
                    value == null || value.isEmpty ? 'Champ requis' : null,
          ),
          const SizedBox(height: 12),
          Text('Durée', style: TextStyle(fontWeight: FontWeight.bold)),
          TextFormField(
            controller: _dureeController,
            decoration: InputDecoration(hintText: "Ex: 00:15:00"),
            validator:
                (value) =>
                    value == null || value.isEmpty ? 'Champ requis' : null,
          ),
          const SizedBox(height: 12),
          Text('Prix', style: TextStyle(fontWeight: FontWeight.bold)),
          TextFormField(
            controller: _prixController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "Ex: 7.5"),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Champ requis';
              final n = num.tryParse(value);
              if (n == null) return 'Entrez un nombre valide';
              return null;
            },
          ),
          const SizedBox(height: 12),
          Text('Statut', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButtonFormField<String>(
            value: _statut,
            items: const [
              DropdownMenuItem(value: 'completed', child: Text('Complété')),
              DropdownMenuItem(value: 'suspendu', child: Text('Suspendu')),
            ],
            onChanged: (val) => setState(() => _statut = val ?? 'completed'),
            validator: (value) => value == null ? 'Champ requis' : null,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submitForm,
              icon: const Icon(Icons.save),
              label: const Text('Enregistrer le rapport'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle, color: Colors.green, size: 48),
        const SizedBox(height: 12),
        Text(
          'Rapport enregistré avec succès.',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        if (_rapportData != null) ...[
          Text('Ticket #${_rapportData!['ticket_id']}'),
          Text('Client ID: ${_rapportData!['client_id']}'),
          Text('Technicien ID: ${_rapportData!['technicien_id']}'),
          Text('Solution: ${_rapportData!['solution']}'),
          Text('Durée: ${_rapportData!['duree']}'),
          Text('Prix: ${_rapportData!['prix']}'),
          Text('Statut: ${_rapportData!['statut']}'),
          Text('Date: ${_rapportData!['date_intervention']}'),
          Text('Heure début: ${_rapportData!['heure_debut']}'),
          Text('Heure fin: ${_rapportData!['heure_fin']}'),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // Refresh dashboard
              final dashboardBloc = BlocProvider.of<TechnicianDashboardBloc>(
                context,
                listen: false,
              );
              dashboardBloc.add(TechnicianDashboardDataRequested());

              // Navigate to ending_details.dart with ticket and rapport data
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/ending_details',
                (route) => route.isFirst,
                arguments: {'ticket': widget.ticket, 'rapport': _rapportData},
              );
            },
            icon: const Icon(Icons.dashboard),
            label: const Text('Voir rapport final'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
