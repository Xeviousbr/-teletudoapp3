import 'dart:async';
import 'models/delivery_details.dart';
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
  String? statusMessage;
  bool hasPickedUp = false;
  bool deliveryCompleted = false;
  bool hasAcceptedDelivery = false;  // Adiciona esta linha

  @override
  void initState() {
    super.initState();
    _scheduleNextHeartbeat(2);
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (deliveryData != null) _buildDeliveryDetails(),
            if (statusMessage != null) Padding(
              padding: EdgeInsets.all(20),
              child: Text(statusMessage!, style: TextStyle(fontSize: 18, color: Colors.red)),
            ),
            if (hasAcceptedDelivery && !hasPickedUp)
              ElevatedButton(
                onPressed: handlePickedUp,
                child: const Text('Peguei a encomenda com o fornecedorr'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(150, 40),
                  backgroundColor: Colors.orange,
                  textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            if (hasPickedUp && !deliveryCompleted)
              ElevatedButton(
                onPressed: handleDeliveryCompleted,
                child: const Text('Entrega Concluída'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(150, 40),
                  backgroundColor: Colors.green,
                  textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
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
              title: Row(
                children: [
                  Expanded(
                    child: Text('Distância: ${deliveryData!['dist']} km'),
                  ),
                  Expanded(
                    child: Text(
                      'Peso: ${deliveryData!['peso'] > 0 ? "${deliveryData!['peso']} kg" : "Não Informado"}',
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.monetization_on, color: Colors.green),
              title: Text(
                  'Valor: R\$ ${deliveryData!['valor'].toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
            ),
            if (!hasAcceptedDelivery) // Só mostra se a entrega ainda não foi aceita
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      handleDeliveryResponse(true);
                    },
                    child: Text(
                      'Aceitar',
                      style: TextStyle(
                          color: Colors.white, // Texto branco
                          fontWeight: FontWeight.bold // Texto em negrito
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(150, 40),
                      backgroundColor: Colors.green,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      handleDeliveryResponse(false);
                    },
                    child: Text(
                      'Recusar',
                      style: TextStyle(
                          color: Colors.white, // Texto branco
                          fontWeight: FontWeight.bold // Texto em negrito
                      ),
                    ),
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
    _timer?.cancel();
    _timer = Timer(Duration(seconds: seconds), chamaHeartbeat);
  }

  Future<void> chamaHeartbeat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DeliveryDetails? deliveryDetails = await API.sendHeartbeat();
    if (deliveryDetails != null) {
      double valorDelivery = deliveryDetails.valor ?? 0.0;
      int? currentChamado = prefs.getInt('currentChamado');

      // Verifica se o novo chamado é diferente do último registrado
      if (deliveryDetails.chamado != currentChamado && valorDelivery > 0.0) {
        await prefs.setInt('currentChamado', deliveryDetails.chamado ?? 0);

        setState(() {
          deliveryData = {
            'enderIN': deliveryDetails.enderIN ?? 'Desconhecido',
            'enderFN': deliveryDetails.enderFN ?? 'Desconhecido',
            'dist': deliveryDetails.dist ?? 0.0,
            'valor': valorDelivery,
            'peso': deliveryDetails.peso ?? 'Não Informado',
            'chamado': deliveryDetails.chamado,
          };
        });

        int? userId = prefs.getInt('idUser');
        if (userId != null) {
          await API.reportViewToServer(userId, deliveryDetails.chamado);
          print("Visualização reportada: chamado = ${deliveryDetails.chamado}, userId = $userId");
        }
      }

      // Agendar o próximo heartbeat de acordo com o 'modo'
      int nextInterval = (deliveryDetails.modo ?? 3) == 3 ? 60 : 10;
      _scheduleNextHeartbeat(nextInterval);
    } else {
      print("Erro ao receber dados de heartbeat");
      _scheduleNextHeartbeat(60); // Usando 60 segundos como fallback
    }
  }

  void handleDeliveryResponse(bool accept) async {
    if (accept) {
      setState(() {
        hasAcceptedDelivery = true;
        statusMessage = "Entrega aceita. A caminho do fornecedor2.";
      });
      // Aqui você pode adicionar a chamada da API para aceitar a entrega
    } else {
      setState(() {
        hasAcceptedDelivery = false;
        hasPickedUp = false;
        statusMessage = "Entrega recusada.";
      });
      // Aqui você pode adicionar a chamada da API para recusar a entrega
    }
  }

  void handlePickedUp() {
    setState(() {
      hasPickedUp = true;
      statusMessage = "A caminho de fazer a entrega";
    });
  }

  void handleDeliveryCompleted() async {
    bool success = await API.notifyDeliveryCompleted(); // Suponha que isto envie a confirmação final ao servidor.
    if (success) {
      setState(() {
        deliveryCompleted = true;  // Indica que a entrega foi concluída.
        statusMessage = 'Entrega concluída com sucesso!';
      });
      // Configurar o temporizador para mudar a mensagem após 50 segundos.
      Timer(Duration(seconds: 50), handleWaitingForNewDelivery);
    } else {
      print("Falha ao confirmar a entrega.");
    }
  }

  void handleWaitingForNewDelivery() {
    setState(() {
      // Limpa os dados de entrega ou mantém o estado que você precisa para nova entrega.
      deliveryData = null;
      statusMessage = "Aguardando novas entregas...";
      hasPickedUp = false;
      deliveryCompleted = false;
      hasAcceptedDelivery = false; // Resetar todos os flags de estado, se necessário.
    });
  }

}
