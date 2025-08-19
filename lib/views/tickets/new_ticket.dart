<<<<<<< HEAD
import 'dart:io';
=======
// lib/views/tickets/new_ticket_screen.dart

>>>>>>> divor
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
<<<<<<< HEAD
import 'package:intl/intl.dart'; // Assurez-vous d'avoir ceci
import 'package:omeamobile/services/api_service.dart';
import 'package:omeamobile/services/ticket_service.dart';
import 'package:omeamobile/models/ticket_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
=======
import 'package:intl/intl.dart';
import 'package:omeamobile/controllers/blocs/tickets/ticket_bloc.dart';
import 'package:omeamobile/controllers/blocs/tickets/ticket_event.dart';
import 'package:omeamobile/controllers/blocs/tickets/ticket_state.dart';
import 'package:omeamobile/utils/snackbar_helper.dart';
>>>>>>> divor

class NewTicketScreen extends StatefulWidget {
  const NewTicketScreen({super.key});

  @override
  State<NewTicketScreen> createState() => _NewTicketScreenState();
}

class _NewTicketScreenState extends State<NewTicketScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
<<<<<<< HEAD
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
=======
  final TextEditingController _dateRdvController = TextEditingController();

  String? _selectedTime; // Ajouté pour stocker l'heure HH:mm

  final List<XFile> _selectedPhotos = [];

  final ImagePicker _picker = ImagePicker();
>>>>>>> divor

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

<<<<<<< HEAD
  // Nouvelle fonction pour sélectionner la date ET l'heure
  Future<void> _selectDateTime(BuildContext context) async {
    // 1. Sélection de la date
=======
  Future<void> _selectDate(BuildContext context) async {
>>>>>>> divor
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
<<<<<<< HEAD

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
=======
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        final DateTime fullDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          _dateRdvController.text = DateFormat(
            'yyyy-MM-dd HH:mm:ss',
          ).format(fullDateTime);
          _selectedTime = DateFormat('HH:mm').format(fullDateTime); // Stocke l'heure
        });
      }
    }
>>>>>>> divor
  }

  Future<void> _submitTicket() async {
    if (_formKey.currentState!.validate()) {
<<<<<<< HEAD
      if (_selectedDateTime == null) {
        // Vérifier si la date et l'heure combinées ont été sélectionnées
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Veuillez sélectionner une date et une heure de rendez-vous',
            ),
          ),
=======
      if (_dateRdvController.text.isEmpty) {
        SnackBarHelper.showWarning(
          context: context,
          message: 'Veuillez sélectionner une date de rendez-vous',
>>>>>>> divor
        );
        return;
      }

      List<String> photosBase64 = [];
      for (XFile photo in _selectedPhotos) {
        Uint8List imageBytes = await photo.readAsBytes();
        photosBase64.add(base64Encode(imageBytes));
      }

      // Formater la date et l'heure au format yyyy-MM-dd HH:mm:ss
      final String dateRdvFormatted = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(_dateRdvController.text));
      context.read<TicketBloc>().add(
        TicketCreateRequested(
          typeProbleme: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          adresse: _addressController.text.trim(),
<<<<<<< HEAD
          dateRdv: _selectedDateTime!, // Envoyez l'objet DateTime combiné
=======
          dateRdv: dateRdvFormatted, // Envoie la date et l'heure formatées
>>>>>>> divor
          photosBase64: photosBase64,
          time: _selectedTime, // Envoie l'heure au backend (optionnel)
        ),
      );
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
      body: BlocConsumer<TicketBloc, TicketState>(
        listener: (context, state) {
          if (state is TicketCreated) {
            SnackBarHelper.showSuccess(
              context: context,
              message: 'Ticket #${state.createdTicket.id} créé avec succès !',
              actionLabel: 'Voir',
              onActionPressed: () {
                // Navigation vers les détails du ticket
              },
            );
            Navigator.pop(context);
          } else if (state is TicketError) {
            SnackBarHelper.showError(
              context: context,
              message: state.message,
              actionLabel: 'Réessayer',
              onActionPressed: _submitTicket,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is TicketLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Titre du problème',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Ex: Problème d\'imprimante, panne réseau...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez saisir le titre de votre problème';
                      }
                      return null;
                    },
                  ),
<<<<<<< HEAD
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
=======
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
>>>>>>> divor
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
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
<<<<<<< HEAD
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
=======
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
>>>>>>> divor
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
                    'Date du rendez-vous',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _dateRdvController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    decoration: const InputDecoration(
                      hintText: 'Sélectionner une date',
                      suffixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(12),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez sélectionner une date de rendez-vous';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submitTicket,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child:
                          isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Soumettre',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward),
                                ],
                              ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
