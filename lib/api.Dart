import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tele_tudo_app/models/delivery_details.dart';

class API {

  static Future<bool> respondToDelivery(int userId, int deliveryId, bool accept) async {
    try {
      var url = Uri.parse("https://teletudo.com/api/respondToDelivery");
      var payload = json.encode({
        'userId': userId,
        'deliveryId': deliveryId,
        'accept': accept,
      });
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: payload,
      );
      print("response.statusCode = ${response.statusCode}");
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print("Envio de respondToDelivery com sucesso");
        return true;
      } else {
        print("Falha ao enviar resposta: ${response.statusCode}, ${response.body.length > 300 ? response.body.substring(0, 300) : response.body}");
        return false;
      }
    } catch (e) {
      print("Erro ao enviar resposta de entrega: $e");
      return false;
    }
  }

  static Future<void> reportViewToServer(int? userid, int? chamado) async {
    try {
      await http.post(
        Uri.parse('https://teletudo.com/api/mtoviu'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'chamadoId': chamado,
          'motoboyId': userid, 
        }),
      );
      print("Visualização reportada ao servidor com sucesso.");
    } catch (e) {
      print("Erro ao reportar visualização: $e");
    }
  }

  static Future<DeliveryDetails?> sendHeartbeat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userid = prefs.getInt('idUser');
    double lat = 0.0;
    double lon = 0.0;
    int vez = prefs.getInt('vez') ?? 0;
    await prefs.setInt('vez', vez + 1);
    if (userid != null) {
      String baseUrl = "https://teletudo.com/api/heartbeat";
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'userid': userid,
          'lat': lat,
          'lon': lon,
          'vez': vez
        }),
      );
      if (response.statusCode == 200) {
        print('Response Body: ${response.body}');
        var data = json.decode(response.body);
        int modo = data['modo'] ?? 3;
        await prefs.setInt('modo', modo);
        return DeliveryDetails.fromJson(data);
      } else {
        print('Erro ao enviar heartbeat');
      }
    }
    return null;
  }

  static Future<bool> veLogin(String user, String password, double lat, double lon) async {
    String baseUrl = "https://teletudo.com/api/login";
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'user': user,
        'password': password,
        'lat': lat, 
        'lon': lon, 
      }),
    );
    if (response.statusCode == 200) {
      print('200');
      var ret = json.decode(response.body);
      final int erro = ret["Erro"] ?? 1;
      if (erro == 0) {
        final int idUser = ret["id"] ?? 0;
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('idUser', idUser);
        return true;
      } else {
        return false;
      }
    } else {
      print('return false');
      return false;
    }
  }

  static Future<bool> registerUser(String nome, String email, String senha, String telefone, String cnh, String placa, String PIX) async {
  String baseUrl = "https://teletudo.com/api/cadboy";
  final response = await http.post(
    Uri.parse(baseUrl),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: json.encode({
      'nome_completo': nome,
      'email': email,
      'senha': senha,
      'telefone': telefone,
      'cnh': cnh,
      'placa': placa,
      'PIX': PIX
    }),
  );
  if (response.statusCode == 200 || response.statusCode == 201) {
    final ret = json.decode(response.body);    
    final int idUser = ret["id"] ?? 0; 
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('idUser', idUser);
    return true;
  } else {
    return false;
  }
}

  static Future<bool> notifyPickedUp() async {
    print("Entrou na API notifyPickedUp");
    try {
      String baseUrl = "https://teletudo.com/api/notifyPickedUp";
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int? currentChamado = prefs.getInt('currentChamado');
      print("chamado = "+currentChamado.toString());
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'chamado': currentChamado
        }),
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
          print("Sucesso ao notificar o servidor: ${response.body}");
          return true;
        } else {
          print("Falha ao notificar o servidor: ${response.body}");
          return false;
        }
    } catch (e) {
      print("Erro na chamada API: $e");
      return false;
    }
  }

  static Future<bool> notifyDeliveryCompleted() async {
    print("Entrou na API notifyDeliveryCompleted");
    try {
      String baseUrl = "https://teletudo.com/api/notifyDeliveryCompleted";
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int? currentChamado = prefs.getInt('currentChamado');
      print("chamado = "+currentChamado.toString());
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'chamado': currentChamado
        }),
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        print("Sucesso ao notificar o servidor: ${response.body}");
        return true;
      } else {
        print("Falha ao notificar o servidor: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Erro na chamada API: $e");
      return false;
    }
  }

}  


