import 'package:cloud_firestore/cloud_firestore.dart';

class PortfolioItem {
  final String id;
  final String title;
  final String url;
  final String iconName;
  final bool isVisible;
  final int order;

  const PortfolioItem({
    required this.id,
    required this.title,
    required this.url,
    required this.iconName,
    required this.isVisible,
    required this.order,
  });

  factory PortfolioItem.fromMap(Map<String, dynamic> data) {
    return PortfolioItem(
      id: data['id'] as String? ?? '',
      title: data['title'] as String? ?? '',
      url: data['url'] as String? ?? '',
      iconName: data['iconName'] as String? ?? 'link',
      isVisible: data['isVisible'] as bool? ?? true,
      order: (data['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'iconName': iconName,
      'isVisible': isVisible,
      'order': order,
    };
  }

  PortfolioItem copyWith({
    String? id,
    String? title,
    String? url,
    String? iconName,
    bool? isVisible,
    int? order,
  }) {
    return PortfolioItem(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      iconName: iconName ?? this.iconName,
      isVisible: isVisible ?? this.isVisible,
      order: order ?? this.order,
    );
  }
}

class UserModel {
  static const Set<String> _universityDomains = {
    'ynu.jp',
    'keio.jp',
  };

  final String id; // Auth UID
  final String email;
  final String userName; // 表示名 (例: ユーザーA)
  final String? profileImageUrl;
  final String role; // student / guest
  final String accountType; // university / guest
  final String? university;
  final String? major;
  final List<PortfolioItem> portfolioItems;
  final List<Map<String, dynamic>> portfolioAchievements;
  final List<Map<String, dynamic>> portfolioSkills;
  final List<String> skillTags;
  final List<String> interestTags;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.userName,
    this.profileImageUrl,
    String? role,
    String? accountType,
    this.university,
    this.major,
    List<PortfolioItem>? portfolioItems,
    List<Map<String, dynamic>>? portfolioAchievements,
    List<Map<String, dynamic>>? portfolioSkills,
    required this.createdAt,
    required this.updatedAt,
    this.skillTags = const [],
    this.interestTags = const [],
  })  : role = role ?? 'guest',
        accountType = accountType ??
            ((role ?? 'guest') == 'student' ? 'university' : 'guest'),
        portfolioItems = portfolioItems ?? const [],
        portfolioAchievements = portfolioAchievements ?? const [],
        portfolioSkills = portfolioSkills ?? const [];

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final email = data['email'] ?? '';
    final resolvedRole = data['role'] ?? roleFromEmail(email);
    final rawPortfolioItems = data['portfolioItems'] as List<dynamic>? ?? [];
    final rawPortfolioAchievements = data['portfolioAchievements'];
    final rawPortfolioSkills = data['portfolioSkills'] as List<dynamic>? ?? [];
    return UserModel(
      id: doc.id,
      email: email,
      userName: data['userName'] ?? '名無しユーザー',
      profileImageUrl: data['profileImageUrl'],
      role: resolvedRole,
      accountType: data['accountType'] ?? accountTypeFromRole(resolvedRole),
      university: data['university'] as String?,
      major: data['major'] as String?,
      portfolioItems: rawPortfolioItems
          .whereType<Map<String, dynamic>>()
          .map(PortfolioItem.fromMap)
          .toList(),
      portfolioAchievements: _portfolioAchievementsFromFirestore(
        rawPortfolioAchievements,
      ),
      portfolioSkills:
          rawPortfolioSkills.whereType<Map<String, dynamic>>().toList(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      skillTags: List<String>.from(data['skillTags'] ?? []),
      interestTags: List<String>.from(data['interestTags'] ?? []),
    );
  }

  static bool isUniversityEmail(String email) {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      return false;
    }

    final domain = normalizedEmail.split('@').last;
    return domain.endsWith('.ac.jp') || _universityDomains.contains(domain);
  }

  static String roleFromEmail(String email) {
    return isUniversityEmail(email) ? 'student' : 'guest';
  }

  static String accountTypeFromRole(String role) {
    return role == 'student' ? 'university' : 'guest';
  }

  static String accountTypeFromEmail(String email) {
    return isUniversityEmail(email) ? 'university' : 'guest';
  }

  bool get isUniversityStudent => role == 'student';
  bool get canCreateCircle => role == 'student';
  bool get canSendDm => role == 'student';

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'userName': userName,
      'profileImageUrl': profileImageUrl,
      'role': role,
      'accountType': accountType,
      'university': university,
      'major': major,
      'portfolioItems': portfolioItems.map((item) => item.toMap()).toList(),
      'portfolioAchievements': portfolioAchievements,
      'portfolioSkills': portfolioSkills,
      'skillTags': skillTags,
      'interestTags': interestTags,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? userName,
    String? profileImageUrl,
    String? role,
    String? accountType,
    String? university,
    String? major,
    List<PortfolioItem>? portfolioItems,
    List<Map<String, dynamic>>? portfolioAchievements,
    List<Map<String, dynamic>>? portfolioSkills,
    List<String>? skillTags,
    List<String>? interestTags,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id,
      email: email,
      userName: userName ?? this.userName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      accountType: accountType ?? this.accountType,
      university: university ?? this.university,
      major: major ?? this.major,
      portfolioItems: portfolioItems ?? this.portfolioItems,
      portfolioAchievements:
          portfolioAchievements ?? this.portfolioAchievements,
      portfolioSkills: portfolioSkills ?? this.portfolioSkills,
      skillTags: skillTags ?? this.skillTags,
      interestTags: interestTags ?? this.interestTags,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static List<Map<String, dynamic>> _portfolioAchievementsFromFirestore(
    dynamic rawValue,
  ) {
    if (rawValue is List<dynamic>) {
      return rawValue.whereType<Map<String, dynamic>>().toList();
    }

    // Backward compatibility for the previous map-shaped draft structure.
    if (rawValue is Map<String, dynamic>) {
      return rawValue.entries.expand<Map<String, dynamic>>((entry) {
        return (entry.value as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .map((item) => {
                  ...item,
                  'category':
                      item['category'] ?? _categoryFromLegacyKey(entry.key),
                });
      }).toList();
    }

    return const [];
  }

  static String _categoryFromLegacyKey(String key) {
    if (key == 'events') return 'event';
    if (key == 'projects') return 'project';
    return 'leadership';
  }
}
