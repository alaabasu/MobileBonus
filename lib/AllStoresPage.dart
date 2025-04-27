import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:api_assigment1/Store.dart';
import 'package:api_assigment1/DistanceCalculate.dart'; // Import the distance calculator

class AllStoresPage extends StatefulWidget {
  final int userId;

  const AllStoresPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<AllStoresPage> createState() => _AllStoresPageState();
}

class _AllStoresPageState extends State<AllStoresPage> {
  List<Store> _stores = [];
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchStores();
  }

  Future<void> _fetchStores() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8080/api/stores'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          _stores = data.map((json) => Store.fromJson(json)).toList();
        });
      } else {
        setState(() {
          _error = 'Failed to load stores';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addToFavorites(int storeId) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/favorites/${widget.userId}/$storeId'),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to favorites')),
        );
      } else if (response.statusCode == 409) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Already in favorites')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _calculateDistance(double storeLat, double storeLon) async {
    try {
      // Get current location (user's location)
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      // Call Distance API (calculating distance between user's location and store's location)
      final distance = await DistanceCalculator.calculateDistance(
        originLat: position.latitude,  // User's Latitude
        originLng: position.longitude, // User's Longitude
        destLat: storeLat,             // Store's Latitude
        destLng: storeLon,             // Store's Longitude
      );

      // Show calculated distance
      if (distance != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Distance: ${distance.toStringAsFixed(2)} km')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to calculate distance')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Stores'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error.isNotEmpty
            ? Center(child: Text(_error))
            : ListView.builder(
          itemCount: _stores.length,
          itemBuilder: (context, index) {
            final store = _stores[index];
            return ListTile(
              title: Text(store.name),
              subtitle: Text(store.address),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.star_border),
                    onPressed: () => _addToFavorites(store.id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.location_on),
                    onPressed: () => _calculateDistance(store.latitude, store.longitude),
                  ),
                ],
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(store.name),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Address: ${store.address}'),
                          Text('Latitude: ${store.latitude}'),
                          Text('Longitude: ${store.longitude}'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
