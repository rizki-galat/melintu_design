import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart'; // Tambahkan import ini jika belum ada
import 'user_list.dart';
import 'order_list_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int? _userId;
  String? _userRole; // Menyimpan role pengguna
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndRole();
  }

  Future<void> _loadUserIdAndRole() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId != null) {
      final user = await DatabaseHelper.instance.getUserById(userId);
      setState(() {
        _userId = userId;
        _userRole = user?.role; // Ambil role dari pengguna
        _isLoading = false;
      });
    } else {
      setState(() {
        _userId = null;
        _userRole = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_userId == null) {
      return const Scaffold(
        body: Center(child: Text('User not found. Please log in again.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Melintu Desain'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _userRole == 'admin'
            ? const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.list),
                  label: 'Order',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: 'User',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ]
            : const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.list),
                  label: 'Order',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  List<Widget> get _widgetOptions => <Widget>[
        const OrderListPage(),
        if (_userRole == 'admin') const UserList(),
        if (_userId != null) ProfilePage(userId: _userId!),
      ];
}
