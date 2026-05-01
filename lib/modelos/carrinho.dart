// lib/modelos/carrinho.dart
import 'produto.dart';

class Carrinho {
  static List<Produto> itens = []; // Lista global de itens selecionados

  static double get total => itens.fold(0, (soma, item) => soma + item.preco);

  static void adicionar(Produto produto) {
    itens.add(produto);
  }

  static void limpar() {
    itens.clear();
  }
}