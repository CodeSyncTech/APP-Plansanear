import 'package:Redeplansanea/formularios/votacao/lista_votacao.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AdminScreenVotacao extends StatefulWidget {
  const AdminScreenVotacao({super.key});

  @override
  _AdminScreenVotacaoState createState() => _AdminScreenVotacaoState();
}

class _AdminScreenVotacaoState extends State<AdminScreenVotacao> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";
  User? get _currentUser => FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    // Carrega os dados do usuário
    _loadUserData();
  }

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
                              'Sistema de ',
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              'Votação',
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
                            const CriarFormularioScreenVotacao(),
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
                    .collection('formulariosVotacao')
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
                          .collection('respostasVotacao')
                          .doc(filteredFormularios[index].id)
                          .get()
                          .then((docSnapshot) {
                        if (docSnapshot.exists) {
                          final data =
                              docSnapshot.data() as Map<String, dynamic>;
                          final respostas =
                              data['respostas'] as List<dynamic>? ?? [];
                          return respostas.length;
                        }
                        return 0;
                      });

                      return FutureBuilder<int>(
                        future: quantidadeFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child:
                                  CircularProgressIndicator(strokeWidth: 2.0),
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
                            onCopy: () =>
                                _GotoVotacao(filteredFormularios[index].id),
                            onDelete: () => _confirmarExclusao(
                                context, filteredFormularios[index].id),
                            onConfigure: () {
                              // Exibe o popup de configuração
                              showDialog(
                                context: context,
                                builder: (context) => ConfiguracaoVotacaoPopup(
                                  idFormulario: filteredFormularios[index].id,
                                ),
                              );
                            },
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
                                        parent: animation, curve: curve);
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
    const baseUrl = 'https://plansanear.com.br/redeplansanea/v10/#/Votacao';
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

  void _GotoVotacao(String idFormulario) {
    GoRouter.of(context).go('/votacao/$idFormulario');
  }

  void _confirmarExclusao(BuildContext context, String idFormulario) {
    if (userData?['nivelConta'] == 1) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Confirmar Exclusão"),
          content:
              const Text("Tem certeza que deseja excluir este formulário?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('formulariosVotacao')
                    .doc(idFormulario)
                    .delete();
                Navigator.pop(ctx);
              },
              child: const Text("Excluir", style: TextStyle(color: Colors.red)),
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

class _FormularioCard extends StatelessWidget {
  final String cidade;
  final String quantidade;
  final String dataCriacao;
  final VoidCallback onTap;
  final VoidCallback onCopy;
  final VoidCallback onDelete;
  final VoidCallback onConfigure;

  const _FormularioCard({
    required this.cidade,
    required this.quantidade,
    required this.dataCriacao,
    required this.onTap,
    required this.onCopy,
    required this.onDelete,
    required this.onConfigure,
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
                  // Informações do formulário (cidade, quantidade de respostas)
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
                  // Botões de ação
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: onDelete,
                        tooltip: 'Excluir formulário',
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.orange),
                        onPressed: onConfigure,
                        tooltip: 'Configurar votação',
                      ),
                      IconButton(
                        icon: Icon(Icons.how_to_reg_outlined,
                            color: const Color.fromARGB(255, 0, 132, 7)),
                        onPressed: onCopy,
                        tooltip: 'Ir para votação',
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
            decoration: const BoxDecoration(color: Colors.white),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
                          'assets/logoredeplanrmbg.png',
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  // Título centralizado
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Respostas - Votação',
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
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('respostasVotacao')
              .doc(idFormulario)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const EmptyStateWidget(
                icon: Icons.assignment_ind,
                message: "Nenhuma resposta encontrada",
              );
            }
            final data = snapshot.data!.data() as Map<String, dynamic>;
            final respostas = data['respostas'] as List<dynamic>? ?? [];

            // Calcula a contagem para cada opção
            Map<String, int> resumoVotos = {};
            for (var resposta in respostas) {
              if (resposta is Map<String, dynamic>) {
                final String opcao = resposta['voto']?.toString() ?? 'N/A';
                resumoVotos[opcao] = (resumoVotos[opcao] ?? 0) + 1;
              }
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount:
                  respostas.length + 2, // +2 para o header (chips e divider)
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return FutureBuilder<int>(
                    future: FirebaseFirestore.instance
                        .collection('formulariosVotacao')
                        .doc(idFormulario)
                        .get()
                        .then((doc) {
                      if (doc.exists) {
                        final data = doc.data() as Map<String, dynamic>;
                        return data['totalVotos'] as int? ?? 0;
                      }
                      return 0;
                    }),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      int configuredTotalVotes = snapshot.data ?? 0;
                      return VoteSummaryWidget(
                        summary: resumoVotos,
                        totalVotos: configuredTotalVotes,
                      );
                    },
                  );
                } else if (index == 1) {
                  return Row(
                    children: [
                      const SizedBox(height: 40),
                      Expanded(
                        child: Divider(
                          thickness: 2,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Detalhamento de votos",
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Divider(
                          thickness: 2,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  );
                } else {
                  final int respostaIndex = index - 2;
                  final resposta =
                      respostas[respostaIndex] as Map<String, dynamic>;
                  return _RespostaCard(
                    resposta: resposta,
                    index: respostaIndex,
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}

/// Widget para exibir o resumo dos votos
class VoteSummaryWidget extends StatelessWidget {
  final Map<String, int> summary;
  final int totalVotos;

  const VoteSummaryWidget(
      {Key? key, required this.summary, required this.totalVotos})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (summary.isEmpty) return const SizedBox();

    final sortedEntries = summary.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Soma todos os votos contabilizados para exibição (pode ser menor que totalVotos)
    int votosContabilizados = summary.values.fold(0, (a, b) => a + b);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12), // Rounded corners
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color.fromARGB(255, 0, 66, 164),
            const Color.fromARGB(255, 134, 163, 196),
            const Color.fromARGB(255, 134, 194, 255),
          ],
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(votosContabilizados),
            const SizedBox(height: 20),
            const SizedBox(height: 30),
            ..._buildRankingList(sortedEntries),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int votosContabilizados) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                const Color.fromARGB(255, 158, 118, 0),
                Colors.amber.shade300
              ],
            ).createShader(bounds),
            child: const Icon(Icons.emoji_events_rounded, size: 80),
          ),
          const SizedBox(height: 20),
          Text(
            'RESULTADO',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(2, 2),
                )
              ],
            ),
          ),
          Text(
            'Atualizado em ${DateFormat('HH:mm').format(DateTime.now())}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          // Exibe os votos contabilizados em relação ao total configurado
          Text(
            'Votos: $votosContabilizados/$totalVotos',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRankingList(List<MapEntry<String, int>> entries) {
    List<Widget> rankingWidgets = [];
    int rank = 1;

    for (int i = 0; i < entries.length; i++) {
      // Se não for o primeiro candidato e se a contagem de votos for igual ao anterior,
      // mantemos o mesmo rank; caso contrário, atualizamos o rank para i + 1.
      if (i > 0 && entries[i].value == entries[i - 1].value) {
        // Mesmo rank que o candidato anterior
      } else {
        rank = i + 1;
      }

      rankingWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: _buildCandidateCard(
            position: rank,
            name: entries[i].key,
            votes: entries[i].value,
          ),
        ),
      );
    }
    return rankingWidgets;
  }

  Widget _buildCandidateCard(
      {required int position, required String name, required int votes}) {
    final isTopThree = position <= 3;
    final positionColors = {
      1: Colors.amber,
      2: Colors.grey.shade400,
      3: const Color(0xFFCD7F32),
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          )
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isTopThree
                ? positionColors[position]!.withOpacity(0.1)
                : Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              position.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isTopThree
                    ? positionColors[position]
                    : Colors.blue.shade800,
              ),
            ),
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.blue.shade900,
          ),
        ),
        subtitle: Text(
          '$votes votos',
          style: TextStyle(
            fontSize: 16,
            color: Colors.blue.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          isTopThree
              ? Icons.workspace_premium_rounded
              : Icons.trending_up_rounded,
          color: isTopThree ? positionColors[position] : Colors.blue.shade300,
          size: 30,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class _RespostaCard extends StatelessWidget {
  final Map<String, dynamic> resposta;
  final int index;

  const _RespostaCard({required this.resposta, required this.index});

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
            Text(
              "Voto: ${resposta['voto'] ?? 'N/A'}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.blue),
                const SizedBox(width: 4),
                Text(
                  "${resposta['dataResposta']} às ${resposta['horaResposta']}",
                  style: const TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// userData será carregado assincronamente
Map<String, dynamic>? userData;

// Ajustando _RespostaCard para incluir a exclusão de respostas

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

class ConfiguracaoVotacaoPopup extends StatefulWidget {
  final String idFormulario;
  const ConfiguracaoVotacaoPopup({Key? key, required this.idFormulario})
      : super(key: key);

  @override
  _ConfiguracaoVotacaoPopupState createState() =>
      _ConfiguracaoVotacaoPopupState();
}

class _ConfiguracaoVotacaoPopupState extends State<ConfiguracaoVotacaoPopup> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _totalVotosController = TextEditingController();
  List<TextEditingController> _candidatosControllers = [];

  @override
  void initState() {
    super.initState();
    // Carrega os dados atuais do formulário para preencher os campos
    FirebaseFirestore.instance
        .collection('formulariosVotacao')
        .doc(widget.idFormulario)
        .get()
        .then((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _totalVotosController.text = data['totalVotos'].toString();
        List<dynamic> candidatos = data['candidatos'] ?? [];
        _candidatosControllers = candidatos
            .map((c) => TextEditingController(text: c.toString()))
            .toList();
        // Se não houver candidatos, adiciona um campo vazio
        if (_candidatosControllers.isEmpty) {
          _candidatosControllers.add(TextEditingController());
        }
        setState(() {}); // Atualiza a UI após carregar os dados
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _candidatosControllers) {
      controller.dispose();
    }
    _totalVotosController.dispose();
    super.dispose();
  }

  Future<void> _atualizarConfiguracao() async {
    if (_formKey.currentState!.validate()) {
      List<String> candidatos =
          _candidatosControllers.map((c) => c.text).toList();
      int totalVotos = int.tryParse(_totalVotosController.text) ?? 0;

      await FirebaseFirestore.instance
          .collection('formulariosVotacao')
          .doc(widget.idFormulario)
          .update({
        'candidatos': candidatos,
        'totalVotos': totalVotos,
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Configuração atualizada!")));
      Navigator.pop(context); // Fecha o popup
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Configurar Votação",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Quantidade Total de Votos:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _totalVotosController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: "Informe a quantidade total de votos",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Informe a quantidade total de votos";
                    }
                    if (int.tryParse(value) == null) {
                      return "Informe um número válido";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  "Candidatos:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _candidatosControllers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _candidatosControllers[index],
                              decoration: InputDecoration(
                                labelText: 'Candidato ${index + 1}',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Informe o nome do candidato";
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Permite remover o candidato, se houver mais de um
                          if (_candidatosControllers.length > 1)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _candidatosControllers.removeAt(index);
                                });
                              },
                            ),
                        ],
                      ),
                    );
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.blue),
                    onPressed: () {
                      setState(() {
                        _candidatosControllers.add(TextEditingController());
                      });
                    },
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _atualizarConfiguracao,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Atualizar Configuração",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
