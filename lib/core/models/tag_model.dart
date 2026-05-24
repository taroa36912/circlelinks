import 'package:cloud_firestore/cloud_firestore.dart';

class TagModel {
  final String id;
  final String name;
  final String type;
  final String? description;
  final String? colorHex;
  final String? iconName;
  final String? circleId;
  final DateTime createdAt;
  final DateTime updatedAt;

  TagModel({
    required this.id,
    required this.name,
    this.type = 'skill',
    this.description,
    this.colorHex,
    this.iconName,
    this.circleId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TagModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TagModel(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? 'skill',
      description: data['description'],
      colorHex: data['colorHex'],
      iconName: data['iconName'],
      circleId: data['circleId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type,
      'description': description,
      'colorHex': colorHex,
      'iconName': iconName,
      'circleId': circleId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  TagModel copyWith({
    String? id,
    String? name,
    String? type,
    String? description,
    String? colorHex,
    String? iconName,
    String? circleId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TagModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      colorHex: colorHex ?? this.colorHex,
      iconName: iconName ?? this.iconName,
      circleId: circleId ?? this.circleId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
