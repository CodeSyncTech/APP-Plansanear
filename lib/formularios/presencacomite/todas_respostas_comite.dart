import 'package:Redeplansanea/formularios/presenca/lista_presenca.dart';
import 'package:Redeplansanea/formularios/presencacomite/lista_presenca_comite.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminScreenComite extends StatefulWidget {
  const AdminScreenComite({super.key});

  @override
  _AdminScreenComiteState createState() => _AdminScreenComiteState();
}

class _AdminScreenComiteState extends State<AdminScreenComite> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

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
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  // Conteúdo centralizado
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
                                'assets/logo_plan.png',
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
                              'Gestão de Formulários',
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              'Comitê',
                              style: GoogleFonts.roboto(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Botão de adicionar estilizado
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled:
                            true, // Permite que o modal ocupe mais espaço
                        backgroundColor: Colors.transparent,
                        builder: (context) =>
                            const CriarFormularioScreenComite(),
                      );
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      foregroundColor: Colors.white,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                      elevation: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE6F3FF), Color(0xFFC4E0FF)],
          ),
        ),
        child: Column(
          children: [
            // Campo de busca (fora do AppBar)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: "Buscar por cidade, estado...",
                  prefixIcon: const Icon(Icons.search, color: Colors.blue),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('formulariosComite')
                    .orderBy('dataCriacao',
                        descending:
                            true) // ORDENANDO DO MAIS RECENTE PARA O MAIS ANTIGO
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF003399)),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.assignment_add,
                      message: "Nenhum formulário criado ainda",
                    );
                  }

                  var formularios = snapshot.data!.docs;

                  // Filtragem da lista com base na busca
                  var filteredFormularios = formularios.where((form) {
                    var formData = form.data() as Map<String, dynamic>;
                    String cidade =
                        '${formData['municipio'] ?? ""} - ${formData['estado'] ?? ""}';
                    return cidade.toLowerCase().contains(searchQuery);
                  }).toList();

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredFormularios.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      var form = filteredFormularios[index].data()
                          as Map<String, dynamic>;
                      final municipio =
                          '${form['municipio'] ?? "Sem Localização"} - ${form['estado'] ?? "Sem Localização"}';

                      final Future<int> quantidadeFuture = FirebaseFirestore
                          .instance
                          .collection('respostasComite')
                          .where('idFormulario',
                              isEqualTo: filteredFormularios[index].id)
                          .get()
                          .then((snapshot) => snapshot.docs.length);

                      return FutureBuilder<int>(
                        future: quantidadeFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                              ),
                            );
                          }
                          if (snapshot.hasError) {
                            return const Text('Erro ao carregar quantidade');
                          }
                          final int quantidade = snapshot.data ?? 0;

                          return _FormularioCard(
                            cidade: municipio,
                            quantidade: "Respostas: ${quantidade.toString()}",
                            dataCriacao:
                                form['dataCriacao'] ?? "Data desconhecida",
                            onCopy: () => _copiarLink(
                                context, filteredFormularios[index].id),
                            onDelete: () => _confirmarExclusao(
                                context, filteredFormularios[index].id),
                            onTap: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      RespostasScreen(
                                    idFormulario: filteredFormularios[index].id,
                                    municipio: municipio,
                                  ),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    const curve = Curves.easeInOut;
                                    var fadeAnimation = CurvedAnimation(
                                      parent: animation,
                                      curve: curve,
                                    );
                                    return FadeTransition(
                                      opacity: fadeAnimation,
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copiarLink(BuildContext context, String idFormulario) {
    const baseUrl = 'https://plansanear.com.br/redeplansanea/v2/#';
    final linkCompleto = '$baseUrl/$idFormulario';

    Clipboard.setData(ClipboardData(text: linkCompleto)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Link copiado para a área de transferência!'),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  void _confirmarExclusao(BuildContext context, String idFormulario) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmar Exclusão"),
        content: const Text("Tem certeza que deseja excluir este formulário?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('formulariosComite')
                  .doc(idFormulario)
                  .delete();
              Navigator.pop(ctx);
            },
            child: const Text("Excluir", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _FormularioCard extends StatelessWidget {
  final String cidade;
  final String quantidade;
  final String dataCriacao;
  final VoidCallback onTap;
  final VoidCallback onCopy;
  final VoidCallback onDelete;

  const _FormularioCard({
    required this.cidade,
    required this.quantidade,
    required this.dataCriacao,
    required this.onTap,
    required this.onCopy,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cidade,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF003399),
                          ),
                        ),
                        Text(
                          quantidade,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: onDelete,
                        tooltip: 'Excluir formulário',
                      ),
                      IconButton(
                        icon: Icon(Icons.link, color: Colors.blue.shade700),
                        onPressed: onCopy,
                        tooltip: 'Copiar link do formulário',
                      ),
                      const Icon(Icons.chevron_right, color: Colors.blue),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    dataCriacao,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Mantenha as outras classes (RespostasScreen, _RespostaCard, _InfoRow, EmptyStateWidget)
// com as alterações anteriores, atualizando apenas os detalhes de estilo conforme necessário

class RespostasScreen extends StatelessWidget {
  final String idFormulario;
  final String municipio;

  const RespostasScreen({
    super.key,
    required this.idFormulario,
    required this.municipio,
  });

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
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Centralização principal
                children: [
                  // Logo centralizado
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
                          'assets/logo_plan.png',
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 20),

                  // Título centralizado verticalmente
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Respostas - Comitê',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          municipio,
                          style: GoogleFonts.roboto(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('respostasComite')
              .where('idFormulario', isEqualTo: idFormulario)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.assignment_ind,
                message: "Nenhuma resposta encontrada",
              );
            }

            var respostas = snapshot.data!.docs;

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: respostas.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                var resposta = respostas[index].data() as Map<String, dynamic>;
                String idResposta = respostas[index]
                    .id; // Obtendo corretamente a ID da resposta

                return _RespostaCard(
                  resposta: resposta,
                  idResposta: idResposta, // Agora passando a ID correta
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// Ajustando _RespostaCard para incluir a exclusão de respostas
class _RespostaCard extends StatelessWidget {
  final Map<String, dynamic> resposta;
  final String idResposta;

  const _RespostaCard({required this.resposta, required this.idResposta});

  void _confirmarExclusao(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmar Exclusão"),
        content: const Text("Tem certeza que deseja excluir esta resposta?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('respostasComite')
                  .doc(idResposta)
                  .delete();
              Navigator.pop(ctx);
            },
            child: const Text("Excluir", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, size: 18, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: SelectableText(
                    resposta['nomeCompleto'] ?? "Anônimo",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmarExclusao(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.phone,
              text: resposta['telefone'] ?? 'Não informado',
            ),
            _InfoRow(
              icon: Icons.work,
              text: resposta['vinculo'] ?? 'Não informado',
            ),
            _InfoRow(
              icon: Icons.group,
              text: resposta['comite'] ?? 'Não informado',
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.blue),
                  const SizedBox(width: 4),
                  SelectableText(
                    "${resposta['dataResposta']} às ${resposta['horaResposta']}",
                    style: const TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text, style: TextStyle(color: Colors.grey.shade800))),
        ],
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String message;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.blue.shade300),
          const SizedBox(height: 16),
          Text(message,
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
