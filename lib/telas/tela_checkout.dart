import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../modelos/carrinho.dart';
import 'tela_historico.dart';

class TelaCheckout extends StatefulWidget {
  const TelaCheckout({super.key});

  @override
  State<TelaCheckout> createState() => _TelaCheckoutState();
}

class _TelaCheckoutState extends State<TelaCheckout> {
  bool _enviando = false;

  Future<void> _enviarPedido() async {
    setState(() => _enviando = true);

    List<Map<String, dynamic>> itens = Carrinho.itens.map((produto) {
      return {'nome': produto.nome, 'preco': produto.preco};
    }).toList();

    try {
      final resposta = await http.post(
        Uri.parse('http://localhost:3000/pedidos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'itens': itens, 'total': Carrinho.total}),
      );

      if (resposta.statusCode == 201) {
        Carrinho.limpar();
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Pedido Confirmado!"),
            content: const Text("Seu pedido foi enviado para a cozinha. Obrigado por comprar na DelyFit!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const TelaHistorico()),
                  );
                },
                child: const Text("Ver Histórico"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text("Voltar ao Início"),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao enviar pedido. Tente novamente.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Não foi possível conectar ao servidor.")),
      );
    }

    setState(() => _enviando = false);
  }

  void _removerItem(int index) {
    setState(() => Carrinho.remover(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Finalizar Pedido"),
        backgroundColor: Colors.orange,
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaHistorico()));
            },
            icon: const Icon(Icons.history, color: Colors.white),
            label: const Text("Histórico", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Carrinho.itens.isEmpty
          ? const Center(child: Text("Seu carrinho está vazio!"))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: Carrinho.itens.length,
                    itemBuilder: (context, index) {
                      final item = Carrinho.itens[index];
                      return ListTile(
                        leading: const Icon(Icons.check_circle, color: Colors.green),
                        title: Text(item.nome),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("R\$ ${item.preco.toStringAsFixed(2)}"),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _removerItem(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${Carrinho.itens.length} ${Carrinho.itens.length == 1 ? 'item' : 'itens'}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            "Total: R\$ ${Carrinho.total.toStringAsFixed(2)}",
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: _enviando ? null : _enviarPedido,
                        child: _enviando
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("CONFIRMAR E PAGAR", style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
