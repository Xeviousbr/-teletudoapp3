import 'package:flutter/material.dart';
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// MODOS DE OPERAÇÃO
// 1 - RECEBEU A INFORMAÇÃO DA ENTREGA MAS SEM ENTREGA AINDA
// 2 - ACEITOU
// 3 - CANCELOU
// 4 - EM ANDAMENTO
// 5 - FINALIZAÇÃO
// 6 - FALHA

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'TeleTudo App MotoBoys',
      home: LoginPage(),
    );
  }
}
