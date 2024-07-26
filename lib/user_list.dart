import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'user_model.dart';
import 'add_user_page.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  late Future<List<User>> _users;
  List<User> _filteredUsers = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _users = DatabaseHelper.instance.getAllUsers();
    _users
        .then((users) => _filteredUsers = users); // Inisialisasi _filteredUsers
  }

  void refreshUserList() {
    setState(() {
      _users = DatabaseHelper.instance.getAllUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengguna'),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
                hintText: 'Cari Pengguna ...', prefixIcon: Icon(Icons.search)),
            onChanged: (text) {
              setState(() {
                _filteredUsers = _filteredUsers
                    .where((user) =>
                        user.email.toLowerCase().contains(text.toLowerCase()))
                    .toList();
                if (kDebugMode) {
                  print(_filteredUsers);
                }
              });
            },
          ),
        ),
        Expanded(
          child: FutureBuilder<List<User>>(
            future: _users,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    User user = snapshot.data![index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(user
                                  .foto), // Asumsikan user.foto adalah URL gambar
                              radius: 25,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user.email,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text('Peran: ${user.role}'),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                // Logika hapus pengguna
                                // Dapatkan ID pengguna yang ingin dihapus.
                                int? userId = user.id;
                                // Tampilkan dialog konfirmasi (opsional tapi direkomendasikan).
                                bool confirmDelete = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Konfirmasi Hapus'),
                                      content: const Text(
                                          'Apakah kamu yakin ingin menghapus pengguna ini?'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('Batal'),
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                        ),
                                        TextButton(
                                          child: const Text('Hapus'),
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                // Jika pengguna mengkonfirmasi, hapus pengguna.
                                if (confirmDelete == true) {
                                  int result = await DatabaseHelper.instance
                                      .deleteUser(userId!);
                                  if (result > 0) {
                                    // Pengguna berhasil dihapus, perbarui UI atau lakukan tindakan lain yang diperlukan.
                                    // Misalnya, kamu bisa memuat ulang daftar pengguna.
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Pengguna berhasil dihapus')),
                                    );
                                    refreshUserList();
                                  } else {
                                    // Terjadi kesalahan saat menghapus pengguna.
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Gagal menghapus pengguna')),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        )
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    AddUserPage(onUserAdded: refreshUserList)),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}






// ListTile(
//                     // ... (kita akan menambahkan detail pengguna di sini)
//                         title: Text(user.email),
//                         subtitle: Text('Peran: ${user.role}'),
//                         trailing: IconButton(
//                           icon: const Icon(Icons.delete),
//                           onPressed: () async {
//                             // Tambahkan logika untuk menghapus pengguna di sini
//                             bool confirmDelete = await showDialog(
//                               context: context,
//                               builder: (context) => AlertDialog(
//                                 title: const Text('Konfirmasi Hapus'),
//                                 content: const Text('Apakah Anda yakin ingin menghapus pengguna ini?'),
//                                 actions: [
//                                   TextButton(
//                                     onPressed: () => Navigator.pop(context, false),
//                                     child: const Text('Batal'),
//                                   ),
//                                   TextButton(
//                                     onPressed: () => Navigator.pop(context, true),
//                                     child: const Text('Hapus'),
//                                   ),
//                                 ],
//                               ),
//                             ) ?? false;
//                             if (confirmDelete) {
//                               // Hapus pengguna dari database
//                               await DatabaseHelper.instance.deleteUser(user.id);
//                               // Perbarui daftar pengguna
//                               setState(() {
//                                 _users = DatabaseHelper.instance.getAllUsers();
//                               });
//                             }
//                           },
//                         ),
//                     );