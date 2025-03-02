import 'package:Redeplansanea/formularios/mapeamentoatores/todas_respostas_mapeamento.dart';
import 'package:Redeplansanea/formularios/presenca/todas_respostas.dart';
import 'package:Redeplansanea/formularios/presencacomite/todas_respostas_comite.dart';
import 'package:Redeplansanea/formularios/satisfacao/todas_respostas_satisfacao.dart';
import 'package:Redeplansanea/formularios/votacao/todas_votacoes.dart';
import 'package:Redeplansanea/main.dart';
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
        "Andaraí",
        "Barra do Choça",
        "Barra da Estiva",
        "Botuporã",
        "Brejões",
        "Caatiba",
        "Cachoeira",
        "Cafarnaum",
        "Canudos",
        "Cardeal da Silva",
        "Catu",
        "Cícero Dantas",
        "Cipó",
        "Entre Rios",
        "Coronel João Sá",
        "Ibipeba",
        "Ibirataia",
        "Iaçu",
        "Iguaí",
        "Itagi",
        "Muqúem de São Francisco",
        "Itagimirim",
        "Itanagra",
        "Nova Itarana",
        "Ituaçu",
        "Iuiu",
        "Rio Real",
        "Jaguaquara",
        "Maracás",
        "Mirangaba",
        "Muritiba",
        "Nordestina",
        "Potiraguá",
        "Quixabeira",
        "Ruy Barbosa",
        "Retirolândia",
        "São Domingos",
        "Sapeaçu",
        "Saúde",
        "Sebastião Laranjeiras",
        "Sento Sé",
        "Ubatã",
        "Várzea da Roça"
      ],
      "Pernambuco": [
        "Belém do São Francisco",
        "Agrestina",
        "Amaraji",
        "Betânia",
        "Barreiros",
        "Brejinho",
        "Cabrobó",
        "Calumbi",
        "Camocim de São Félix",
        "Carnaubeira da Penha",
        "Canhotinho",
        "Carnaíba",
        "Lajedo",
        "Cedro",
        "Cupira",
        "Petrolândia",
        "Custódia",
        "Ferreiros",
        "Quixaba",
        "Granito",
        "Ipubi",
        "São José do Belmonte",
        "Jaqueira",
        "Jataúba",
        "Serrita",
        "Joaquim Nabuco",
        "Lagoa do Ouro",
        "Trindade",
        "Maraial",
        "Mirandiba",
        "Passira",
        "Santa Cruz",
        "Santa Cruz da Baixa Verde",
        "São Bento do Una",
        "São José do Egito",
        "Solidão",
        "Triunfo",
        "Verdejante"
      ],
      "Rio de Janeiro": [
        "Bom Jardim",
        "Cardoso Moreira",
        "Bom Jesus do Itabapoana",
        "Casimiro de Abreu",
        "Conceição de Macabu",
        "Duas Barras",
        "Engenheiro Paulo de Frontín",
        "Itaocara",
        "São Fidélis",
        "São Francisco de Itabapoana",
        "Trajano de Moraes"
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
                        'assets/logoredeplanrmbg.png',
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
                              }

                              if (estadoSelecionado != null &&
                                  municipioSelecionado != null &&
                                  tipoSelecionado != null) {
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
    return SingleChildScrollView(
      child: Center(
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
              title: 'Pesquisa de Satisfação',
              subtitle: 'Avaliação das percepções e opiniões dos participantes',
              imagePath: 'assets/ico_pesquisa.png',
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        AdminScreenSatisfacao(),
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
              title: 'Mapeamento de atores sociais locais',
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
            buildAnimatedCard(
              context,
              title: 'Votação',
              subtitle: 'Sistema simples de votação, intuitivo e seguro.',
              imagePath: 'assets/ico_votacao.png',
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        AdminScreenVotacao(),
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
            SizedBox(height: 120),
          ],
        ),
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
