class RegistrationZone {
  int? id;
  String? name;
  RegistrationGovernorate? governorate;
  bool? deleted;
  String? creationDate;

  RegistrationZone({
    this.id,
    this.name,
    this.governorate,
    this.deleted,
    this.creationDate,
  });

  factory RegistrationZone.fromJson(Map<String, dynamic> json) {
    return RegistrationZone(
      id: json['id'],
      name: json['name'],
      governorate: json['governorate'] != null
          ? RegistrationGovernorate.fromJson(json['governorate'])
          : null,
      deleted: json['deleted'],
      creationDate: json['creationDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'governorate': governorate?.toJson(),
      'deleted': deleted,
      'creationDate': creationDate,
    };
  }

  @override
  String toString() {
    return 'RegistrationZone(id: $id, name: $name, governorate: ${governorate?.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RegistrationZone && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class RegistrationGovernorate {
  int? id;
  String? name;
  bool? deleted;
  String? creationDate;

  RegistrationGovernorate({
    this.id,
    this.name,
    this.deleted,
    this.creationDate,
  });

  factory RegistrationGovernorate.fromJson(Map<String, dynamic> json) {
    return RegistrationGovernorate(
      id: json['id'],
      name: json['name'],
      deleted: json['deleted'],
      creationDate: json['creationDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'deleted': deleted,
      'creationDate': creationDate,
    };
  }

  @override
  String toString() {
    return 'RegistrationGovernorate(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RegistrationGovernorate && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}