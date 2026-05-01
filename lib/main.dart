import 'package:flutter/material.dart';
import 'telas/tela_principal.dart'; // Import correto

void main() {
  runApp(const DelyFitApp());
}

class DelyFitApp extends StatelessWidget {
  const DelyFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DelyFit',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      // Adicionando o widget importado aqui:
      home: TelaPrincipal(), 
    );
  }
}
