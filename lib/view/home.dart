import 'package:Redeplansanea/produtos/produto_a/views/formacao_comite_form.dart';
import 'package:Redeplansanea/view/painelAdmin/ProdutoA/padmin_formacaocomite.dart';
import 'package:Redeplansanea/view/painelAdmin/ProdutoA/padmin_infomunicipio.dart';
import 'package:Redeplansanea/view/painelAdmin/ProdutoA/padmin_organizacaosocial.dart';
import 'package:Redeplansanea/view/painelAdmin/ProdutoA/padmin_setores.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../view/auth_screen.dart';

class HomeScreen extends StatefulWidget {
  final User? user;

  const HomeScreen(this.user, {super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? _accountLevel;

  User? get _currentUser => FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;

  Future<void> _loadUserData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser?.uid)
        .get();

    setState(() {
      userData = doc.data() as Map<String, dynamic>?;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
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
          if (_accountLevel == 1 || _accountLevel == 0)
            buildAdminPanel(context),
          const SizedBox(height: 30),
          SizedBox(height: 20),
          Container(
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromARGB(138, 255, 255, 255),
            ),
            child: Image.asset(
              'assets/barradelogo.png',
            ),
          ),
          const SizedBox(height: 30),
          _buildLogoutButton(context),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget buildAdminPanel(BuildContext context) {
    TextEditingController _searchController = TextEditingController();
    String _searchQuery = "";

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Gestão de Usuários',
                    style: const TextStyle(
                      fontSize: 22,
                      color: Color(0xFFD2E48E),
                      shadows: [
                        Shadow(
                          color: Color(0xFF004466),
                          offset: Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.person_add_alt_1, // Novo ícone de usuário
                      color: Color(0xFFD2E48E),
                      size: 28,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminCreateAccountScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Buscar usuário',
                    labelStyle: TextStyle(color: Colors.grey[700]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[700]),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.blueAccent, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Erro ao carregar usuários');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                var filteredUsers = snapshot.data!.docs.where((doc) {
                  var userData = doc.data() as Map<String, dynamic>;
                  var userName = userData['name']?.toLowerCase() ?? '';
                  return userName.contains(_searchQuery);
                }).toList();

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    var userDoc = filteredUsers[index];
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
      },
    );
  }

  void _showEditUserDialog(DocumentSnapshot userDoc) {
    // Obtenha os dados atuais do usuário
    var userData = userDoc.data() as Map<String, dynamic>;
    final colorScheme = Theme.of(context).colorScheme;

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
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 10,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Editar Perfil',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: nameController,
                  label: 'Nome Completo',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  controller: emailController,
                  label: 'E-mail',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  controller: telController,
                  label: 'Telefone',
                  icon: Icons.phone_iphone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  controller: municipioController,
                  label: 'Município',
                  icon: Icons.location_city_outlined,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  controller: estadoController,
                  label: 'Estado',
                  icon: Icons.flag_outlined,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  controller: cargoController,
                  label: 'Cargo',
                  icon: Icons.work_outline,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  controller: cpfController,
                  label: 'CPF',
                  icon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  controller: nivelContaController,
                  label: 'Nível da Conta',
                  icon: Icons.security_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          // Mantenha a mesma lógica de salvamento
                          await userDoc.reference.update({
                            'name': nameController.text,
                            'email': emailController.text,
                            'tel': telController.text,
                            'municipio': municipioController.text,
                            'estado': estadoController.text,
                            'cargo': cargoController.text,
                            'cpf': cpfController.text,
                            'nivelConta': int.parse(nivelContaController.text),
                            // ... outros campos
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Salvar Alterações',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 15),
      ),
    );
  }

  void _confirmDeleteUser(String docId) {
    if (userData?['nivelConta'] == 1) {
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Apenas administradores podem excluir formulários.'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
    return GestureDetector(
      onTap: () => _showUserOptions(
          context, docId), // Adicionado evento de clique no card
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 1),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          Theme.of(context).primaryColor.withOpacity(0.2),
                      child: Icon(Icons.person,
                          color: Theme.of(context).primaryColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        userData['name'] ?? 'Sem nome',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    _buildActionButtons(),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDivider(),
                const SizedBox(height: 8),
                _buildUserDetailItem(
                  icon: Icons.email,
                  label: 'Email:',
                  value: userData['email'] ?? 'Não informado',
                ),
                _buildUserDetailItem(
                  icon: Icons.work,
                  label: 'Cargo:',
                  value: userData['cargo'] ?? 'Não informado',
                ),
                _buildUserDetailItem(
                  icon: Icons.stacked_line_chart,
                  label: 'Nível:',
                  value: userData['nivelConta']?.toString() ?? '2',
                ),
                _buildUserDetailItem(
                  icon: Icons.location_city,
                  label: 'Município:',
                  value: userData['municipio'] ?? 'Não informado',
                ),
                _buildUserDetailItem(
                  icon: Icons.place,
                  label: 'Estado:',
                  value: userData['estado'] ?? 'Não informado',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.withOpacity(0.2),
    );
  }

  void _showUserOptions(BuildContext context, String docId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Produto A com opções agrupadas
                ExpansionTile(
                  leading: Icon(Icons.folder, color: Colors.blue[800]),
                  title: const Text('Produto A'),
                  childrenPadding: const EdgeInsets.only(left: 32.0),
                  children: [
                    ListTile(
                      leading: Icon(Icons.group, color: Colors.blue[800]),
                      title: const Text('Formação Comitê'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FormacaoComiteInfoScreen(userId: docId),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading:
                          Icon(Icons.info_outline, color: Colors.green[800]),
                      title: const Text('Informações sobre o Município'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                InformacoesMunicipioScreen(userId: docId),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading:
                          Icon(Icons.social_distance, color: Colors.blue[800]),
                      title: const Text('Organização Social'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                VisualizacaoOrganizacaoMunicipioScreen(
                                    userId: docId),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading:
                          Icon(Icons.folder_special, color: Colors.blue[800]),
                      title: const Text('Setores'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ListaSetoresScreen(userId: docId),
                          ),
                        );
                      },
                    )
                  ],
                ),
                // Produto B com opções agrupadas
                ExpansionTile(
                  leading: Icon(Icons.folder, color: Colors.blue[800]),
                  title: const Text('Produto B'),
                  childrenPadding: const EdgeInsets.only(left: 32.0),
                  children: [
                    ListTile(
                      leading: Icon(Icons.group, color: Colors.blue[800]),
                      title: const Text('Opção X'),
                      onTap: () {
                        Navigator.pop(context);
                        // Adicione aqui a navegação para a tela de Opção X do Produto B
                      },
                    ),
                    ListTile(
                      leading:
                          Icon(Icons.info_outline, color: Colors.green[800]),
                      title: const Text('Opção Y'),
                      onTap: () {
                        Navigator.pop(context);
                        // Adicione aqui a navegação para a tela de Opção Y do Produto B
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserDetailItem(
      {required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.blue[800]),
            onPressed: onEdit,
            splashRadius: 20,
          ),
          Container(
            height: 24,
            width: 1,
            color: Colors.grey.withOpacity(0.3),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red[800]),
            onPressed: onDelete,
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}
