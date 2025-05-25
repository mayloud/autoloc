// Prompt: Create the Home screen as a dashboard after login
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _getUserName(User? user) {
    if (user == null) return 'Utilisateur';
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      return user.displayName!;
    }
    // Extraire le nom d'utilisateur de l'email (partie avant @)
    final email = user.email ?? '';
    return email.split('@').first;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = _getUserName(user);

    final List<Map<String, dynamic>> vehicles = [
      {
        'model': 'Toyota Corolla',
        'price': '300 MAD/jour',
        'position': LatLng(34.020882, -6.841650),
      },
      {
        'model': 'Honda Civic',
        'price': '350 MAD/jour',
        'position': LatLng(34.022000, -6.850000),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Section de bienvenue
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  const Icon(
                    Icons.waving_hand,
                    size: 40,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 15),
                  Text(
                    'Bienvenue, $userName !',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Section carte
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
                  options: MapOptions(
                    center: LatLng(34.020882, -6.841650),
                    zoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: vehicles.map((v) => Marker(
                        point: v['position'],
                        width: 60.0,
                        height: 60.0,
                        child: Icon(Icons.directions_car, color: Colors.red),
                      )).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Section liste des véhicules
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Véhicules disponibles',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: vehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = vehicles[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: const Icon(Icons.directions_car),
                          title: Text(vehicle['model']),
                          subtitle: Text(vehicle['price']),
                          trailing: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(vehicle['model']),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Modèle : ${vehicle['model']}'),
                                      const SizedBox(height: 8),
                                      Text('Prix : ${vehicle['price']}'),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Annuler'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Réservation effectuée pour ${vehicle['model']}'),
                                          ),
                                        );
                                      },
                                      child: const Text('Réserver'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Text('Réserver'),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
