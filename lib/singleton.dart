class MeuSingleton {
  // A instância estática para garantir que sempre haja apenas uma
  static final MeuSingleton _instance = MeuSingleton._internal();

  // Construtor privado
  MeuSingleton._internal();

  // Método estático para acessar a instância
  static MeuSingleton get instance => _instance;

  // A variável que é um vetor (lista)
  List<String> respostasSatisfacao = [];

  // A variável que é um vetor (lista)
  List<String> configSatisfacao = [];

  // Variável booleana auxiliar
  bool flagPodeEnviar = false;

  // Método para adicionar um item ao vetor
  void adicionarItem(String item) {
    respostasSatisfacao.add(item);
    // Aqui você pode fazer algo com flagAuxiliar, se precisar
  }

  // Método para obter o vetor completo
  List<String> obterVetor() {
    return respostasSatisfacao;
  }

  // Método para "zerar" o vetor
  void zerarVetor() {
    respostasSatisfacao.clear();
  }

  // Método para definir a flag auxiliar
  void definirFlagAuxiliar(bool valor) {
    flagPodeEnviar = valor;
  }
}
