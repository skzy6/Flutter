import 'package:dio/dio.dart';

Dio dio = Dio();

class NetUnit {
  static Future<String> get({String url}) async {
    var c = await dio.get(url);
    return c.data.toString();
  }
}
