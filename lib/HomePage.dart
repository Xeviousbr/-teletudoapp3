import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tele_tudo_app/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? _timer;
  Map<String, dynamic>? deliveryData;

  @override
  void initState() {
    super.initState();
    _scheduleNextHeartbeat(10); // Primeira chamada agendada para daqui a 10 segundos
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teletudo App - Entregas'),
        centerTitle: true,
      ),
      body: Center(
        child: deliveryData != null ? _buildDeliveryDetails() : const Text('Aguardando novas entregas...'),
      ),
    );
  }

  Widget _buildDeliveryDetails() {
    return Card(
      margin: EdgeInsets.all(20),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detalhes da Entrega:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text('De: ${deliveryData!['enderIN']}'),
              subtitle: Text('Para: ${deliveryData!['enderFN']}'),
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text('Distância: ${deliveryData!['dist']} km'),
            ),
            ListTile(
              leading: Icon(Icons.monetization_on),
              title: Text('Valor: R\$${deliveryData!['valor']}'),
            ),
            ListTile(
              leading: Icon(Icons.line_weight),
              title: Text('Peso: ${deliveryData!['peso']} kg'),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    print('Entrega aceita');
                  },
                  child: Text('Aceitar Entrega'),
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(150, 40),
                    backgroundColor: Colors.green,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    print('Entrega recusada');
                  },
                  child: Text('Recusar Entrega'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(150, 40),
                    backgroundColor: Colors.red,
                  ),
                  // style: ElevatedButton.styleFrom(minimumSize: Size(150, 40), primary: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _scheduleNextHeartbeat(int seconds) {
    _timer?.cancel();  // Cancela qualquer timer existente antes de criar um novo
    _timer = Timer(Duration(seconds: seconds), chamaHeartbeat);
  }

  Future<void> chamaHeartbeat() async {
    var modo = await API.sendHeartbeat();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int nextInterval = (modo == 3) ? 60 : 10;
    _scheduleNextHeartbeat(nextInterval);
    if (modo != null && modo == 1) {
      setState(() {
        deliveryData = {
          'enderIN': prefs.getString('enderIN') ?? 'Desconhecido',
          'enderFN': prefs.getString('enderFN') ?? 'Desconhecido',
          'dist': prefs.getDouble('dist') ?? 0.0,
          'valor': prefs.getDouble('valor') ?? 0.0,
          'peso': prefs.getDouble('peso') ?? 0.0,
        };
      });
    }
  }
}
