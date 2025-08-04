import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // Assurez-vous d'avoir ceci
import 'package:omeamobile/services/api_service.dart';
import 'package:omeamobile/services/ticket_service.dart';
import 'package:omeamobile/models/ticket_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class NewTicketScreen extends StatefulWidget {
  const NewTicketScreen({super.key});

  @override
  State<NewTicketScreen> createState() => _NewTicketScreenState();
}

class _NewTicketScreenState extends State<NewTicketScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  // Un seul contrôleur pour la date et l'heure combinées
  final TextEditingController _dateTimeRdvController = TextEditingController();
  String? _selectedProblemType;

  List<XFile> _selectedPhotos = [];
  bool _isLoading = false;

  final List<String> _problemTypes = [
    'Problème d\'imprimante',
    'Configuration wifi',
    'Problème de gazinière',
    'Panne réseau',
    'Logiciel lent',
    'Autre',
  ];

  final ImagePicker _picker = ImagePicker();
  late final TicketService _ticketService;

  // Un seul objet DateTime pour stocker la date et l'heure combinées
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _ticketService = TicketService(ApiService());
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();
    _dateTimeRdvController.dispose(); // Dispose du nouveau contrôleur combiné
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedPhotos.add(pickedFile);
      });
    }
  }

  // Nouvelle fonction pour sélectionner la date ET l'heure
  Future<void> _selectDateTime(BuildContext context) async {
    // 1. Sélection de la date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (pickedDate == null)
      return; // L'utilisateur a annulé la sélection de la date

    // 2. Sélection de l'heure, après la date
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
    );

    if (pickedTime == null)
      return; // L'utilisateur a annulé la sélection de l'heure

    // 3. Combinaison de la date et de l'heure sélectionnées
    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      // Formate la date et l'heure combinées pour l'affichage dans le champ de texte
      _dateTimeRdvController.text = DateFormat(
        'yyyy-MM-dd HH:mm',
      ).format(_selectedDateTime!);
    });
  }

  Future<void> _submitTicket() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDateTime == null) {
        // Vérifier si la date et l'heure combinées ont été sélectionnées
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Veuillez sélectionner une date et une heure de rendez-vous',
            ),
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      List<String> photosBase64 = [];
      for (XFile photo in _selectedPhotos) {
        Uint8List imageBytes = await photo.readAsBytes();
        photosBase64.add(base64Encode(imageBytes));
      }

      try {
        final Ticket createdTicket = await _ticketService.createTicket(
          typeProbleme: _selectedProblemType!,
          description: _descriptionController.text.trim(),
          adresse: _addressController.text.trim(),
          dateRdv: _selectedDateTime!, // Envoyez l'objet DateTime combiné
          photosBase64: photosBase64,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ticket ${createdTicket.id} créé avec succès!'),
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau ticket'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedProblemType,
                decoration: const InputDecoration(
                  hintText: 'Sélectionner',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                ),
                items:
                    _problemTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedProblemType = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner un type de problème';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Description',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Décrivez votre problème',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez décrire votre problème';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Photos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      _selectedPhotos.isEmpty
                          ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                size: 40,
                                color: Colors.grey,
                              ),
                              Text('Taper pour ajouter des photos'),
                            ],
                          )
                          : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedPhotos.length,
                            itemBuilder: (context, index) {
                              final XFile photo = _selectedPhotos[index];
                              return Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: FutureBuilder<Uint8List>(
                                      future: photo.readAsBytes(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                                ConnectionState.done &&
                                            snapshot.hasData) {
                                          return Image.memory(
                                            snapshot.data!,
                                            width: 90,
                                            height: 90,
                                            fit: BoxFit.cover,
                                          );
                                        }
                                        return Container(
                                          width: 90,
                                          height: 90,
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedPhotos.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        color: Colors.black54,
                                        child: const Icon(
                                          Icons.remove_circle,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Adresse',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  hintText: 'Entrez votre adresse',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre adresse';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Date et Heure du rendez-vous', // Nouveau libellé
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller:
                    _dateTimeRdvController, // Utilisez le nouveau contrôleur
                readOnly: true,
                onTap:
                    () => _selectDateTime(
                      context,
                    ), // Appelez la nouvelle fonction combinée
                decoration: const InputDecoration(
                  hintText: 'Sélectionner date et heure', // Nouveau hint
                  suffixIcon: Icon(
                    Icons.calendar_today,
                  ), // Icône pour le sélecteur
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner une date et une heure de rendez-vous';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitTicket,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Soumettre', style: TextStyle(fontSize: 18)),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward),
                            ],
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
