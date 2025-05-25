import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddVehicleScreen extends StatefulWidget {
  final String? vehicleId;
  final String? initialModel;
  final String? initialPrice;
  final LatLng? initialPosition;

  const AddVehicleScreen({
    super.key,
    this.vehicleId,
    this.initialModel,
    this.initialPrice,
    this.initialPosition,
  });

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _modelController = TextEditingController();
  final _priceController = TextEditingController();
  LatLng? _selectedPosition;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    if (widget.initialModel != null) {
      _modelController.text = widget.initialModel!;
    }
    if (widget.initialPrice != null) {
      _priceController.text = widget.initialPrice!;
    }
    if (widget.initialPosition != null) {
      _selectedPosition = widget.initialPosition;
    }
  }

  @override
  void dispose() {
    _modelController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveVehicle() async {
    if (_formKey.currentState!.validate() && _selectedPosition != null) {
      try {
        print('Début de l\'ajout du véhicule'); // Message de débogage

        final vehicleData = {
          'model': _modelController.text,
          'price': _priceController.text,
          'latitude': _selectedPosition!.latitude,
          'longitude': _selectedPosition!.longitude,
          'ownerId': FirebaseAuth.instance.currentUser?.uid,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        print('Données du véhicule préparées: $vehicleData'); // Message de débogage

        if (widget.vehicleId == null) {
          vehicleData['createdAt'] = FieldValue.serverTimestamp();
          await FirebaseFirestore.instance.collection('vehicles').add(vehicleData);
          print('Véhicule ajouté à Firestore'); // Message de débogage
        } else {
          await FirebaseFirestore.instance
              .collection('vehicles')
              .doc(widget.vehicleId)
              .update(vehicleData);
          print('Véhicule mis à jour dans Firestore'); // Message de débogage
        }

        if (!mounted) {
          print('Widget non monté après l\'ajout'); // Message de débogage
          return;
        }

        print('Tentative d\'affichage du dialogue de succès'); // Message de débogage

        // Afficher le message de succès directement avec ScaffoldMessenger
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  widget.vehicleId == null
                      ? 'Véhicule ${_modelController.text} ajouté avec succès !'
                      : 'Véhicule ${_modelController.text} modifié avec succès !',
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(10),
          ),
        );

        // Réinitialiser le formulaire
        _modelController.clear();
        _priceController.clear();
        setState(() {
          _selectedPosition = null;
        });

        // Attendre un court instant avant de retourner à l'écran précédent
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.of(context).pop();
        }

      } catch (e) {
        print('Erreur lors de l\'ajout du véhicule: $e'); // Message de débogage
        
        if (!mounted) return;

        // Afficher le message d'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Erreur: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(10),
          ),
        );
      }
    } else if (_selectedPosition == null) {
      // Afficher le message d'avertissement
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 10),
              Text('Veuillez sélectionner une position sur la carte'),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          margin: EdgeInsets.all(10),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vehicleId == null ? 'Ajouter un véhicule' : 'Modifier le véhicule'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: _selectedPosition ?? LatLng(34.020882, -6.841650),
                    zoom: 13.0,
                    onTap: (tapPosition, point) {
                      setState(() {
                        _selectedPosition = point;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                    ),
                    if (_selectedPosition != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _selectedPosition!,
                            width: 60.0,
                            height: 60.0,
                            child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _modelController,
                      decoration: const InputDecoration(
                        labelText: 'Modèle du véhicule',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le modèle du véhicule';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Prix par jour (MAD)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le prix';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveVehicle,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: Text(
                        widget.vehicleId == null ? 'Ajouter le véhicule' : 'Modifier le véhicule',
                      ),
                    ),
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