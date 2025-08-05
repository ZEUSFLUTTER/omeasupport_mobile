// lib/views/tickets/new_ticket_screen.dart

// ignore_for_file: use_build_context_synchronously

import 'dart:convert'; // For base64 encoding
import 'dart:typed_data'; // For Uint8List on web

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:omeamobile/services/api_service.dart'; // Import ApiService for initialization
import 'package:omeamobile/services/ticket_service.dart'; // Import your TicketService
import 'package:omeamobile/models/ticket_model.dart';
import 'package:omeamobile/utils/snackbar_helper.dart'; // Import Ticket model to handle response

// Import pour vérifier la plateforme (si web ou non)

class NewTicketScreen extends StatefulWidget {
  const NewTicketScreen({super.key});

  @override
  State<NewTicketScreen> createState() => _NewTicketScreenState();
}

class _NewTicketScreenState extends State<NewTicketScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dateRdvController =
      TextEditingController(); // For date picker
  String? _selectedProblemType;

  // CHANGEMENT MAJEUR ICI: Stocker les XFile directement pour la compatibilité web
  final List<XFile> _selectedPhotos = []; // Utilisez XFile au lieu de File

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

  @override
  void initState() {
    super.initState();
    _ticketService = TicketService(ApiService());
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();
    _dateRdvController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedPhotos.add(pickedFile); // Ajoutez XFile directement
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _dateRdvController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submitTicket() async {
    if (_formKey.currentState!.validate()) {
      if (_dateRdvController.text.isEmpty) {
        SnackBarHelper.showWarning(
          context: context,
          message: 'Veuillez sélectionner une date de rendez-vous',
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      List<String> photosBase64 = [];
      for (XFile photo in _selectedPhotos) {
        // Itérer sur XFile
        // Lire les octets de l'image de manière compatible avec le web
        Uint8List imageBytes = await photo.readAsBytes();
        photosBase64.add(base64Encode(imageBytes));
      }

      try {
        final Ticket createdTicket = await _ticketService.createTicket(
          typeProbleme: _selectedProblemType!,
          description: _descriptionController.text.trim(),
          adresse: _addressController.text.trim(),
          dateRdv: DateTime.parse(_dateRdvController.text),
          photosBase64: photosBase64,
        );

        SnackBarHelper.showSuccess(
          context: context,
          message: 'Ticket #${createdTicket.id} créé avec succès !',
          actionLabel: 'Voir',
          onActionPressed: () {
            // Navigation vers les détails du ticket
          },
        );
        Navigator.pop(context);
      } catch (e) {
        SnackBarHelper.showError(
          context: context,
          message: 'Erreur lors de la création : ${e.toString()}',
          actionLabel: 'Réessayer',
          onActionPressed: () => _submitTicket(),
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
                              // CHANGEMENT MAJEUR ICI: Utiliser Image.memory pour le web
                              final XFile photo = _selectedPhotos[index];
                              return Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    // Utilisez Image.memory pour afficher les octets de l'image
                                    // C'est compatible avec mobile et web.
                                    child: FutureBuilder<Uint8List>(
                                      future:
                                          photo
                                              .readAsBytes(), // Lire les octets
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                                ConnectionState.done &&
                                            snapshot.hasData) {
                                          return Image.memory(
                                            snapshot
                                                .data!, // Utilisez les octets pour afficher
                                            width: 90,
                                            height: 90,
                                            fit: BoxFit.cover,
                                          );
                                        }
                                        // Ou un indicateur de chargement si l'image prend du temps à charger
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
