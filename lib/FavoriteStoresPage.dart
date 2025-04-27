import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FavoriteStore {
  final int id;
  final Store store;

  FavoriteStore({required this.id, required this.store});

  factory FavoriteStore.fromJson(Map<String, dynamic> json) {
    return FavoriteStore(
      id: json['id'],
      store: Store.fromJson(json['store']),
    );
  }
}

class Store {
  final int id;
  final String name;
  final String address;

  Store({required this.id, required this.name, required this.address});

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      name: json['name'],
      address: json['address'],
    );
  }
}

class FavoriteStoresPage extends StatefulWidget {
  final int userId;

  const FavoriteStoresPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<FavoriteStoresPage> createState() => _FavoriteStoresPageState();
}

class _FavoriteStoresPageState extends State<FavoriteStoresPage> {
  List<FavoriteStore> _favorites = [];
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/favorites/${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _favorites = data.map((e) => FavoriteStore.fromJson(e)).toList();
        });
      } else {
        setState(() {
          _error = 'Failed to load favorites: ${response.body}';
        });
      }
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error.isNotEmpty) return Center(child: Text(_error));

    return ListView.builder(
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final store = _favorites[index].store;
        return ListTile(
          title: Text(store.name),
          subtitle: Text(store.address),
        );
      },
    );
  }
}
