import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import '../../core/models/member_model.dart';
import '../../core/models/user_model.dart';

class CircleManagementScreen extends ConsumerStatefulWidget {
  final CircleModel circle;

  const CircleManagementScreen({
    super.key,
    required this.circle,
  });

  @override
  ConsumerState<CircleManagementScreen> createState() =>
      _CircleManagementScreenState();
}

class _CircleManagementScreenState
    extends ConsumerState<CircleManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _circleNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _memberCountController;
  late TextEditingController _universityController;

  String? _selectedCategory;
  bool _isLoading = false;

  File? _profileImageFile;
  Uint8List? _profileImageBytes;
  File? _coverImageFile;
  Uint8List? _coverImageBytes;

  bool _isRecruiting = false;
  late TextEditingController _recruitmentHeadlineController;
  late TextEditingController _recruitmentTagsController;
  late TextEditingController _featureTagsController;

  final List<String> _categories = [
    'Sports',
    'Culture',
    'Arts',
    'Academic',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _circleNameController =
        TextEditingController(text: widget.circle.circleName);
    _descriptionController =
        TextEditingController(text: widget.circle.description);
    _memberCountController =
        TextEditingController(text: widget.circle.memberCount.toString());
    _universityController =
        TextEditingController(text: widget.circle.universityName);

    _isRecruiting = widget.circle.isRecruiting;
    _recruitmentHeadlineController =
        TextEditingController(text: widget.circle.recruitmentHeadline ?? '');
    _recruitmentTagsController = TextEditingController(
        text: widget.circle.recruitmentTags.join(', '));
    _featureTagsController =
        TextEditingController(text: widget.circle.featureTags.join(', '));

    _selectedCategory = widget.circle.category;
    if (!_categories.contains(_selectedCategory)) {
      _selectedCategory = 'Other';
    }
  }

  @override
  void dispose() {
    _circleNameController.dispose();
    _descriptionController.dispose();
    _memberCountController.dispose();
    _universityController.dispose();
    _recruitmentHeadlineController.dispose();
    _recruitmentTagsController.dispose();
    _featureTagsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage({required bool isProfile}) async {
    try {
      final picker = ImagePicker();
      final pickedFile =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          if (isProfile) {
            _profileImageFile = File(pickedFile.path);
            _profileImageBytes = bytes;
          } else {
            _coverImageFile = File(pickedFile.path);
            _coverImageBytes = bytes;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('画像の選択に失敗しました'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _updateCircle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final storageService = ref.read(firebaseStorageServiceProvider);
      final firestoreService = ref.read(firestoreServiceProvider);

      String? profileImageUrl = widget.circle.profileImageUrl;
      String? coverImageUrl = widget.circle.coverImageUrl;

      if (kIsWeb && _profileImageBytes != null) {
        final path =
            storageService.generateImagePath(widget.circle.id, 'profile');
        profileImageUrl = await storageService.uploadImage(
            bytes: _profileImageBytes!, path: path);
      } else if (!kIsWeb && _profileImageFile != null) {
        final path =
            storageService.generateImagePath(widget.circle.id, 'profile');
        profileImageUrl = await storageService.uploadImage(
            imageFile: _profileImageFile!, path: path);
      }

      if (kIsWeb && _coverImageBytes != null) {
        final path =
            storageService.generateImagePath(widget.circle.id, 'cover');
        coverImageUrl = await storageService.uploadImage(
            bytes: _coverImageBytes!, path: path);
      } else if (!kIsWeb && _coverImageFile != null) {
        final path =
            storageService.generateImagePath(widget.circle.id, 'cover');
        coverImageUrl = await storageService.uploadImage(
            imageFile: _coverImageFile!, path: path);
      }

      final updatedCircle = widget.circle.copyWith(
        circleName: _circleNameController.text.trim(),
        description: _descriptionController.text.trim(),
        memberCount: int.tryParse(_memberCountController.text.trim()) ?? 0,
        universityName: _universityController.text.trim(),
        category: _selectedCategory ?? 'Other',
        profileImageUrl: profileImageUrl,
        coverImageUrl: coverImageUrl,
        updatedAt: DateTime.now(),
        isRecruiting: _isRecruiting,
        recruitmentHeadline: _recruitmentHeadlineController.text.trim().isNotEmpty
            ? _recruitmentHeadlineController.text.trim()
            : null,
        recruitmentTags:
            _recruitmentTagsController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
        featureTags:
            _featureTagsController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
      );

      await firestoreService.updateCircle(updatedCircle);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('サークル情報を更新しました'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新に失敗しました: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleMemberAction(
      String action, MemberModel member, String targetUserId, String displayName) async {
    final firestoreService = ref.read(firestoreServiceProvider);

    try {
      if (action == 'toggle_role') {
        final newRole = member.role == 'admin' ? 'member' : 'admin';
        await firestoreService.updateCircleMemberRole(
            widget.circle.id, targetUserId, newRole);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('権限を変更しました')),
          );
        }
      } else if (action == 'remove') {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('メンバーの削除'),
            content: Text('$displayName さんをサークルから追放しますか？'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('キャンセル')),
              TextButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('削除', style: TextStyle(color: Colors.red))),
            ],
          ),
        );

        if (confirm == true) {
          await firestoreService.removeCircleMember(
              widget.circle.id, targetUserId);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('メンバーを削除しました')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作に失敗しました: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildMemberManagementSection(ThemeData theme) {
    final firestoreService = ref.read(firestoreServiceProvider);
    final currentUserId =
        ref.read(firebaseAuthServiceProvider).currentUser?.uid;

    return StreamBuilder<List<MemberModel>>(
      stream: firestoreService.getCircleMembersStream(widget.circle.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
        }

        final members = snapshot.data ?? [];
        if (members.isEmpty) {
          return const Center(child: Text('メンバーがいません'));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            final memberUserId =
                member.userId.trim().isNotEmpty ? member.userId : member.id;
            final isMe = memberUserId == currentUserId;

            return FutureBuilder<UserModel?>(
              future: firestoreService.getUser(memberUserId),
              builder: (context, userSnapshot) {
                String displayName = '読み込み中...';
                String? profileUrl;

                if (userSnapshot.connectionState == ConnectionState.done) {
                  if (userSnapshot.hasError) {
                    displayName = 'エラー';
                  } else {
                    final user = userSnapshot.data;
                    if (user != null) {
                      final hasUserName = user.userName.trim().isNotEmpty;
                      displayName = hasUserName
                          ? user.userName
                          : (user.email.trim().isNotEmpty
                              ? user.email
                              : '不明なユーザー');
                      profileUrl = user.profileImageUrl;
                    } else {
                      displayName = 'ユーザーが見つかりません';
                    }
                  }
                }

                return Card(
                  elevation: 1,
                  margin: EdgeInsets.only(bottom: 1.h),
                  child: ListTile(
                    leading: SafeAvatarWidget(
                      imageUrl: profileUrl,
                      radius: 20,
                      fallback: const Icon(Icons.person),
                    ),
                    title: Text(displayName,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(member.role == 'admin' ? '管理者' : '一般メンバー'),
                    trailing: isMe
                        ? const Chip(label: Text('あなた'))
                        : IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (sheetContext) => SafeArea(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: const Icon(Icons.manage_accounts),
                                        title: Text(member.role == 'admin'
                                            ? '一般メンバーに降格'
                                            : '管理者に昇格'),
                                        onTap: () {
                                          Navigator.pop(sheetContext);
                                          _handleMemberAction('toggle_role', member, memberUserId, displayName);
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.person_remove, color: Colors.red),
                                        title: const Text('サークルから削除',
                                            style: TextStyle(color: Colors.red)),
                                        onTap: () {
                                          Navigator.pop(sheetContext);
                                          _handleMemberAction('remove', member, memberUserId, displayName);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.circle.circleName} の管理'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.connections,
                        arguments: {'circleId': widget.circle.id});
                  },
                  icon: const Icon(Icons.people_outline),
                  label: const Text('サークル間コネクション管理'),
                  style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h)),
                ),
              ),
              SizedBox(height: 2.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.circleDmList,
                        arguments: {'circleId': widget.circle.id});
                  },
                  icon: const Icon(Icons.mail_outline),
                  label: const Text('このサークルへのDMを確認する'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    foregroundColor: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              const Divider(),
              SizedBox(height: 2.h),
              Text('基本情報の編集',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              SizedBox(height: 3.h),
              TextFormField(
                controller: _circleNameController,
                decoration: const InputDecoration(labelText: 'サークル名'),
                validator: (value) => value!.isEmpty ? '入力してください' : null,
              ),
              SizedBox(height: 2.h),
              TextFormField(
                controller: _universityController,
                decoration: const InputDecoration(labelText: '大学名'),
                validator: (value) => value!.isEmpty ? '入力してください' : null,
              ),
              SizedBox(height: 2.h),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: 'カテゴリー'),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                      value: category, child: Text(category));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              SizedBox(height: 2.h),
              TextFormField(
                controller: _memberCountController,
                decoration: const InputDecoration(labelText: 'メンバー数'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 2.h),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: '活動内容'),
                maxLines: 5,
              ),
              SizedBox(height: 4.h),
              const Divider(),
              SizedBox(height: 2.h),
              Text('画像の設定',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              SizedBox(height: 2.h),
              Text('カバー画像',
                  style:
                      theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
              SizedBox(height: 1.h),
              GestureDetector(
                onTap: () => _pickImage(isProfile: false),
                child: Container(
                  height: 20.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _coverImageBytes != null
                        ? Image.memory(_coverImageBytes!, fit: BoxFit.cover)
                        : _coverImageFile != null
                            ? Image.file(_coverImageFile!, fit: BoxFit.cover)
                            : widget.circle.coverImageUrl != null
                                ? Image.network(
                                    widget.circle.coverImageUrl!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 20.h,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Center(
                                                child: Icon(
                                                    Icons.add_photo_alternate,
                                                    size: 50,
                                                    color: Colors.grey)),
                                  )
                                : const Center(
                                    child: Icon(Icons.add_photo_alternate,
                                        size: 50, color: Colors.grey)),
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              Text('プロフィール画像',
                  style:
                      theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
              SizedBox(height: 1.h),
              GestureDetector(
                onTap: () => _pickImage(isProfile: true),
                child: _profileImageBytes != null
                    ? CircleAvatar(
                        radius: 12.w,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        backgroundImage: MemoryImage(_profileImageBytes!),
                      )
                    : _profileImageFile != null
                        ? CircleAvatar(
                            radius: 12.w,
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                            backgroundImage: FileImage(_profileImageFile!),
                          )
                        : SafeAvatarWidget(
                            imageUrl: widget.circle.profileImageUrl,
                            radius: 12.w,
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                            fallback: Icon(Icons.group,
                                size: 12.w, color: Colors.grey),
                          ),
              ),
              SizedBox(height: 4.h),
              const Divider(),
              SizedBox(height: 2.h),
              Text('募集・タグ設定',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              SizedBox(height: 2.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                        context, AppRoutes.recruitmentManagement,
                        arguments: {'circleId': widget.circle.id});
                  },
                  icon: const Icon(Icons.campaign),
                  label: const Text('新規メンバー募集を管理'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              SwitchListTile(
                title: const Text('募集中にする'),
                value: _isRecruiting,
                onChanged: (v) => setState(() => _isRecruiting = v),
              ),
              TextFormField(
                controller: _recruitmentHeadlineController,
                decoration: const InputDecoration(
                    labelText: '募集見出し',
                    hintText: '例: 一緒に活動する仲間を募集中！'),
              ),
              SizedBox(height: 2.h),
              TextFormField(
                controller: _recruitmentTagsController,
                decoration: const InputDecoration(
                    labelText: '募集タグ',
                    hintText: 'カンマ区切り 例: 新歓,初心者歓迎'),
              ),
              SizedBox(height: 2.h),
              TextFormField(
                controller: _featureTagsController,
                decoration: const InputDecoration(
                    labelText: '特徴タグ',
                    hintText: 'カンマ区切り 例: アットホーム,全国大会出場'),
              ),
              SizedBox(height: 4.h),
              const Divider(),
              SizedBox(height: 2.h),
              Text('メンバー管理',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              SizedBox(height: 2.h),
              _buildMemberManagementSection(theme),
              SizedBox(height: 4.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateCircle,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('変更を保存'),
                ),
              ),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }
}