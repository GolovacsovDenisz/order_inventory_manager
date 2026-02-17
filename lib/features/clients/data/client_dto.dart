import '../domain/client.dart';

class ClientDto {
  final String id;
  final String name;
  final String? phone;
  final String? notes;
  final String? email;

  ClientDto({
    required this.id,
    required this.name,
    this.phone,
    this.notes,
    this.email,
  });

  factory ClientDto.fromJson(Map<String, dynamic> json) {
    return ClientDto(
      id: json['id'].toString(),
      name: (json['name'] ?? '').toString(),
      phone: json['phone']?.toString(),
      notes: json['notes']?.toString(),
      email: json['email']?.toString(),
    );
  }

  Client toDomain() {
    return Client(
      id: id,
      name: name,
      phone: phone,
      notes: notes,
      email: email,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'notes': notes,
      'email': email,
    };
  }
}
