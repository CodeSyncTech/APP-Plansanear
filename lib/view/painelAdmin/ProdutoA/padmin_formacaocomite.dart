import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormacaoComiteInfoScreen extends StatefulWidget {
  final String userId;

  const FormacaoComiteInfoScreen({required this.userId});

  @override
  _FormacaoComiteInfoScreenState createState() =>
      _FormacaoComiteInfoScreenState();
}

class _FormacaoComiteInfoScreenState extends State<FormacaoComiteInfoScreen> {
  // Lista de todos os cargos possíveis
  final List<String> _todosCargos = [
    "Coordenador",
    "Suplente Coordenador",
    "Engenheiro",
    "Suplente Engenheiro",
    "Profissional Ciências Sociais",
    "Suplente Profissional Ciências Sociais",
    "Estagiário Engenharia",
    "Suplente Estagiário Engenharia",
    "Estagiário em Sociologia, Pedagogia ou Ciências Humanas",
    "Suplente Estagiário em Sociologia, Pedagogia ou Ciências Humanas",
    "Téc. Informática",
    "Suplente Téc. Informática",
    "Secretário Comitê Executivo",
    "Suplente Secretário Comitê Executivo",
    "Representante Municipal de Secretarias Ligadas ao Saneamento",
    "Suplente Representante Municipal de Secretarias Ligadas ao Saneamento",
    "Representante Téc. Prestador Serviço",
    "Suplente Téc. Prestador Serviço",
    "Conselheiro Municipal",
    "Suplente Conselheiro Municipal",
    "Profissional Órgão Adminstração direta e indireta de outros entes da federação",
    "Suplente Profissional Órgão Adminstração direta e indireta de outros entes da federação"
  ];

  // Mapa com o status de preenchimento para cada cargo
  Map<String, String> _statusCargos = {};

  // Lista de documentos preenchidos para o usuário
  List<Map<String, dynamic>> _userDataList = [];

  String? _cargoSelecionado;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Busca todos os registros onde 'preenchidoPor' é igual ao userId
  void _fetchUserData() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('formacao_comite')
          .where('preenchidoPor', isEqualTo: widget.userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        _userDataList = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      }

      // Para cada cargo na lista completa, define seu status:
      // Se existir algum documento com esse cargo, considera como "completo".
      _statusCargos = {
        for (var cargo in _todosCargos)
          cargo: _userDataList.any((data) => data['cargo'] == cargo)
              ? "completo"
              : "não preenchido"
      };

      // Define o cargo selecionado: se houver registros preenchidos, seleciona o primeiro preenchido;
      // caso contrário, seleciona o primeiro da lista de cargos.
      _cargoSelecionado = _userDataList.isNotEmpty
          ? _userDataList.first['cargo']
          : _todosCargos.first;
    } catch (e) {
      print("Erro ao carregar os dados: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Função para retornar o ícone de acordo com o status
  IconData _iconeStatus(String status) {
    switch (status) {
      case "completo":
        return Icons.check_circle;
      case "parcial":
        return Icons.warning;
      default:
        return Icons.circle;
    }
  }

  // Cor de acordo com o status
  Color _corStatus(String status) {
    switch (status) {
      case "completo":
        return Colors.green;
      case "parcial":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Formação Comitê - Registros")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Dropdown com todos os cargos
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _cargoSelecionado,
                        icon: Icon(Icons.arrow_drop_down,
                            color: Colors.blue[800]),
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        items: _todosCargos.map((cargo) {
                          // Busca o status para cada cargo no mapa criado
                          String status =
                              _statusCargos[cargo] ?? "não preenchido";
                          return DropdownMenuItem(
                            value: cargo,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  Icon(_iconeStatus(status),
                                      color: _corStatus(status), size: 20),
                                  SizedBox(width: 12),
                                  Expanded(child: Text(cargo)),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _cargoSelecionado = value!;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Exibição dos detalhes do cargo selecionado
                  _buildUserDetails(_cargoSelecionado),
                ],
              ),
            ),
    );
  }

  // Retorna os detalhes do cargo selecionado, se preenchido; caso contrário, exibe mensagem.
  Widget _buildUserDetails(String? cargo) {
    // Procura na lista de documentos o que corresponde ao cargo selecionado.
    Map<String, dynamic>? userData = _userDataList.firstWhere(
      (data) => data['cargo'] == cargo,
      orElse: () => {},
    );

    if (userData == null || userData.isEmpty) {
      return Center(
          child: Text(
        "Cargo não preenchido.",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ));
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoItem("Nome Completo", userData['nomeCompleto']),
            _buildInfoItem("CPF", userData['cpf']),
            _buildInfoItem("Profissão", userData['profissao']),
            _buildInfoItem("Função", userData['funcao']),
            _buildInfoItem("Telefone", userData['telefone']),
            _buildInfoItem("Email", userData['email']),
            _buildInfoItem("Cargo", userData['cargo']),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.blue[800], size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "$label: ${value ?? 'Não informado'}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
