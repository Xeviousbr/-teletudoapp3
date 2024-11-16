import 'package:flutter/material.dart';
import 'package:tele_tudo_app/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  void processResgate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('idUser');
    if (userId != null) {
      try {
        bool success = await API.sacar(userId);

        if (success) {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Resgate Concluído'),
                  content: Text('Seu resgate foi processado com sucesso.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Fecha o diálogo
                        Navigator.of(context).pop(); // Retorna para a HomePage
                      },
                      child: Text('Ok'),
                    )
                  ],
                );
              }
          );
        }

        else {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Erro'),
                  content: Text('Falha ao processar resgate. Tente novamente mais tarde.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Ok'),
                    )
                  ],
                );
              }
          );
        }
      } catch (e) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Erro'),
                content: Text('Ocorreu um erro durante a operação: $e'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Ok'),
                  )
                ],
              );
            }
        );
      }
    }
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
              onPressed: () async {
                Navigator.of(context).pop(); // Fecha o diálogo imediatamente
                processResgate(); // Chama a função que processa o resgate
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
