// lib/modelos/produto.dart
class Produto {
  final String nome;
  final double preco;
  final String imagem;
  final String macros; // Novo campo
  final String descricao; // Novo campo
  final String categoria;

  Produto({
    required this.nome,
    required this.preco,
    required this.imagem,
    required this.macros,
    required this.descricao,
    required this.categoria,
  });
}
