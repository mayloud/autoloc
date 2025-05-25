import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agence de Location',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

// Page d'accueil
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Accueil')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('Connexion'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
              ),
            ),
            ElevatedButton(
              child: Text('Inscription'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RegisterPage()),
              ),
            ),
            ElevatedButton(
              child: Text('Voir les véhicules sur la carte'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CarMapPage()),
              ),
            ),
            ElevatedButton(
              child: Text('Liste des véhicules'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CarListPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Page de connexion
class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Se connecter'),
            ),
          ],
        ),
      ),
    );
  }
}

// Page d'inscription
class RegisterPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inscription')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nom complet'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('S\'inscrire'),
            ),
          ],
        ),
      ),
    );
  }
}

// Page de carte avec OpenStreetMap
class CarMapPage extends StatelessWidget {
  final List<Map<String, dynamic>> vehicles = [
    {
      'model': 'Toyota Corolla',
      'position': LatLng(34.020882, -6.841650),
    },
    {
      'model': 'Honda Civic',
      'position': LatLng(34.022000, -6.850000),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Carte des véhicules')),
      body: FlutterMap(
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
    );
  }
}

// Liste des véhicules
class CarListPage extends StatelessWidget {
  final List<Map<String, String>> vehicles = [
    {'model': 'Toyota Corolla', 'price': '300 MAD/jour'},
    {'model': 'Honda Civic', 'price': '350 MAD/jour'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Véhicules disponibles')),
      body: ListView.builder(
        itemCount: vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = vehicles[index];
          return ListTile(
            leading: Icon(Icons.directions_car),
            title: Text(vehicle['model']!),
            subtitle: Text(vehicle['price']!),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => VehicleDetailsPage(vehicle: vehicle)),
              );
            },
          );
        },
      ),
    );
  }
}

// Détail d'un véhicule
class VehicleDetailsPage extends StatelessWidget {
  final Map<String, String> vehicle;

  VehicleDetailsPage({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(vehicle['model']!)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Modèle : ${vehicle['model']}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Prix : ${vehicle['price']}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 24),
            ElevatedButton(
              child: Text('Réserver'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Réservation effectuée pour ${vehicle['model']}')), 
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
