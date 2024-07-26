class User {
  final int? id; // Tambahkan properti id
  final String email;
  final String password;
  final String role;
  final String foto;

  User({
    this.id,
    required this.email,
    required this.password,
    required this.role,
    required this.foto,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'role': role,
      'foto': foto
    };
  }

  static User fromMap(Map<String, dynamic> first) {
    return User(
        id: first['id'],
        email: first['email'],
        password: first['password'],
        role: first['role'],
        foto: first['foto']);
  }
}
