import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../view/auth_screen.dart';

class HomeScreen extends StatelessWidget {
  final User? user;

  const HomeScreen(this.user, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bem-vindo(a)"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "UID: ${user?.uid ?? 'Não disponível'}",
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                "Email: ${user?.email ?? 'Não disponível'}",
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              user == null
                  ? const Text("Usuário não disponível")
                  : FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(user?.uid)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasData && snapshot.data!.exists) {
                            var userData =
                                snapshot.data!.data() as Map<String, dynamic>;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Nome: ${userData['name'] ?? 'Não disponível'}",
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "cargo: ${userData['cargo'] ?? 'Não disponível'}",
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "cpf: ${userData['cpf'] ?? 'Não disponível'}",
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "municipio: ${userData['municipio'] ?? 'Não disponível'}",
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Telefone: ${userData['tel'] ?? 'Não disponível'}",
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            );
                          } else {
                            return const Text(
                                "Dados do usuário não encontrados.");
                          }
                        } else if (snapshot.hasError) {
                          return Text("Erro: ${snapshot.error}");
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) => const AuthScreen()),
                        );
                      },
                      child: const Text("Sair")),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
