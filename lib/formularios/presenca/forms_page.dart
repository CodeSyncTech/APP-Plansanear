import 'package:Redeplansanea/formularios/mapeamentoatores/todas_respostas_mapeamento.dart';
import 'package:Redeplansanea/formularios/presenca/todas_respostas.dart';
import 'package:Redeplansanea/formularios/presencacomite/todas_respostas_comite.dart';
import 'package:Redeplansanea/main.dart';
import 'package:Redeplansanea/pesquisaSatisfacao.dart';
import 'package:Redeplansanea/singleton.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ListPage extends StatelessWidget {
  const ListPage({super.key});

  void _showPopup(BuildContext context) async {
    final estados = ["Rio de Janeiro", "Pernambuco", "Bahia"];
    final municipios = {
      "Bahia": [
        "Araci",
        "Caatiba",
        "Cícero Dantas",
        "Iaçu",
        "Nova Itarana",
        "Barra da Estiva",
        "Canudos",
        "Coronel João Sá",
        "Muquém do São Francisco",
        "Rio Real"
      ],
      "Pernambuco": [
        "Belém do São Francisco",
        "Betânia",
        "Cabrobó",
        "Carnaubeira da Penha",
        "Lajedo",
        "Petrolândia",
        "Quixaba",
        "São José do Belmonte",
        "Serrita",
        "Trindade"
      ],
      "Rio de Janeiro": [
        "Itaocara",
        "São Francisco de Itabapoana",
        "São Fidélis",
        "Duas Barras",
        "Casimiro de Abreu",
        "Bom Jardim",
        "Bom Jesus de Itabapoana"
      ]
    };
    final tipos = ["Comitê", "Evento Público"];

    String? estadoSelecionado;
    String? municipioSelecionado;
    String? tipoSelecionado;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Stack(
              children: [
                // 1) Animação Lottie ocupando todo o fundo
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Lottie.asset(
                      'assets/lottie.json', // Caminho da sua animação
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // 2) Overlay (opcional) para dar contraste
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.15),
                          Colors.black.withOpacity(0.25),
                        ],
                      ),
                    ),
                  ),
                ),

                // 3) Conteúdo principal do Popup
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/ze_planinho.png',
                        width: 100,
                        height: 100,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Selecione as opções",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 239, 239, 239),
                        ),
                      ),
                      const SizedBox(height: 10),
                      StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          Widget campoDropdown({
                            required String rotulo,
                            required Widget dropdown,
                            Color? rotuloColor,
                          }) {
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 255, 255, 255)
                                    .withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        const Color.fromARGB(255, 80, 80, 80),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: rotulo,
                                  labelStyle: TextStyle(
                                    color: rotuloColor ?? Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                child: dropdown,
                              ),
                            );
                          }

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Campo para escolher o Estado
                              campoDropdown(
                                rotulo: 'Estado',
                                rotuloColor: Colors.blue.shade700,
                                dropdown: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: estadoSelecionado,
                                    hint: const Text("Selecione o estado"),
                                    items: estados.map((String estado) {
                                      return DropdownMenuItem<String>(
                                        value: estado,
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              'assets/bandeiras/bandeira_${estado.toLowerCase().replaceAll(" ", "_")}.png',
                                              width: 40,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(estado),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        estadoSelecionado = newValue;
                                        municipioSelecionado = null;
                                      });
                                    },
                                  ),
                                ),
                              ),

                              // Campo para escolher o Município
                              if (estadoSelecionado != null)
                                campoDropdown(
                                  rotulo: 'Município',
                                  rotuloColor: Colors.green.shade700,
                                  dropdown: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: municipioSelecionado,
                                      hint: const Text("Selecione o município"),
                                      items: municipios[estadoSelecionado]!
                                          .map((String municipio) {
                                        return DropdownMenuItem<String>(
                                          value: municipio,
                                          child: Text(municipio),
                                        );
                                      }).toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          municipioSelecionado = newValue;
                                        });
                                      },
                                    ),
                                  ),
                                ),

                              // Campo para escolher o Tipo
                              campoDropdown(
                                rotulo: 'Tipo',
                                rotuloColor: Colors.orange.shade700,
                                dropdown: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: tipoSelecionado,
                                    hint: const Text("Selecione o tipo"),
                                    items: tipos.map((String tipo) {
                                      return DropdownMenuItem<String>(
                                        value: tipo,
                                        child: Text(tipo),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        tipoSelecionado = newValue;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              // Use seu Singleton ou lógica própria
                              MeuSingleton.instance.zerarVetor();
                              if (estadoSelecionado != null &&
                                  municipioSelecionado != null &&
                                  tipoSelecionado != null) {
                                print("Estado: $estadoSelecionado");
                                print("Município: $municipioSelecionado");
                                print("Tipo: $tipoSelecionado");

                                MeuSingleton.instance.adicionarItem(
                                  "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year} "
                                  "${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}",
                                );
                                MeuSingleton.instance
                                    .adicionarItem(municipioSelecionado!);
                                MeuSingleton.instance
                                    .adicionarItem(estadoSelecionado!);
                                MeuSingleton.instance
                                    .adicionarItem(tipoSelecionado!);

                                print(
                                  "\n\nEste é o meu vetor: ${MeuSingleton.instance.obterVetor()}",
                                );

                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PesquisaSatisfacao(),
                                  ),
                                );
                              }

                              if (estadoSelecionado != null &&
                                  municipioSelecionado != null &&
                                  tipoSelecionado != null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PesquisaSatisfacao(),
                                  ),
                                );
                              } else {
                                showErrorToast(
                                  context,
                                  'Erro!',
                                  'Por favor, selecione todas as opções!',
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text("Confirmar"),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 255, 255, 255),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text("Cancelar"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          buildAnimatedCard(
            context,
            title: 'Formulário de Presença',
            subtitle: 'Atividades iniciais para a elaboração do PMSB',
            imagePath: 'assets/ico_presenca2.png',
            onTap: () {
              //  context.go('/formularios');
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      AdminScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
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
          ),
          buildAnimatedCard(
            context,
            title: 'Formulário de Presença: Comitê',
            subtitle: 'Registro de participação',
            imagePath: 'assets/ico_presenca3.png',
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      AdminScreenComite(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
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
          ),
          buildAnimatedCard(
            context,
            title: 'Formulário de Satisfação',
            subtitle: 'Avaliação das percepções e opiniões dos participantes',
            imagePath: 'assets/ico_pesquisa.png',
            onTap: () {
              _showPopup(context);
            },
          ),
          buildAnimatedCard(
            context,
            title: 'Mapeamento Social',
            subtitle: 'Mapeamento de atores sociais locais',
            imagePath: 'assets/ico_mapeamento.png',
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      AdminScreenMapeamento(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
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
          ),
        ],
      ),
    );
  }
}

class ComparePage extends StatelessWidget {
  const ComparePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Em manutenção',
        style: TextStyle(fontSize: 30, color: Colors.white),
      ),
    );
  }
}
