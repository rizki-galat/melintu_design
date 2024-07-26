import 'dart:io';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'user_model.dart';
import 'package:image_picker/image_picker.dart';

class AddUserPage extends StatefulWidget {
  final VoidCallback onUserAdded;

  const AddUserPage(
      {super.key, required this.onUserAdded}); // Tambahkan key pada konstruktor

  @override
  AddUserPageState createState() => AddUserPageState();
}

class AddUserPageState extends State<AddUserPage> {
  // Ubah dari _AddUserPage menjadi AddUserPage
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = 'user'; // Nilai default
  XFile? _imageFile;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Tambah Pengguna'),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan email';
                      }
                      if (!value.contains('@')) {
                        return 'Masukkan email yang valid';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan password';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: _role,
                    decoration: const InputDecoration(labelText: 'Peran'),
                    items: const [
                      DropdownMenuItem(value: 'user', child: Text('User')),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _role = value!;
                      });
                    },
                  ),
                  // Widget untuk menampilkan gambar yang dipilih
                  if (_imageFile != null) Image.file(File(_imageFile!.path)),
                  // Tombol untuk memilih gambar dari galeri
                  ElevatedButton(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    child: const Text('Pilih dari Galeri'),
                  ),
                  // Tombol untuk memilih gambar dari kamera
                  ElevatedButton(
                    onPressed: () => _pickImage(ImageSource.camera),
                    child: const Text('Ambil Foto'),
                  ),

                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Simpan pengguna ke database
                        User newUser = User(
                          email: _emailController.text,
                          password: _passwordController.text,
                          role: _role,
                          foto: '', // Ganti dengan URL foto jika diperlukan
                        );
                        await DatabaseHelper.instance.insertUser(newUser);
                        // Panggil callback untuk memperbarui daftar pengguna
                        widget.onUserAdded();
                        // Navigasi kembali ke halaman UserList
                        if (mounted) Navigator.pop(context);
                      }
                    },
                    child: const Text('Simpan'),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
