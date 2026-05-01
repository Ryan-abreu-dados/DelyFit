import 'package:flutter/material.dart';
import '../modelos/carrinho.dart';

class TelaCheckout extends StatefulWidget {
  const TelaCheckout({super.key});

  @override
  State<TelaCheckout> createState() => _TelaCheckoutState();
}

class _TelaCheckoutState extends State<TelaCheckout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Finalizar Pedido"),
        backgroundColor: Colors.orange,
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
                        trailing: Text("R\$ ${item.preco.toStringAsFixed(2)}"),
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
                          const Text("Total:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text("R\$ ${Carrinho.total.toStringAsFixed(2)}", 
                               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Pedido Confirmado!"),
                              content: const Text("Obrigado por comprar na DelyFit."),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Carrinho.limpar();
                                    Navigator.popUntil(context, (route) => route.isFirst);
                                  },
                                  child: const Text("Voltar ao Início"),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text("CONFIRMAR E PAGAR", style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}