import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';

class CircleManagementScreen extends ConsumerStatefulWidget {
  final CircleModel circle;

  const CircleManagementScreen({
    super.key,
    required this.circle,
  });

  @override
  ConsumerState<CircleManagementScreen> createState() => _CircleManagementScreenState();
}

class _CircleManagementScreenState extends ConsumerState<CircleManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _circleNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _memberCountController;
  late TextEditingController _universityController;
  
  String? _selectedCategory;
  bool _isLoading = false;

  // 画像アップロード用変数
  File? _profileImageFile;
  Uint8List? _profileImageBytes;
  File? _coverImageFile;
  Uint8List? _coverImageBytes;

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
    _circleNameController = TextEditingController(text: widget.circle.circleName);
    _descriptionController = TextEditingController(text: widget.circle.description);
    _memberCountController = TextEditingController(text: widget.circle.memberCount.toString());
    _universityController = TextEditingController(text: widget.circle.universityName);
    
    // カテゴリの初期値設定（リストにない場合は 'Other' にする）
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
    super.dispose();
  }

  // --- 画像選択メソッド ---
  Future<void> _pickImage({required bool isProfile}) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      
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
        const SnackBar(content: Text('画像の選択に失敗しました'), backgroundColor: Colors.red),
      );
    }
  }

  // --- 更新処理 ---
  Future<void> _updateCircle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; });

    try {
      final storageService = ref.read(firebaseStorageServiceProvider);
      final firestoreService = ref.read(firestoreServiceProvider);

      String? profileImageUrl = widget.circle.profileImageUrl;
      String? coverImageUrl = widget.circle.coverImageUrl;

      // 1. プロフィール画像のアップロード
      if (kIsWeb && _profileImageBytes != null) {
        final path = storageService.generateImagePath(widget.circle.id, 'profile');
        profileImageUrl = await storageService.uploadImage(bytes: _profileImageBytes!, path: path);
      } else if (!kIsWeb && _profileImageFile != null) {
        final path = storageService.generateImagePath(widget.circle.id, 'profile');
        profileImageUrl = await storageService.uploadImage(imageFile: _profileImageFile!, path: path);
      }

      // 2. カバー画像のアップロード
      if (kIsWeb && _coverImageBytes != null) {
        final path = storageService.generateImagePath(widget.circle.id, 'cover');
        coverImageUrl = await storageService.uploadImage(bytes: _coverImageBytes!, path: path);
      } else if (!kIsWeb && _coverImageFile != null) {
        final path = storageService.generateImagePath(widget.circle.id, 'cover');
        coverImageUrl = await storageService.uploadImage(imageFile: _coverImageFile!, path: path);
      }

      // 3. データの更新
      final updatedCircle = widget.circle.copyWith(
        circleName: _circleNameController.text.trim(),
        description: _descriptionController.text.trim(),
        memberCount: int.tryParse(_memberCountController.text.trim()) ?? 0,
        universityName: _universityController.text.trim(),
        category: _selectedCategory ?? 'Other',
        profileImageUrl: profileImageUrl,
        coverImageUrl: coverImageUrl,
        updatedAt: DateTime.now(),
      );

      await firestoreService.updateCircle(updatedCircle);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('サークル情報を更新しました'), backgroundColor: Colors.green),
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
      if (mounted) setState(() { _isLoading = false; });
    }
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
              // --- 連絡・コネクション機能への導線 ---
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.connections, arguments: {'circleId': widget.circle.id});
                  },
                  icon: const Icon(Icons.people_outline),
                  label: const Text('サークル間コネクション管理'),
                  style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 1.5.h)),
                ),
              ),
              SizedBox(height: 2.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.circleDmList, arguments: {'circleId': widget.circle.id});
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
              Text('画像の設定', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              SizedBox(height: 2.h),

              // --- カバー画像の設定 ---
              Text('カバー画像', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
              SizedBox(height: 1.h),
              GestureDetector(
                onTap: () => _pickImage(isProfile: false),
                child: Container(
                  height: 20.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    image: _coverImageBytes != null
                        ? DecorationImage(image: MemoryImage(_coverImageBytes!), fit: BoxFit.cover)
                        : (_coverImageFile != null
                            ? DecorationImage(image: FileImage(_coverImageFile!), fit: BoxFit.cover)
                            : (widget.circle.coverImageUrl != null
                                ? DecorationImage(image: NetworkImage(widget.circle.coverImageUrl!), fit: BoxFit.cover)
                                : null)),
                  ),
                  child: (_coverImageBytes == null && _coverImageFile == null && widget.circle.coverImageUrl == null)
                      ? const Center(child: Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey))
                      : null,
                ),
              ),
              SizedBox(height: 3.h),

              // --- プロフィール画像の設定 ---
              Text('プロフィール画像', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
              SizedBox(height: 1.h),
              GestureDetector(
                onTap: () => _pickImage(isProfile: true),
                child: CircleAvatar(
                  radius: 12.w,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  backgroundImage: _profileImageBytes != null
                      ? MemoryImage(_profileImageBytes!)
                      : (_profileImageFile != null
                          ? FileImage(_profileImageFile!)
                          : (widget.circle.profileImageUrl != null
                              ? NetworkImage(widget.circle.profileImageUrl!) as ImageProvider
                              : null)),
                  child: (_profileImageBytes == null && _profileImageFile == null && widget.circle.profileImageUrl == null)
                      ? Icon(Icons.group, size: 12.w, color: Colors.grey)
                      : null,
                ),
              ),

              SizedBox(height: 4.h),
              const Divider(),
              SizedBox(height: 2.h),
              Text('基本情報の編集', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
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
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'カテゴリー'),
                items: _categories.map((category) {
                  return DropdownMenuItem(value: category, child: Text(category));
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

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateCircle,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
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