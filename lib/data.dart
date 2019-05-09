class Ticket {
  bool valid;
  String validateId;
  DateTime usedAt;
  int id;
  DateTime createdAt;
  DateTime updatedAt;
  int changedBy;

  Ticket();

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket()
      ..valid = json["valid_"] as bool
      ..validateId = json["validate_id"] as String
      //..usedAt = DateTime.parse(json["used_at"]) TODO parse if datetime present
      ..id = json["id"] as int
      ..createdAt = DateTime.parse(json["created_at"])
      ..updatedAt = DateTime.parse(json["updated_at"])
      ..changedBy = json["changed_by"] as int;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'valid_': this.valid,
        'validate_id': this.validateId,
        'used_at': this.usedAt,
        'id': this.id,
        'created_at': this.createdAt,
        'updated_at': this.updatedAt,
        'changed_by': this.changedBy
      };
}

class User {
  int id;
  String name;
  int rank;
  bool admin;
  bool enabled;
  String email;
  DateTime createdAt;
  DateTime updatedAt;
  String role;

  User();

  factory User.fromJson(Map<String, dynamic> json) {
    return User()
      ..id = json["id"] as int
      ..name = json["name"] as String
      ..rank = json["rank"] as int
      ..admin = json["admin"] as bool
      ..enabled = json["enabled"] as bool
      ..email = json["email"] as String
      ..createdAt = DateTime.parse(json["created_at"])
      ..updatedAt = DateTime.parse(json["updated_at"])
      ..role = json["role"] as String;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': this.id,
        'name': this.name,
        'rank': this.rank,
        'admin': this.admin,
        'enabled': this.enabled,
        'email': this.email,
        'created_at': this.createdAt.toIso8601String(),
        'updated_at': this.updatedAt.toIso8601String(),
        'role': this.role
      };
}

class ValidationException implements Exception {
  String message;
  int code;

  ValidationException(this.message, this.code);
}

class TicketValidationException extends ValidationException {
  String validationId;
  int ticketId;

  TicketValidationException(String message, int code, this.validationId, this.ticketId) : super(message, code);
}

class UserValidationException extends ValidationException {
  String email;

  UserValidationException(String message, int code, this.email) : super(message, code);
}
