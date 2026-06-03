import 'package:flutter/material.dart';
import 'produto.dart';

class Carrinho {
  static List<Produto> itens = [];

  // Notifica a UI quando o carrinho muda (para o badge funcionar)
  static ValueNotifier<int> contador = ValueNotifier(0);

  static double get total => itens.fold(0, (soma, item) => soma + item.preco);

  static void adicionar(Produto produto) {
    itens.add(produto);
    contador.value = itens.length;
  }

  static void remover(int index) {
    itens.removeAt(index);
    contador.value = itens.length;
  }

  static void limpar() {
    itens.clear();
    contador.value = 0;
  }
}
