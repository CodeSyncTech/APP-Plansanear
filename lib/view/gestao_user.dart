import 'package:Redeplansanea/produtos/produto_a/views/formacao_comite_form.dart';
import 'package:Redeplansanea/view/painelAdmin/ProdutoA/padmin_formacaocomite.dart';
import 'package:Redeplansanea/view/painelAdmin/ProdutoA/padmin_infomunicipio.dart';
import 'package:Redeplansanea/view/painelAdmin/ProdutoA/padmin_organizacaosocial.dart';
import 'package:Redeplansanea/view/painelAdmin/ProdutoA/padmin_setores.dart';
import 'package:Redeplansanea/view/painelAdmin/ProdutoB/padmin_caracterizacaomunicipio.dart';
import 'package:Redeplansanea/view/painelAdmin/ProdutoB/padmin_estruturapubmunicipal.dart';
import 'package:Redeplansanea/view/painelAdmin/ProdutoB/padmin_populacoestradicionais.dart';
import 'package:Redeplansanea/view/painelAdmin/ProdutoB/padmin_programacampanhaeacoes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../view/auth_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({Key? key}) : super(key: key);

  @override
  _AdminPanelScreenState createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: AppBar(
          elevation: 2,
          shadowColor: Colors.blue.shade100,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF00B3CC),
                  Color(0xFF004466),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Image.asset(
                                'assets/logoredeplanrmbg.png',
                                height: 50,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        // Título
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gestão de',
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Usuários',
                              style: GoogleFonts.roboto(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: const Color.fromARGB(255, 230, 242, 255),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 158, 226, 235),
              Color.fromARGB(255, 63, 125, 156),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 30),
              // Cabeçalho e botão para criar nova conta
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AdminCreateAccountScreen(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueGrey.withOpacity(0.1),
                          spreadRadius: 3,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [Colors.blue[800]!, Colors.blue[600]!],
                            stops: [0, 0.8],
                          ).createShader(bounds),
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .snapshots(),
                            builder: (context, snapshot) {
                              String text = 'Criar nova conta';
                              if (snapshot.hasData) {
                                final count = snapshot.data!.docs.length;
                                text = 'Criar nova conta ($count)';
                              }
                              return Text(
                                text,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Poppins',
                                  letterSpacing: 0.8,
                                ),
                              );
                            },
                          ),
                        ),
                        Icon(
                          Icons.person_add,
                          color: Colors.blue[800],
                          size: 28,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Campo de busca
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
              // Lista de usuários
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
          ),
        ),
      ),
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
}

// RELATORIO DE RESUMO DE RESPOSTAS DO USUARIO

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
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
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
                      leading: Icon(Icons.group_add, color: Colors.blue[800]),
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
                          Icon(Icons.location_city, color: Colors.blue[800]),
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
                      leading: Icon(Icons.group_work, color: Colors.blue[800]),
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
                      leading: Icon(Icons.view_module, color: Colors.blue[800]),
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
                    ),
                  ],
                ),
                // Produto B com opções agrupadas
                ExpansionTile(
                  leading: Icon(Icons.folder, color: Colors.blue[800]),
                  title: const Text('Produto B'),
                  childrenPadding: const EdgeInsets.only(left: 32.0),
                  children: [
                    ListTile(
                      leading:
                          Icon(Icons.account_balance, color: Colors.blue[800]),
                      title: const Text('Estrutura Pública Municipal'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                VisualizacaoEstruturapubMunicipal(
                                    userId: docId),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.campaign, color: Colors.blue[800]),
                      title: const Text('Programas, Campanhas e Ações'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                VisualizacaoProgramaCampanha(userId: docId),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.map, color: Colors.blue[800]),
                      title: const Text('Caracterização do Município'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                VisualizacaoCaracterizacaoMunicipio(
                                    userId: docId),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading:
                          Icon(Icons.nature_people, color: Colors.blue[800]),
                      title: const Text('Populações Tradicionais'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                VisualizacaoPopulacoesTradicionais(
                                    userId: docId),
                          ),
                        );
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

  Widget _buildUserDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
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
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
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
