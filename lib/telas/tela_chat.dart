import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TelaChat extends StatefulWidget {
  const TelaChat({super.key});

  @override
  State<TelaChat> createState() => _TelaChatState();
}

class _TelaChatState extends State<TelaChat> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Cada mensagem é um mapa com 'texto' e 'ehUsuario'
  final List<Map<String, dynamic>> _mensagens = [
    {'texto': 'Olá! Sou o assistente da DelyFit. Como posso ajudar?', 'ehUsuario': false},
  ];

  bool _carregando = false;

  Future<void> _enviarMensagem() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;

    setState(() {
      _mensagens.add({'texto': texto, 'ehUsuario': true});
      _carregando = true;
    });

    _controller.clear();
    _rolarParaBaixo();

    try {
      final resposta = await http.post(
        Uri.parse('http://localhost:3000/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mensagem': texto}),
      );

      final dados = jsonDecode(resposta.body);
      setState(() {
        _mensagens.add({'texto': dados['resposta'], 'ehUsuario': false});
      });
    } catch (e) {
      setState(() {
        _mensagens.add({'texto': 'Sem conexão com o servidor.', 'ehUsuario': false});
      });
    }

    setState(() => _carregando = false);
    _rolarParaBaixo();
  }

  void _rolarParaBaixo() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildBolinha(Map<String, dynamic> mensagem) {
    final ehUsuario = mensagem['ehUsuario'] as bool;
    return Align(
      alignment: ehUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: ehUsuario ? Colors.deepOrange : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          mensagem['texto'],
          style: TextStyle(
            color: ehUsuario ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat DelyFit'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _mensagens.length,
              itemBuilder: (context, index) => _buildBolinha(_mensagens[index]),
            ),
          ),
          if (_carregando)
            const Padding(
              padding: EdgeInsets.all(8),
              child: LinearProgressIndicator(color: Colors.orange),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Digite sua mensagem...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _enviarMensagem(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.deepOrange,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _enviarMensagem,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
