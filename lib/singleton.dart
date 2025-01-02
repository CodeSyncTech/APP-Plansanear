class MeuSingleton {
  // A instância estática para garantir que sempre haja apenas uma
  static final MeuSingleton _instance = MeuSingleton._internal();

  // Construtor privado
  MeuSingleton._internal();

  // Método estático para acessar a instância
  static MeuSingleton get instance => _instance;

  // A variável que é um vetor (lista)
  List<String> meuVetor = [];

  // Variável booleana auxiliar
  bool flagPodeEnviar = false;

  // Método para adicionar um item ao vetor
  void adicionarItem(String item) {
    meuVetor.add(item);
    // Aqui você pode fazer algo com flagAuxiliar, se precisar
  }

  // Método para obter o vetor completo
  List<String> obterVetor() {
    return meuVetor;
  }

  // Método para "zerar" o vetor
  void zerarVetor() {
    meuVetor.clear();
  }

  // Método para definir a flag auxiliar
  void definirFlagAuxiliar(bool valor) {
    flagPodeEnviar = valor;
  }
}
