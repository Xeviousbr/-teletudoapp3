import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tele_tudo_app/api.dart';

class ResgatePage extends StatefulWidget {
  @override
  _ResgatePageState createState() => _ResgatePageState();
}

class _ResgatePageState extends State<ResgatePage> {
  String saldo = 'R\$ 0,00';
  String valorDebitado = 'R\$ 0,00';
  String valorResgate = 'R\$ 0,00';

  @override
  void initState() {
    super.initState();
    fetchSaldo();
  }

  void fetchSaldo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('idUser');

    if (userId != null) {
      try {
        String newSaldo = await API.saldo(userId);
        double saldoNum = double.parse(newSaldo);
        double debito = saldoNum >= 500 ? 1.0 : 2.0;
        double valorAResgatar = saldoNum - debito;

        setState(() {
          saldo = 'R\$ ${saldoNum.toStringAsFixed(2)}';
          valorDebitado = 'R\$ ${debito.toStringAsFixed(2)}';
          valorResgate = 'R\$ ${valorAResgatar.toStringAsFixed(2)}'; // Valor a ser resgatado
        });
      } catch (e) {
        print('Erro ao buscar saldo: $e');
      }
    } else {
      print("UserID não encontrado. Por favor, faça login novamente.");
    }
  }

  void confirmResgate() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmar Resgate"),
          content: Text("Confirma transferência de $valorResgate para sua conta?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancelar"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Confirmar"),
              onPressed: () {
                // Lógica para processar o resgate
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Resgate"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Saldo Total: $saldo", style: TextStyle(fontSize: 18)),
            Text("Valor Debitado: $valorDebitado", style: TextStyle(fontSize: 18, color: Colors.red)),
            Text("Valor a Resgatar: $valorResgate", style: TextStyle(fontSize: 18, color: Colors.green)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: confirmResgate,
              child: Text('Resgatar'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(150, 40),
                backgroundColor: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
