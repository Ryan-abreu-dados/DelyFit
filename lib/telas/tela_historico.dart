import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TelaHistorico extends StatefulWidget {
  const TelaHistorico({super.key});

  @override
  State<TelaHistorico> createState() => _TelaHistoricoState();
}

class _TelaHistoricoState extends State<TelaHistorico> {
  List<dynamic> _pedidos = [];
  bool _carregando = true;
  String _erro = '';

  @override
  void initState() {
    super.initState();
    _buscarPedidos();
  }

  Future<void> _buscarPedidos() async {
    setState(() {
      _carregando = true;
      _erro = '';
    });

    try {
      final resposta = await http.get(Uri.parse('http://localhost:3000/pedidos'));
      final dados = jsonDecode(resposta.body) as List;
      setState(() {
        _pedidos = dados.reversed.toList(); // mais recente primeiro
      });
    } catch (e) {
      setState(() => _erro = 'Não foi possível carregar o histórico.');
    }

    setState(() => _carregando = false);
  }

  String _formatarData(String dataIso) {
    final data = DateTime.parse(dataIso);
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}  ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Histórico de Pedidos"),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _buscarPedidos,
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : _erro.isNotEmpty
              ? Center(child: Text(_erro, style: const TextStyle(color: Colors.red)))
              : _pedidos.isEmpty
                  ? const Center(child: Text("Nenhum pedido realizado ainda."))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _pedidos.length,
                      itemBuilder: (context, index) {
                        final pedido = _pedidos[index];
                        final itens = pedido['itens'] as List;
                        final total = pedido['total'];
                        final data = _formatarData(pedido['data']);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Pedido #${pedido['id']}",
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    Text(
                                      data,
                                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                                    ),
                                  ],
                                ),
                                const Divider(height: 20),
                                ...itens.map((item) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(item['nome']),
                                          Text("R\$ ${(item['preco'] as num).toStringAsFixed(2)}"),
                                        ],
                                      ),
                                    )),
                                const Divider(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      "Total: R\$ ${(total as num).toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
