class Store {
  final int id;  // Use int instead of Long
  final String name;
  final String address;
  final double latitude; // Add latitude and longitude
  final double longitude;

  Store({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],  // Ensure id is parsed as int
      name: json['name'],
      address: json['address'],
      latitude: json['latitude']?.toDouble() ?? 0.0,  // Handle latitude and longitude
      longitude: json['longitude']?.toDouble() ?? 0.0,
    );
  }
}
