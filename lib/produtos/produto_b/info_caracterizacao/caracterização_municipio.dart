import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CaracterizacaoMunicipioScreen extends StatefulWidget {
  const CaracterizacaoMunicipioScreen({Key? key}) : super(key: key);

  @override
  _CaracterizacaoMunicipioScreenState createState() =>
      _CaracterizacaoMunicipioScreenState();
}

class _CaracterizacaoMunicipioScreenState
    extends State<CaracterizacaoMunicipioScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  // ---------------------------------------------------------------------------
  // ESTRUTURA PÚBLICA MUNICIPAL
  // ---------------------------------------------------------------------------
  String? _qtdVereadores; // selecionado via dropdown
  final TextEditingController _leiMunicipalController = TextEditingController();

  // ---------------------------------------------------------------------------
  // PROGRAMAS, AÇÕES E GESTÃO DO SANEAMENTO BÁSICO
  // ---------------------------------------------------------------------------
  // Cada item: { "programa": String, "secretaria": String }
  List<Map<String, String>> _programasSaneamento = [];
  final TextEditingController _programaSaneamentoController =
      TextEditingController();
  final TextEditingController _secretariaSaneamentoController =
      TextEditingController();

  // ---------------------------------------------------------------------------
  // PROGRAMAS, CAMPANHAS E AÇÕES NA POLÍTICA DE SAÚDE
  // ---------------------------------------------------------------------------
  // Cada item: { "nome": String, "dataInicio": DateTime?, "dataFim": DateTime? }
  List<Map<String, dynamic>> _programasSaude = [];
  final TextEditingController _nomeSaudeController = TextEditingController();

  // ---------------------------------------------------------------------------
  // PROGRAMAS, CAMPANHAS E AÇÕES NA POLÍTICA DE ASSISTÊNCIA SOCIAL
  // ---------------------------------------------------------------------------
  List<Map<String, dynamic>> _programasAssistencia = [];
  final TextEditingController _nomeAssistenciaController =
      TextEditingController();

  // ---------------------------------------------------------------------------
  // DATAS RELEVANTES, FESTEJOS E FERIADOS MUNICIPAIS
  // ---------------------------------------------------------------------------
  List<Map<String, dynamic>> _festejosFeriados = [];
  final TextEditingController _nomeFestejoController = TextEditingController();

  // ---------------------------------------------------------------------------
  // OUTRAS AGENDAS
  // ---------------------------------------------------------------------------
  List<Map<String, dynamic>> _outrasAgendas = [];
  final TextEditingController _nomeAgendaController = TextEditingController();

  // ---------------------------------------------------------------------------
  // PRODUTO B – POLÍTICA DE SANEAMENTO, CONSELHO, PLANO DIRETOR
  // ---------------------------------------------------------------------------
  bool? _possuiPoliticaSaneamento;
  bool? _haConselhoSaneamento;
  bool? _possuiPlanoDiretor;

  // ---------------------------------------------------------------------------
  // POPULAÇÕES TRADICIONAIS
  // ---------------------------------------------------------------------------
  bool? _existePopulacoesTrad;
  // Lista dinâmica: { "tipo": String, "setor": String }
  List<Map<String, String>> _populacoesTrad = [];
  final TextEditingController _tipoPopTradController = TextEditingController();
  String?
      _setorPopTrad; // selecionado via dropdown (agora carregado dinamicamente)
  // Campo para descrever políticas específicas
  final TextEditingController _politicasEspecificasController =
      TextEditingController();

  // ---------------------------------------------------------------------------
  // MÉTODOS PARA ESCOLHER DATA/INTERVALO (para listas com data)
  // ---------------------------------------------------------------------------
  /// Abre um diálogo para escolher entre data única ou intervalo e salva no item da lista.
  Future<void> _pickDateOrRange({
    required int index,
    required List<Map<String, dynamic>> list,
  }) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Escolher Data ou Intervalo"),
        content: Text("Como deseja selecionar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, "unica"),
            child: Text("Data Única"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, "intervalo"),
            child: Text("Intervalo de Datas"),
          ),
        ],
      ),
    );
    if (choice == null) return;

    if (choice == "unica") {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        setState(() {
          list[index]['dataInicio'] = picked;
          list[index]['dataFim'] = picked;
        });
      }
    } else {
      final pickedRange = await showDateRangePicker(
        context: context,
        initialDateRange: DateTimeRange(
          start: DateTime.now(),
          end: DateTime.now().add(Duration(days: 1)),
        ),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (pickedRange != null) {
        setState(() {
          list[index]['dataInicio'] = pickedRange.start;
          list[index]['dataFim'] = pickedRange.end;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // MÉTODOS AUXILIARES – ADIÇÃO/REMOÇÃO DE ITENS
  // ---------------------------------------------------------------------------
  void _addProgramaSaneamento() {
    final prog = _programaSaneamentoController.text.trim();
    final sec = _secretariaSaneamentoController.text.trim();
    if (prog.isEmpty || sec.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Informe o programa e a secretaria.")),
      );
      return;
    }
    setState(() {
      _programasSaneamento.add({"programa": prog, "secretaria": sec});
      _programaSaneamentoController.clear();
      _secretariaSaneamentoController.clear();
    });
  }

  void _removeProgramaSaneamento(int index) {
    setState(() {
      _programasSaneamento.removeAt(index);
    });
  }

  void _addProgramaSaude() {
    final nome = _nomeSaudeController.text.trim();
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Informe o programa/ação de saúde.")),
      );
      return;
    }
    setState(() {
      _programasSaude.add({"nome": nome, "dataInicio": null, "dataFim": null});
      _nomeSaudeController.clear();
    });
  }

  void _removeProgramaSaude(int index) {
    setState(() {
      _programasSaude.removeAt(index);
    });
  }

  void _addProgramaAssistencia() {
    final nome = _nomeAssistenciaController.text.trim();
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Informe o programa/ação de assistência social.")),
      );
      return;
    }
    setState(() {
      _programasAssistencia
          .add({"nome": nome, "dataInicio": null, "dataFim": null});
      _nomeAssistenciaController.clear();
    });
  }

  void _removeProgramaAssistencia(int index) {
    setState(() {
      _programasAssistencia.removeAt(index);
    });
  }

  void _addFestejo() {
    final nome = _nomeFestejoController.text.trim();
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Informe o nome do festejo/evento.")),
      );
      return;
    }
    setState(() {
      _festejosFeriados
          .add({"nome": nome, "dataInicio": null, "dataFim": null});
      _nomeFestejoController.clear();
    });
  }

  void _removeFestejo(int index) {
    setState(() {
      _festejosFeriados.removeAt(index);
    });
  }

  void _addOutraAgenda() {
    final nome = _nomeAgendaController.text.trim();
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Informe o nome da agenda/evento.")),
      );
      return;
    }
    setState(() {
      _outrasAgendas.add({"nome": nome, "dataInicio": null, "dataFim": null});
      _nomeAgendaController.clear();
    });
  }

  void _removeOutraAgenda(int index) {
    setState(() {
      _outrasAgendas.removeAt(index);
    });
  }

  void _addPopTrad() {
    final tipo = _tipoPopTradController.text.trim();
    final setor = _setorPopTrad;
    if (tipo.isEmpty || setor == null || setor.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Informe o tipo de população e o setor.")),
      );
      return;
    }
    setState(() {
      _populacoesTrad.add({"tipo": tipo, "setor": setor});
      _tipoPopTradController.clear();
      _setorPopTrad = null;
    });
  }

  void _removePopTrad(int index) {
    setState(() {
      _populacoesTrad.removeAt(index);
    });
  }

  // ---------------------------------------------------------------------------
  // SALVAR DADOS NO FIRESTORE
  // ---------------------------------------------------------------------------
  Future<void> _salvarDados() async {
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Usuário não autenticado.")),
      );
      return;
    }
    try {
      final dataToSave = {
        "estruturaPublicaMunicipal": {
          "qtdVereadores": _qtdVereadores ?? "",
          "leiMunicipal": _leiMunicipalController.text.trim(),
        },
        "programasAcoesSaneamento": _programasSaneamento,
        "programasSaude": _serializeListWithDates(_programasSaude),
        "programasAssistencia": _serializeListWithDates(_programasAssistencia),
        "festejosFeriados": _serializeListWithDates(_festejosFeriados),
        "outrasAgendas": _serializeListWithDates(_outrasAgendas),
        "produtoB": {
          "politicaSaneamento": _possuiPoliticaSaneamento ?? false,
          "conselhoSaneamento": _haConselhoSaneamento ?? false,
          "planoDiretor": _possuiPlanoDiretor ?? false,
        },
        "populacoesTradicionais": {
          "existe": _existePopulacoesTrad ?? false,
          "lista": _populacoesTrad,
          "politicasEspecificas": _politicasEspecificasController.text.trim(),
        },
      };

      await _firestore
          .collection('formInfoMunicipio')
          .doc(uid)
          .collection('caracterizacoes')
          .doc('caracterizacaoMunicipio')
          .set(dataToSave, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Dados salvos com sucesso!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao salvar dados: $e")),
      );
    }
  }

  /// Serializa listas que possuem data (DateTime) para Timestamps.
  List<Map<String, dynamic>> _serializeListWithDates(
      List<Map<String, dynamic>> list) {
    return list.map((item) {
      final start = item['dataInicio'] as DateTime?;
      final end = item['dataFim'] as DateTime?;
      return {
        "nome": item['nome'] ?? "",
        "dataInicio": start != null ? Timestamp.fromDate(start) : null,
        "dataFim": end != null ? Timestamp.fromDate(end) : null,
      };
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // WIDGET AUXILIAR: Dropdown para quantidade de vereadores
  // ---------------------------------------------------------------------------
  Widget _buildDropdownVereadores() {
    // Exemplo: opções de 5 a 25 vereadores
    final options = List<String>.generate(21, (i) => '${i + 5}');
    return DropdownButtonFormField<String>(
      value: _qtdVereadores,
      items: options
          .map((op) => DropdownMenuItem(value: op, child: Text(op)))
          .toList(),
      onChanged: (value) {
        setState(() {
          _qtdVereadores = value;
        });
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      ),
      hint: Text("Selecione a quantidade"),
    );
  }

  // ---------------------------------------------------------------------------
  // WIDGET AUXILIAR: Lista para itens com data (usa _pickDateOrRange)
  // ---------------------------------------------------------------------------
  Widget _buildListWithDates({
    required List<Map<String, dynamic>> list,
    required Function(int) removeItem,
    required Function(int) pickDates,
  }) {
    if (list.isEmpty) return Text("Nenhum item adicionado.");
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (ctx, index) {
        final item = list[index];
        String dataInfo = "Sem data definida";
        if (item['dataInicio'] != null && item['dataFim'] != null) {
          final start = DateFormat('dd/MM/yyyy').format(item['dataInicio']);
          final end = DateFormat('dd/MM/yyyy').format(item['dataFim']);
          dataInfo = start == end ? start : "Início: $start | Fim: $end";
        }
        return ListTile(
          title: Text(item['nome'] ?? ""),
          subtitle: Text(dataInfo),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.calendar_today, color: Colors.green),
                onPressed: () => pickDates(index),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => removeItem(index),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // WIDGET AUXILIAR: Dropdown para perguntas Sim/Não (substitui os radio buttons)
  // ---------------------------------------------------------------------------
  Widget _buildYesNoDropdown({
    required String label,
    required bool? value,
    required Function(bool?) onChanged,
  }) {
    String? dropdownValue;
    if (value != null) {
      dropdownValue = value ? "Sim" : "Não";
    }
    return Row(
      children: [
        Expanded(child: Text(label)),
        SizedBox(width: 16),
        DropdownButton<String>(
          value: dropdownValue,
          items: [
            DropdownMenuItem(value: "Sim", child: Text("Sim")),
            DropdownMenuItem(value: "Não", child: Text("Não")),
          ],
          hint: Text("Selecione"),
          onChanged: (val) {
            if (val != null) {
              onChanged(val == "Sim" ? true : false);
            }
          },
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // WIDGET AUXILIAR: Dropdown para Setor de Mobilização (carregado do Firestore)
  // ---------------------------------------------------------------------------
  Widget _buildDropdownSetorPopTrad() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('formInfoMunicipio')
          .doc(uid)
          .collection('setores')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text("Nenhum setor cadastrado.");
        }
        final setores = snapshot.data!.docs;
        return DropdownButtonFormField<String>(
          value: _setorPopTrad,
          items: setores.map((doc) {
            return DropdownMenuItem<String>(
              value: doc.id, // ou doc['nome'] se preferir usar o nome
              child: Text(doc['nome'] ?? 'Sem nome'),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              _setorPopTrad = val;
            });
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          ),
          hint: Text("Selecione um setor"),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD – Monta a tela completa
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Caracterização do Município"),
      ),
      body: uid == null
          ? Center(child: Text("Usuário não autenticado."))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabeçalho
                  Text(
                    "INFORMAÇÕES PARA A CARACTERIZAÇÃO DO MUNICÍPIO",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  // ESTRUTURA PÚBLICA MUNICIPAL
                  Text(
                    "ESTRUTURA PÚBLICA MUNICIPAL",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                      "Quantidade de vereadores que compõem a Câmara Municipal:"),
                  _buildDropdownVereadores(),
                  SizedBox(height: 8),
                  Text("Lei Municipal que define o número de vereadores:"),
                  TextField(
                    controller: _leiMunicipalController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Ex.: Lei nº 123/2021",
                    ),
                  ),
                  SizedBox(height: 20),
                  // PROGRAMAS, AÇÕES E GESTÃO DO SANEAMENTO BÁSICO
                  Text(
                    "PROGRAMAS, AÇÕES E GESTÃO DO SANEAMENTO BÁSICO",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Informe os programas que o município desenvolve (coluna 1) e a secretaria responsável (coluna 2).",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _programaSaneamentoController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Programa",
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _secretariaSaneamentoController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Secretaria Responsável",
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, color: Colors.blue),
                        onPressed: _addProgramaSaneamento,
                      ),
                    ],
                  ),
                  _programasSaneamento.isEmpty
                      ? Text("Nenhum programa adicionado.")
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _programasSaneamento.length,
                          itemBuilder: (ctx, i) {
                            final item = _programasSaneamento[i];
                            return ListTile(
                              title: Text(item['programa'] ?? ""),
                              subtitle:
                                  Text("Secretaria: ${item['secretaria']}"),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeProgramaSaneamento(i),
                              ),
                            );
                          },
                        ),
                  SizedBox(height: 20),
                  // PROGRAMAS, CAMPANHAS E AÇÕES NA POLÍTICA DE SAÚDE
                  Text(
                    "PROGRAMAS, CAMPANHAS E AÇÕES NA POLÍTICA DE SAÚDE",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Ex.: campanhas de vacinação, PSF, outubro rosa, etc. Informe data ou período.",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nomeSaudeController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Programa/Ação (Saúde)",
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, color: Colors.blue),
                        onPressed: _addProgramaSaude,
                      ),
                    ],
                  ),
                  _buildListWithDates(
                    list: _programasSaude,
                    removeItem: _removeProgramaSaude,
                    pickDates: (index) =>
                        _pickDateOrRange(index: index, list: _programasSaude),
                  ),
                  SizedBox(height: 20),
                  // PROGRAMAS, CAMPANHAS E AÇÕES NA POLÍTICA DE ASSISTÊNCIA SOCIAL
                  Text(
                    "PROGRAMAS, CAMPANHAS E AÇÕES NA POLÍTICA DE ASSISTÊNCIA SOCIAL",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Ex.: Bolsa Família, Campanhas do Agasalho, etc. Informe data ou período.",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nomeAssistenciaController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Programa/Ação (Assistência)",
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, color: Colors.blue),
                        onPressed: _addProgramaAssistencia,
                      ),
                    ],
                  ),
                  _buildListWithDates(
                    list: _programasAssistencia,
                    removeItem: _removeProgramaAssistencia,
                    pickDates: (index) => _pickDateOrRange(
                      index: index,
                      list: _programasAssistencia,
                    ),
                  ),
                  SizedBox(height: 20),
                  // DATAS RELEVANTES, FESTEJOS E FERIADOS MUNICIPAIS
                  Text(
                    "DATAS RELEVANTES, FESTEJOS E FERIADOS MUNICIPAIS",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Elabore uma lista detalhada dos festejos, eventos religiosos, feriados, etc.",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nomeFestejoController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Festejo/Evento",
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, color: Colors.blue),
                        onPressed: _addFestejo,
                      ),
                    ],
                  ),
                  _buildListWithDates(
                    list: _festejosFeriados,
                    removeItem: _removeFestejo,
                    pickDates: (index) =>
                        _pickDateOrRange(index: index, list: _festejosFeriados),
                  ),
                  SizedBox(height: 20),
                  // OUTRAS AGENDAS
                  Text(
                    "OUTRAS AGENDAS",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Cite a agenda de reuniões e eventos da Câmara Municipal.",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nomeAgendaController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Agenda/Evento",
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, color: Colors.blue),
                        onPressed: _addOutraAgenda,
                      ),
                    ],
                  ),
                  _buildListWithDates(
                    list: _outrasAgendas,
                    removeItem: _removeOutraAgenda,
                    pickDates: (index) =>
                        _pickDateOrRange(index: index, list: _outrasAgendas),
                  ),
                  SizedBox(height: 20),
                  // PRODUTO B – POLÍTICA DE SANEAMENTO, CONSELHO, PLANO DIRETOR
                  Text(
                    "INFORMAÇÕES – PRODUTO B",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  _buildYesNoDropdown(
                    label: "O Município possui Política de Saneamento?",
                    value: _possuiPoliticaSaneamento,
                    onChanged: (val) {
                      setState(() {
                        _possuiPoliticaSaneamento = val;
                      });
                    },
                  ),
                  _buildYesNoDropdown(
                    label: "Há Conselho Municipal de Saneamento Básico?",
                    value: _haConselhoSaneamento,
                    onChanged: (val) {
                      setState(() {
                        _haConselhoSaneamento = val;
                      });
                    },
                  ),
                  _buildYesNoDropdown(
                    label: "O Município possui Plano Diretor?",
                    value: _possuiPlanoDiretor,
                    onChanged: (val) {
                      setState(() {
                        _possuiPlanoDiretor = val;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  // POPULAÇÕES TRADICIONAIS
                  Text(
                    "POPULAÇÕES TRADICIONAIS",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Ex.: Quilombolas, Indígenas, Ribeirinhos, Pescadores etc.",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  _buildYesNoDropdown(
                    label: "Existem populações tradicionais no Município?",
                    value: _existePopulacoesTrad,
                    onChanged: (val) {
                      setState(() {
                        _existePopulacoesTrad = val;
                      });
                    },
                  ),
                  if (_existePopulacoesTrad == true) ...[
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _tipoPopTradController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Tipo de População",
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(child: _buildDropdownSetorPopTrad()),
                        IconButton(
                          icon: Icon(Icons.add, color: Colors.blue),
                          onPressed: _addPopTrad,
                        ),
                      ],
                    ),
                    _populacoesTrad.isEmpty
                        ? Text("Nenhuma população adicionada.")
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _populacoesTrad.length,
                            itemBuilder: (ctx, i) {
                              final item = _populacoesTrad[i];
                              return ListTile(
                                title: Text(item['tipo'] ?? ""),
                                subtitle: Text("Setor: ${item['setor']}"),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removePopTrad(i),
                                ),
                              );
                            },
                          ),
                    SizedBox(height: 8),
                    Text(
                        "O Município possui políticas específicas voltadas para os povos tradicionais?"),
                    TextField(
                      controller: _politicasEspecificasController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText:
                            "Descreva as políticas e como são implementadas",
                      ),
                      maxLines: 3,
                    ),
                  ],
                  SizedBox(height: 20),
                  // BOTÃO SALVAR
                  Center(
                    child: ElevatedButton(
                      onPressed: _salvarDados,
                      child: Text("Salvar Informações"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _leiMunicipalController.dispose();
    _programaSaneamentoController.dispose();
    _secretariaSaneamentoController.dispose();
    _nomeSaudeController.dispose();
    _nomeAssistenciaController.dispose();
    _nomeFestejoController.dispose();
    _nomeAgendaController.dispose();
    _tipoPopTradController.dispose();
    _politicasEspecificasController.dispose();
    super.dispose();
  }
}
