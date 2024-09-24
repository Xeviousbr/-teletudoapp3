import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tele_tudo_app/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/delivery_details.dart';

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
    _scheduleNextHeartbeat(
        10); // Primeira chamada agendada para daqui a 10 segundos
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
        child: deliveryData != null
            ? _buildDeliveryDetails()
            : const Text('Aguardando novas entregas...'),
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
            Text('Detalhes da Entrega:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _scheduleNextHeartbeat(int seconds) {
    _timer?.cancel(); // Cancela qualquer timer existente antes de criar um novo
    _timer = Timer(Duration(seconds: seconds), chamaHeartbeat);
  }

  Future<void> chamaHeartbeat() async {
    DeliveryDetails? deliveryDetails = (await API.sendHeartbeat()) as DeliveryDetails?;
    if (deliveryDetails != null) {
      int nextInterval = (deliveryDetails.modo ?? 3) == 3 ? 60 : 5;
      _scheduleNextHeartbeat(nextInterval);

      if (deliveryDetails.chamado != null && deliveryDetails.chamado! > 0) {
        setState(() {
          deliveryData = {
            'enderIN': deliveryDetails.enderIN ?? 'Desconhecido',
            'enderFN': deliveryDetails.enderFN ?? 'Desconhecido',
            'dist': deliveryDetails.dist ?? 0.0,
            'dist': deliveryDetails.dist ?? 0.0,
            'valor': deliveryDetails.valor ?? 0.0,
            'peso': deliveryDetails.peso ?? 0.0,
          };
        });
        print("chamado = ${deliveryDetails.chamado} em chamaHeartbeat");
      } else {
        print("chamado = 0 em chamaHeartbeat");
      }
    } else {
      // Se deliveryDetails é nulo, reagende o heartbeat para um intervalo padrão, ou trate como um erro
      print("Erro ao receber dados de heartbeat");
      _scheduleNextHeartbeat(60);  // Usando 60 segundos como fallback
    }
  }

}
