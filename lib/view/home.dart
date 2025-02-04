import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../view/auth_screen.dart';

class HomeScreen extends StatefulWidget {
  final User? user;

  const HomeScreen(this.user, {super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? _accountLevel;
  @override
  void initState() {
    super.initState();
    _fetchUserAccountLevel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF00B3CC), // Azul ciano mais claro
            Color(0xFF004466), // Azul profundo mais escuro
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: _accountLevel == null
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(context),
    );
  }

  Future<void> _fetchUserAccountLevel() async {
    if (widget.user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user!.uid)
        .get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      setState(() {
        _accountLevel = data['nivelConta'] ?? 2;
      });
    }
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildUserHeader(),
          const SizedBox(height: 30),
          _buildAuthInfo(),
          const SizedBox(height: 25),
          _buildProfileInfo(),
          if (_accountLevel == 1) _buildAdminPanel(),
          const SizedBox(height: 30),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildAdminPanel() {
    return Column(
      children: [
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Painel Administrativo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            IconButton(
              icon: const Icon(Icons.add_circle,
                  color: Color.fromARGB(255, 0, 0, 0)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AdminCreateAccountScreen()),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const _ErrorInfo(message: 'Erro ao carregar usuários');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var userDoc = snapshot.data!.docs[index];
                var userData = userDoc.data() as Map<String, dynamic>;

                return _UserListItem(
                  userData: userData,
                  docId: userDoc.id,
                  onEdit: () => _showEditUserDialog(userDoc),
                  onDelete: () => _confirmDeleteUser(userDoc.id),
                );
              },
            );
          },
        ),
      ],
    );
  }

  void _showEditUserDialog(DocumentSnapshot userDoc) {
    // Obtenha os dados atuais do usuário
    var userData = userDoc.data() as Map<String, dynamic>;

    // Crie TextEditingControllers para cada campo que deseja editar
    TextEditingController nameController =
        TextEditingController(text: userData['name']);
    TextEditingController emailController =
        TextEditingController(text: userData['email']);
    TextEditingController telController =
        TextEditingController(text: userData['tel']);
    TextEditingController municipioController =
        TextEditingController(text: userData['municipio']);
    TextEditingController estadoController =
        TextEditingController(text: userData['estado']);
    TextEditingController cargoController =
        TextEditingController(text: userData['cargo']);
    TextEditingController cpfController =
        TextEditingController(text: userData['cpf']);
    TextEditingController nivelContaController = TextEditingController(
        text: userData['nivelConta'] != null
            ? userData['nivelConta'].toString()
            : '2');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Usuário'),
        content: SingleChildScrollView(
          child: Column(children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'E-mail'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: telController,
              decoration: const InputDecoration(labelText: 'Telefone'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: municipioController,
              decoration: const InputDecoration(labelText: 'Município'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: municipioController,
              decoration: const InputDecoration(labelText: 'Estado'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: cargoController,
              decoration: const InputDecoration(labelText: 'Cargo'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: cpfController,
              decoration: const InputDecoration(labelText: 'CPF'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nivelContaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Nível da Conta'),
            ),
          ]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await userDoc.reference.update({
                'name': nameController.text,
                'email': emailController.text,
                'tel': telController.text,
                'municipio': municipioController.text,
                'estado': estadoController.text,
                'cargo': cargoController.text,
                'cpf': cpfController.text,

                // Se nível de conta for int, converta antes de salvar
                'nivelConta': int.tryParse(nivelContaController.text) ?? 2,
              });
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteUser(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza que deseja excluir este usuário?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(docId)
                  .delete();
              Navigator.pop(context);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    if (widget.user == null) {
      return const Text("Usuário não disponível");
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user?.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return _ErrorInfo(
                message: "Erro ao carregar dados: ${snapshot.error}");
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const _ErrorInfo(
                message: "Dados do usuário não encontrados");
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          _accountLevel = userData['nivelConta'] ?? 2;

          return _InfoCard(
            title: 'Dados Pessoais',
            children: [
              UserInfoItem(
                icon: Icons.person,
                label: 'Nome:',
                value: userData['name'] ?? 'Não informado',
              ),
              UserInfoItem(
                icon: Icons.work,
                label: 'Cargo:',
                value: userData['cargo'] ?? 'Não informado',
              ),
              UserInfoItem(
                icon: Icons.badge,
                label: 'CPF:',
                value: userData['cpf'] ?? 'Não informado',
              ),
              UserInfoItem(
                icon: Icons.location_city,
                label: 'Município:',
                value: userData['municipio'] ?? 'Não informado',
              ),
              UserInfoItem(
                icon: Icons.location_city,
                label: 'Estado:',
                value: userData['estado'] ?? 'Não informado',
              ),
              UserInfoItem(
                icon: Icons.phone,
                label: 'Telefone:',
                value: userData['tel'] ?? 'Não informado',
              ),
              UserInfoItem(
                icon: Icons.security,
                label: 'Nível da Conta:',
                value: userData['nivelConta'].toString(),
              ),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildUserHeader() {
    return CircleAvatar(
      radius: 50,
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      child: Icon(
        Icons.person,
        size: 50,
        color: const Color.fromARGB(255, 106, 106, 106),
      ),
    );
  }

  Widget _buildAuthInfo() {
    final user = FirebaseAuth.instance.currentUser;
    return _InfoCard(
      title: 'Informações de Conta',
      children: [
        UserInfoItem(
          icon: Icons.fingerprint,
          label: 'UID:',
          value: user?.uid ?? 'Não disponível',
        ),
        UserInfoItem(
          icon: Icons.email,
          label: 'E-mail:',
          value: user?.email ?? 'Não cadastrado',
        ),
      ],
    );
  }

  Widget _InfoCard({required String title, required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 70),
      child: ElevatedButton(
        onPressed: () => _confirmLogout(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text('SAIR DA CONTA'),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmação de Saída'),
        content: const Text('Tem certeza que deseja desconectar da conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const AuthScreen()),
              );
            },
            child: const Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Mantenha os widgets _InfoCard, UserInfoItem e _ErrorInfo do código anterior

class _InfoCard extends StatefulWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({required this.title, required this.children});

  @override
  State<_InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<_InfoCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
            ),
            const Divider(height: 30),
            ...widget.children,
          ],
        ),
      ),
    );
  }
}

class UserInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const UserInfoItem({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 15),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  TextSpan(
                    text: '$label ',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorInfo extends StatelessWidget {
  final String message;

  const _ErrorInfo({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade800),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.red.shade800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserListItem extends StatelessWidget {
  final Map<String, dynamic> userData;
  final String docId;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _UserListItem({
    required this.userData,
    required this.docId,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(userData['name'] ?? 'Sem nome'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${userData['email'] ?? 'Não informado'}'),
            Text('Cargo: ${userData['cargo'] ?? 'Não informado'}'),
            Text('Nível: ${userData['nivelConta'] ?? 2}'),
            Text('Municipio: ${userData['municipio'] ?? 'Não informado'}'),
            Text('Estado: ${userData['estado'] ?? 'Não informado'}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
