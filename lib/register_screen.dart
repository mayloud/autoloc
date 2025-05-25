import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Prompt: Import Firebase Auth

class RegisterScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inscription")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Créer un compte',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nom complet',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  if (emailController.text.trim().isEmpty ||
                      passwordController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Veuillez remplir tous les champs')),
                    );
                    return;
                  }

                  try {
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: emailController.text.trim(),
                      password: passwordController.text.trim(),
                    );

                    if (!context.mounted) {
                      return; // Vérifie si le widget est toujours monté
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Compte créé avec succès')),
                    );
                    Navigator.pop(context);
                  } on FirebaseAuthException catch (e) {
                    String errorMessage;
                    switch (e.code) {
                      case 'email-already-in-use':
                        errorMessage = 'Cet email est déjà utilisé.';
                        break;
                      case 'invalid-email':
                        errorMessage = 'Email invalide.';
                        break;
                      case 'weak-password':
                        errorMessage = 'Le mot de passe est trop faible.';
                        break;
                      default:
                        errorMessage = 'Erreur : ${e.message}';
                    }

                    if (!context.mounted) {
                      return; // Vérifie si le widget est toujours monté
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(errorMessage)),
                    );
                  } catch (e) {
                    if (!context.mounted) {
                      return; // Vérifie si le widget est toujours monté
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur inconnue : $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text("S'inscrire"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
