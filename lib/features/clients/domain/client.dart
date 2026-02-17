class Client {
  final String id;
  final String name;
  final String? phone;
  final String? notes;
  final String? email;

  const Client({
    required this.id,
    required this.name,
    this.phone,
    this.notes,
    this.email,
  });

  Client copyWith({
    String? id,
    String? name,
    String? phone,
    String? notes,
    String? email,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      email: email ?? this.email,
    );
  }
}
