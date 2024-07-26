import 'package:flutter/material.dart';
import 'database_helper.dart'; // Ganti dengan path yang sesuai
import 'user_model.dart'; // Ganti dengan path yang sesuai
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  final int userId; // User ID untuk mengambil data pengguna

  const ProfilePage({super.key, required this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = await DatabaseHelper.instance.getUserProfile(widget.userId);
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user profile: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    Navigator.pushReplacementNamed(
        context, '/login'); // Arahkan ke halaman login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? const Center(child: Text('User not found'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(_user!.foto),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'Email: ${_user!.email}',
                        style: const TextStyle(fontSize: 18.0),
                      ),
                      Text(
                        'Role: ${_user!.role}',
                        style: const TextStyle(fontSize: 18.0),
                      ),
                    ],
                  ),
                ),
    );
  }
}
