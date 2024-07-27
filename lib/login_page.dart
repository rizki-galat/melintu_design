import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _emailController = TextEditingController();
final _passwordController = TextEditingController();

class LoginPage extends StatefulWidget {
  final void Function(BuildContext) onLoginSuccess;
  final void Function(bool) onLoginProcess;

  const LoginPage({
    super.key,
    required this.onLoginSuccess,
    required this.onLoginProcess,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true; // Tambahkan variabel ini

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE0F7FA),
              Color(0xFF2962FF),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png'),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscureText, // Gunakan variabel ini
                  decoration: InputDecoration(
                    hintText: 'Password',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText; // Ubah nilai obscureText
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  String email = _emailController.text;
                  String password = _passwordController.text;
                  if (email.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Email dan password harus diisi.')),
                    );
                    return;
                  }
                  widget.onLoginProcess(true);

                  Map<String, dynamic>? adminInfo =
                      await DatabaseHelper.instance.isAdmin(email);

                  if (adminInfo != null) {
                    debugPrint('Login berhasil sebagai admin!');
                    _saveUserId(adminInfo['id']); // Simpan userId 0 untuk admin
                    Navigator.pushReplacementNamed(
                        context, '/home'); // Arahkan ke halaman home
                  } else {
                    User? user =
                        await DatabaseHelper.instance.getUserByEmail(email);
                    debugPrint('User ditemukan: ${user != null}');
                    if (user != null && user.password == password) {
                      debugPrint('Login berhasil sebagai pengguna!');
                      _saveUserId(user.id);
                      Navigator.pushReplacementNamed(
                          context, '/home'); // Arahkan ke halaman home
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Login Gagal'),
                          content: const Text('Email atau password salah.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                  widget.onLoginProcess(false);
                },
                child:
                    const Text('Login', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveUserId(int? userId) async {
    final prefs = await SharedPreferences.getInstance();
    if (userId != null) {
      await prefs.setInt('userId', userId);
    }
  }
}
