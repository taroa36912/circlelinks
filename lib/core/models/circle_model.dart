import 'package:cloud_firestore/cloud_firestore.dart';

class CircleModel {
  final String id;
  final String email;
  final String universityName;
  final String circleName;
  final String category;
  final String description;
  final int memberCount;
  final String? profileImageUrl;
  final String? coverImageUrl;
  final String? verificationDocumentUrl;
  final List<String> socialMediaLinks;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isVerified;
  final List<String> featureTags;
  final List<String> recruitmentTags;
  final bool isRecruiting;
  final String? recruitmentHeadline;

  CircleModel({
    required this.id,
    required this.email,
    required this.universityName,
    required this.circleName,
    required this.category,
    required this.description,
    required this.memberCount,
    this.profileImageUrl,
    this.coverImageUrl,
    this.verificationDocumentUrl,
    this.socialMediaLinks = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isVerified = false,
    this.featureTags = const [],
    this.recruitmentTags = const [],
    this.isRecruiting = false,
    this.recruitmentHeadline,
  });

  factory CircleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CircleModel(
      id: doc.id,
      email: data['email'] ?? '',
      universityName: data['universityName'] ?? '',
      circleName: data['circleName'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      memberCount: data['memberCount'] ?? 0,
      profileImageUrl: data['profileImageUrl'],
      coverImageUrl: data['coverImageUrl'],
      verificationDocumentUrl: data['verificationDocumentUrl'],
      socialMediaLinks: List<String>.from(data['socialMediaLinks'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isVerified: data['isVerified'] ?? false,
      featureTags: List<String>.from(data['featureTags'] ?? []),
      recruitmentTags: List<String>.from(data['recruitmentTags'] ?? []),
      isRecruiting: data['isRecruiting'] ?? false,
      recruitmentHeadline: data['recruitmentHeadline'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'universityName': universityName,
      'circleName': circleName,
      'category': category,
      'description': description,
      'memberCount': memberCount,
      'profileImageUrl': profileImageUrl,
      'coverImageUrl': coverImageUrl,
      'verificationDocumentUrl': verificationDocumentUrl,
      'socialMediaLinks': socialMediaLinks,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isVerified': isVerified,
      'featureTags': featureTags,
      'recruitmentTags': recruitmentTags,
      'isRecruiting': isRecruiting,
      'recruitmentHeadline': recruitmentHeadline,
    };
  }

  CircleModel copyWith({
    String? id,
    String? email,
    String? universityName,
    String? circleName,
    String? category,
    String? description,
    int? memberCount,
    String? profileImageUrl,
    String? coverImageUrl,
    String? verificationDocumentUrl,
    List<String>? socialMediaLinks,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    List<String>? featureTags,
    List<String>? recruitmentTags,
    bool? isRecruiting,
    String? recruitmentHeadline,
  }) {
    return CircleModel(
      id: id ?? this.id,
      email: email ?? this.email,
      universityName: universityName ?? this.universityName,
      circleName: circleName ?? this.circleName,
      category: category ?? this.category,
      description: description ?? this.description,
      memberCount: memberCount ?? this.memberCount,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      verificationDocumentUrl:
          verificationDocumentUrl ?? this.verificationDocumentUrl,
      socialMediaLinks: socialMediaLinks ?? this.socialMediaLinks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      featureTags: featureTags ?? this.featureTags,
      recruitmentTags: recruitmentTags ?? this.recruitmentTags,
      isRecruiting: isRecruiting ?? this.isRecruiting,
      recruitmentHeadline: recruitmentHeadline ?? this.recruitmentHeadline,
    );
  }
}
