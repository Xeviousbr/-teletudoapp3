import 'login_page.dart';
import 'package:flutter/material.dart';
import 'package:background_fetch/background_fetch.dart';

// MODOS DE OPERAÇÃO
// 1 - RECEBEU A INFORMAÇÃO DA ENTREGA MAS SEM ENTREGA AINDA
// 2 - ACEITOU
// 3 - CANCELOU
// 4 - EM ANDAMENTO
// 5 - FINALIZAÇÃO
// 6 - FALHA

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

void backgroundFetchHeadlessTask(HeadlessTask task) async {
  var taskId = task.taskId;
  if (taskId == 'flutter_background_fetch') {
    // Aqui você chama sua função sendHeartbeat() ou similar
    print('[BackgroundFetch] Evento em background recebido');
    // Suponha que esta função atualize alguma informação ou envie dados
    await sendHeartbeat();
  }
  BackgroundFetch.finish(taskId);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TeleTudo App MotoBoys',
      home: LoginPage(),
      builder: (context, child) {
        initPlatformState();
        return child!;
      },
    );
  }

  // Inicializar o estado da plataforma e configurar o BackgroundFetch
  void initPlatformState() {
    BackgroundFetch.configure(BackgroundFetchConfig(
      minimumFetchInterval: 15, // Intervalo em minutos - mínimo 15 para iOS
      stopOnTerminate: false,
      startOnBoot: true,
      enableHeadless: true,
    ), (String taskId) {
      print('[BackgroundFetch] Evento em background: $taskId');
      // Aqui você chama sua função sendHeartbeat() ou similar
      sendHeartbeat();
      BackgroundFetch.finish(taskId);
    }).then((int status) {
      print('BackgroundFetch configurado com sucesso: $status');
    }).catchError((e) {
      print('Erro na configuração do BackgroundFetch: $e');
    });
  }
}

Future<void> sendHeartbeat() async {
  // Aqui você implementa o que precisa ser feito regularmente em background
  print('Heartbeat enviado');
}
