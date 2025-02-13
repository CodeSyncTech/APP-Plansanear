import 'package:Redeplansanea/formularios/presenca/lista_presenca.dart';
import 'package:Redeplansanea/formularios/satisfacao/lista_presenca_satisfacao.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminScreenSatisfacao extends StatefulWidget {
  const AdminScreenSatisfacao({Key? key}) : super(key: key);

  @override
  _AdminScreenSatisfacaoState createState() => _AdminScreenSatisfacaoState();
}

class _AdminScreenSatisfacaoState extends State<AdminScreenSatisfacao> {
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
                              'Gestão de Formulários',
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              'Pesquisa de Satisfação',
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
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true, // Modal ocupa mais espaço
                        backgroundColor: Colors.transparent,
                        builder: (context) =>
                            const CriarFormularioScreenSatisfacao(),
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
                    .collection('formulariosSatisfacao')
                    .orderBy('dataCriacao', descending: true)
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
                          .collection('respostasSatisfacao')
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
    const baseUrl =
        'https://plansanear.com.br/redeplansanea/v10/#/pesquisasatisfacao';
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
                  .collection('formulariosSatisfacao')
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
    Key? key,
    required this.cidade,
    required this.quantidade,
    required this.dataCriacao,
    required this.onTap,
    required this.onCopy,
    required this.onDelete,
  }) : super(key: key);

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

class RespostasScreen extends StatelessWidget {
  final String idFormulario;
  final String municipio;

  const RespostasScreen({
    Key? key,
    required this.idFormulario,
    required this.municipio,
  }) : super(key: key);

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
              .collection('respostasSatisfacao')
              .where('idFormulario', isEqualTo: idFormulario)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)),
              );
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
                String idResposta = respostas[index].id;
                return _RespostaCard(
                  resposta: resposta,
                  idResposta: idResposta,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _RespostaCard extends StatelessWidget {
  final Map<String, dynamic> resposta;
  final String idResposta;

  const _RespostaCard({
    Key? key,
    required this.resposta,
    required this.idResposta,
  }) : super(key: key);

  // Exibe diálogo para confirmar a exclusão da resposta
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
                  .collection('respostasSatisfacao')
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

  // Retorna a cor de fundo de acordo com a nota (1 a 5)
  Color _getRatingColor(int rating) {
    final hues = [
      Colors.red[400]!,
      Colors.orange[400]!,
      Colors.yellow[600]!,
      Colors.lightGreen[400]!,
      Colors.green[400]!
    ];
    return hues[rating - 1];
  }

  // Retorna o label descritivo da nota
  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return "Muito insatisfeito";
      case 2:
        return "Insatisfeito";
      case 3:
        return "Neutro";
      case 4:
        return "Satisfeito";
      case 5:
        return "Muito satisfeito";
      default:
        return "Não informado";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtém a lista de respostas (supõe-se que seja um array com índices 0 a 4 para as escalas)
    List<dynamic>? respostasList = resposta['respostas'];
    List<Widget> ratingWidgets = [];
    if (respostasList != null && respostasList is List) {
      int totalRatingQuestions =
          respostasList.length >= 5 ? 5 : respostasList.length;
      for (int i = 0; i < totalRatingQuestions; i++) {
        int? rating;
        if (respostasList[i] is int) {
          rating = respostasList[i] as int;
        } else if (respostasList[i] is String) {
          rating = int.tryParse(respostasList[i]) ?? 0;
        }
        ratingWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Text(
                  "Pergunta ${i + 1}:",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                if (rating != null && rating > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getRatingColor(rating),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "$rating - ${_getRatingLabel(rating)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  const Text("Não informado"),
              ],
            ),
          ),
        );
      }
      // Se houver observações no índice 5, exibe-as
      if (respostasList.length > 5) {
        String observation = respostasList[5]?.toString() ?? "";
        if (observation.trim().isNotEmpty) {
          ratingWidgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                "Observações: $observation",
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          );
        }
      }
    } else {
      ratingWidgets.add(const Text("Nenhuma resposta registrada."));
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho: nome do respondente e botão de exclusão
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
            // Exibe as respostas das escalas (número da pergunta e indicador colorido)
            ...ratingWidgets,
            const SizedBox(height: 12),
            // Data e hora da resposta
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

  const _InfoRow({Key? key, required this.icon, required this.text})
      : super(key: key);

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
    Key? key,
    required this.icon,
    required this.message,
  }) : super(key: key);

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
