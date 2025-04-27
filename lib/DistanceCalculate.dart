import 'dart:convert';
import 'package:http/http.dart' as http;

class DistanceCalculator {
  static const String _baseUrl = 'https://api.distancematrix.ai/maps/api/distancematrix/json';
  static const String _apiKey = '2YTYevD0UhaPYfglrg7ZZwiL9tXEs8nGgSIEHTaMLdbkVpHMhIjDkv8kc4uuAaUP';

  static Future<double?> calculateDistance({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    final url = Uri.parse(
      '$_baseUrl'
          '?origins=$originLat,$originLng'
          '&destinations=$destLat,$destLng'
          '&key=$_apiKey',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['rows'] != null &&
            data['rows'][0]['elements'] != null &&
            data['rows'][0]['elements'][0]['status'] == 'OK') {
          final distanceInMeters = data['rows'][0]['elements'][0]['distance']['value'];
          final distanceInKm = distanceInMeters / 1000;
          return distanceInKm;
        } else {
          print('Error in response: ${data['rows'][0]['elements'][0]['status']}');
          return null;
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception occurred: $e');
      return null;
    }
  }
}
