import 'package:flutter/material.dart';
import '../modelos/carrinho.dart';
import '../modelos/produto.dart';
import '../modelos/produtos_exemplo.dart';
import 'tela_checkout.dart';

class TelaCardapio extends StatelessWidget {
  TelaCardapio({super.key});

  final List<Produto> listaDeProdutos = produtosExemplo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nosso Cardápio"),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TelaCheckout()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: listaDeProdutos.length,
        itemBuilder: (context, index) {
          return _cardProdutoHorizontal(context, listaDeProdutos[index]);
        },
      ),
    );
  }

  Widget _cardProdutoHorizontal(BuildContext context, Produto produto) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _mostrarDetalhesPopUp(context, produto);
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  produto.imagem,
                  height: 90,
                  width: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) =>
                      Container(width: 90, height: 90, color: Colors.grey[300]),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produto.nome,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      produto.macros,
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "R\$ ${produto.preco.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const Icon(
                          Icons.add_circle,
                          color: Colors.orange,
                          size: 26,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDetalhesPopUp(BuildContext context, Produto produto) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            produto.nome,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline, size: 50, color: Colors.orange),
                const SizedBox(height: 15),
                const Text(
                  "Detalhes do Prato:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  produto.descricao,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[800], fontSize: 14),
                ),
                const SizedBox(height: 15),
                Divider(color: Colors.grey[300]),
                const SizedBox(height: 10),
                Text(
                  produto.macros,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "R\$ ${produto.preco.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Fechar", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () {
                Carrinho.adicionar(produto);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${produto.nome} no carrinho!")),
                );
              },
              child: const Text("Adicionar"),
            ),
          ],
        );
      },
    );
  }
}
