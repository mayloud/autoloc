// Prompt: Create the Home screen as a dashboard after login
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_vehicle_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Tous';
  final List<String> _filters = ['Tous', 'Disponibles', 'Réservés', 'Prix croissant', 'Prix décroissant'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('AutoLoc'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue.shade800, Colors.blue.shade500],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.directions_car,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenue, ${FirebaseAuth.instance.currentUser?.email ?? 'Utilisateur'}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  // Barre de recherche
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un véhicule...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                  // Filtres
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _filters.map((filter) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(
                              filter,
                              style: const TextStyle(fontSize: 12),
                            ),
                            selected: _selectedFilter == filter,
                            onSelected: (selected) {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                            backgroundColor: Colors.grey.shade200,
                            selectedColor: Colors.blue.shade100,
                            checkmarkColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Section carte
          SliverToBoxAdapter(
            child: Container(
              height: 300,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('vehicles').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text('Erreur de chargement de la carte'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final vehicles = snapshot.data?.docs ?? [];
                    final markers = vehicles.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final isReserved = data['isReserved'] ?? false;
                      return Marker(
                        point: LatLng(
                          data['latitude'] as double,
                          data['longitude'] as double,
                        ),
                        width: 50.0,
                        height: 50.0,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.directions_car,
                              color: isReserved ? Colors.orange : Colors.blue,
                              size: 25,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              child: Text(
                                '${data['price']} MAD',
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList();

                    return FlutterMap(
                      options: MapOptions(
                        center: LatLng(34.020882, -6.841650),
                        zoom: 13.0,
                        onTap: (_, __) {},
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: ['a', 'b', 'c'],
                        ),
                        MarkerLayer(markers: markers),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('vehicles').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const SliverFillRemaining(
                  child: Center(child: Text('Une erreur est survenue')),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              var vehicles = snapshot.data!.docs;
              
              // Appliquer la recherche
              if (_searchController.text.isNotEmpty) {
                vehicles = vehicles.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['model'].toString().toLowerCase().contains(_searchController.text.toLowerCase());
                }).toList();
              }

              // Appliquer les filtres
              vehicles = vehicles.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                switch (_selectedFilter) {
                  case 'Disponibles':
                    return !(data['isReserved'] ?? false);
                  case 'Réservés':
                    return data['isReserved'] ?? false;
                  case 'Prix croissant':
                    vehicles.sort((a, b) {
                      final priceA = double.tryParse((a.data() as Map<String, dynamic>)['price'] ?? '0') ?? 0;
                      final priceB = double.tryParse((b.data() as Map<String, dynamic>)['price'] ?? '0') ?? 0;
                      return priceA.compareTo(priceB);
                    });
                    return true;
                  case 'Prix décroissant':
                    vehicles.sort((a, b) {
                      final priceA = double.tryParse((a.data() as Map<String, dynamic>)['price'] ?? '0') ?? 0;
                      final priceB = double.tryParse((b.data() as Map<String, dynamic>)['price'] ?? '0') ?? 0;
                      return priceB.compareTo(priceA);
                    });
                    return true;
                  default:
                    return true;
                }
              }).toList();

              if (vehicles.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Aucun véhicule trouvé',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(12.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.05,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final vehicle = vehicles[index].data() as Map<String, dynamic>;
                      final vehicleId = vehicles[index].id;
                      final isReserved = vehicle['isReserved'] ?? false;

                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            // En-tête avec image et statut
                            Container(
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                              ),
                              child: Stack(
                                children: [
                                  const Center(
                                    child: Icon(
                                      Icons.directions_car,
                                      size: 30,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isReserved ? Colors.orange : Colors.green,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        isReserved ? 'Réservé' : 'Disponible',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Contenu
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Modèle
                                    Text(
                                      vehicle['model'] ?? 'Modèle inconnu',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 1),
                                    // Prix
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.attach_money,
                                          size: 9,
                                          color: Colors.green,
                                        ),
                                        const SizedBox(width: 1),
                                        Text(
                                          '${vehicle['price']} MAD/jour',
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 1),
                                    // Localisation
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 9,
                                          color: Colors.blue.shade700,
                                        ),
                                        const SizedBox(width: 1),
                                        Expanded(
                                          child: Text(
                                            '${vehicle['latitude']?.toStringAsFixed(2)}, ${vehicle['longitude']?.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: Colors.blue.shade700,
                                              fontSize: 7,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    // Boutons d'action
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 1),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _buildActionButton(
                                            icon: Icons.edit,
                                            color: Colors.blue,
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => AddVehicleScreen(
                                                    vehicleId: vehicleId,
                                                    initialModel: vehicle['model'],
                                                    initialPrice: vehicle['price'],
                                                    initialPosition: LatLng(
                                                      vehicle['latitude'] ?? 0,
                                                      vehicle['longitude'] ?? 0,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          _buildActionButton(
                                            icon: Icons.delete,
                                            color: Colors.red,
                                            onPressed: () => _showDeleteConfirmation(context, vehicleId),
                                          ),
                                          _buildActionButton(
                                            icon: isReserved ? Icons.cancel : Icons.check_circle,
                                            color: isReserved ? Colors.orange : Colors.green,
                                            onPressed: () => _toggleReservation(context, vehicleId, isReserved),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: vehicles.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddVehicleScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, size: 12),
      onPressed: onPressed,
      color: color,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 16,
        minHeight: 16,
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, String vehicleId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Voulez-vous vraiment supprimer ce véhicule ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('vehicles')
            .doc(vehicleId)
            .delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Véhicule supprimé avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _toggleReservation(BuildContext context, String vehicleId, bool isReserved) async {
    try {
      await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(vehicleId)
          .update({'isReserved': !isReserved});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isReserved ? 'Réservation annulée' : 'Véhicule réservé avec succès'),
            backgroundColor: isReserved ? Colors.orange : Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}