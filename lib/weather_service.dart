import 'dart:convert';
import 'package:http/http.dart' as http;
import 'main.dart'; // ใช้ TempUnit

// ใส่คีย์ของคุณตรงนี้
const String apiKey = 'c35de01d10f0f11a3b6f659459f4fd0c';

class WeatherService {
  static const _host = 'api.openweathermap.org';
  static const _path = '/data/2.5/weather';

  static Map<String, String> _baseParams(TempUnit unit) {
    final m = <String, String>{'appid': apiKey};
    final u = unit.api;
    if (u != null) m['units'] = u;
    return m;
  }

  static Future<Map<String, dynamic>> _get(Map<String, String> params) async {
    final uri = Uri.https(_host, _path, params);
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> byCityCountry({
    required String city,
    required String country,
    required TempUnit unit,
  }) =>
      _get({'q': '$city,$country', ..._baseParams(unit)});

  static Future<Map<String, dynamic>> byZipCountry({
    required String zip,
    required String country,
    required TempUnit unit,
  }) =>
      _get({'zip': '$zip,$country', ..._baseParams(unit)});

  static Future<Map<String, dynamic>> byLatLon({
    required double lat,
    required double lon,
    required TempUnit unit,
  }) =>
      _get({'lat': '$lat', 'lon': '$lon', ..._baseParams(unit)});
}
