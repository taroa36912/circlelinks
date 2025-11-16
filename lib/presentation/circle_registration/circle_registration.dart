import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

class CircleRegistration extends ConsumerStatefulWidget {
  const CircleRegistration({super.key});

  @override
  ConsumerState<CircleRegistration> createState() => _CircleRegistrationState();
}

class _CircleRegistrationState extends ConsumerState<CircleRegistration> {
  final PageController _pageController = PageController();
  int _currentStep = 0; // 0 = 基本情報, 1 = 詳細情報
  bool _isLoading = false;

  // Form controllers
  // ⬇️ アカウント用コントローラを削除 ⬇️
  // final _emailController = TextEditingController();
  // final _passwordController = TextEditingController();
  // final _confirmPasswordController = TextEditingController();
  final _universityController = TextEditingController();
  final _circleNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _memberCountController = TextEditingController();

  // Form data
  String _selectedCategory = '';
  File? _profileImage;
  File? _coverImage;
  File? _verificationDocument;
  Uint8List? _profileImageBytes;
  Uint8List? _coverImageBytes;
  Uint8List? _verificationDocumentBytes;
  final List<String> _socialMediaLinks = [];
  final List<String> _categories = [
    'Sports',
    'Culture',
    'Arts',
    'Academic',
    'Other'
  ];

  @override
  void dispose() {
    _pageController.dispose();
    // ⬇️ アカウント用コントローラを削除 ⬇️
    // _emailController.dispose();
    // _passwordController.dispose();
    // _confirmPasswordController.dispose();
    _universityController.dispose();
    _circleNameController.dispose();
    _descriptionController.dispose();
    _memberCountController.dispose();
    super.dispose();
  }

  void _nextStep() {
    // ⬇️ ステップ数を 1 (0 -> 1) に変更 ⬇️
    if (_currentStep < 1) { 
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeRegistration();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // ... ( _pickImage, _pickDocument, _addSocialMediaLink, _removeSocialMediaLink は変更なし ) ...
  Future<void> _pickImage(ImageSource source, String type) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source, imageQuality: 80,);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          switch (type) {
            case 'profile':
              _profileImage = File(image.path);
              _profileImageBytes = bytes;
              break;
            case 'cover':
              _coverImage = File(image.path);
              _coverImageBytes = bytes;
              break;
            case 'document':
              _verificationDocument = File(image.path);
              _verificationDocumentBytes = bytes;
              break;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('画像の選択に失敗しました: $e'), backgroundColor: Colors.red,),);
      }
    }
  }
  Future<void> _pickDocument() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? document = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80,);
      if (document != null) {
        final bytes = await document.readAsBytes();
        setState(() {
          _verificationDocument = File(document.path);
          _verificationDocumentBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ドキュメントの選択に失敗しました: $e'), backgroundColor: Colors.red,),);
      }
    }
  }
  void _addSocialMediaLink() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('ソーシャルメディアリンクを追加'),
          content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'https://example.com',),),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル'),),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() { _socialMediaLinks.add(controller.text); });
                }
                Navigator.pop(context);
              },
              child: const Text('追加'),
            ),
          ],
        );
      },
    );
  }
  void _removeSocialMediaLink(int index) {
    setState(() { _socialMediaLinks.removeAt(index); });
  }

  // ⬇️ _handleGoogleRegistration は不要なので削除 ⬇️
  /*
  Future<void> _handleGoogleRegistration() async { ... }
  */
  
  Widget _buildImageWidget({
    required File? imageFile,
    required Uint8List? imageBytes,
    required IconData placeholderIcon,
    required BoxFit fit,
  }) {
    if (kIsWeb) {
      if (imageBytes != null) { return Image.memory(imageBytes, fit: fit,); }
    } else {
      if (imageFile != null) { return Image.file(imageFile, fit: fit,); }
    }
    return Icon(placeholderIcon);
  }

  bool _isStepValid() {
    switch (_currentStep) {
      // ⬇️ ステップ0 (旧ステップ1) のバリデーション ⬇️
      case 0: 
        return _universityController.text.isNotEmpty &&
            _circleNameController.text.isNotEmpty &&
            _selectedCategory.isNotEmpty &&
            _descriptionController.text.isNotEmpty &&
            _memberCountController.text.isNotEmpty;
      // ⬇️ ステップ1 (旧ステップ2) のバリデーション ⬇️
      case 1: 
        return true; // Optional step
      default:
        return false;
    }
  }

  // _isValidEmail は不要なので削除
  // bool _isValidEmail(String email) { ... }

  Future<void> _completeRegistration() async {
    FocusScope.of(context).unfocus(); 

    setState(() { _isLoading = true; });

    try {
      // ⬇️ --- 修正: 既存ユーザーの情報を取得 --- ⬇️
      final authService = ref.read(firebaseAuthServiceProvider);
      final user = authService.currentUser;

      // ユーザーがログインしていない（あり得ないはずだが）
      if (user == null) {
        throw Exception("ユーザーがログインしていません。");
      }
      
      final userId = user.uid;
      final userEmail = user.email ?? ''; // Authからメールアドレスを取得
      // ⬆️ --- 修正ここまで --- ⬆️

      // ⬇️ Auth作成処理 (createUserWithEmailAndPassword) は削除 ⬇️
      /*
      final userCredential = await authService.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      */

      // ⬆️ 削除 ⬆️

      // userCredential?.user != null の代わりに userId をチェック (既知)
      // if (userCredential?.user != null) { // 👈 削除

        final storageService = ref.read(firebaseStorageServiceProvider);
        final firestoreService = ref.read(firestoreServiceProvider);

        // Upload images
        String? profileImageUrl;
        String? coverImageUrl;
        String? verificationDocumentUrl;

        if (kIsWeb) {
          // --- Web ---
          if (_profileImageBytes != null) {
            final profilePath = storageService.generateImagePath(userId, 'profile');
            profileImageUrl = await storageService.uploadImage(bytes: _profileImageBytes!, path: profilePath,);
          }
          if (_coverImageBytes != null) {
            final coverPath = storageService.generateImagePath(userId, 'cover');
            coverImageUrl = await storageService.uploadImage(bytes: _coverImageBytes!, path: coverPath,);
          }
          if (_verificationDocumentBytes != null) {
            final documentPath = storageService.generateDocumentPath(userId);
            verificationDocumentUrl = await storageService.uploadDocument(bytes: _verificationDocumentBytes!, path: documentPath,);
          }
        } else {
          // --- モバイル ---
          if (_profileImage != null) {
            final profilePath = storageService.generateImagePath(userId, 'profile');
            profileImageUrl = await storageService.uploadImage(imageFile: _profileImage!, path: profilePath,);
          }
          if (_coverImage != null) {
            final coverPath = storageService.generateImagePath(userId, 'cover');
            coverImageUrl = await storageService.uploadImage(imageFile: _coverImage!, path: coverPath,);
          }
          if (_verificationDocument != null) {
            final documentPath = storageService.generateDocumentPath(userId);
            verificationDocumentUrl = await storageService.uploadDocument(documentFile: _verificationDocument!, path: documentPath,);
          }
        }

        // Create circle document
        final circle = CircleModel(
          id: userId, // 👈 AuthのUIDをサークルのIDとして使用
          userId: userId, // 👈 AuthのUID
          email: userEmail, // 👈 Authから取得したEmail
          universityName: _universityController.text,
          circleName: _circleNameController.text,
          category: _selectedCategory,
          description: _descriptionController.text,
          memberCount: int.tryParse(_memberCountController.text) ?? 0,
          profileImageUrl: profileImageUrl,
          coverImageUrl: coverImageUrl,
          verificationDocumentUrl: verificationDocumentUrl,
          socialMediaLinks: _socialMediaLinks,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isVerified: false,
        );
        await firestoreService.createCircle(circle); 
        HapticFeedback.lightImpact();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('サークル登録が完了しました！'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          setState(() { _isLoading = false; });

          // 登録完了後はメイン画面（サークル一覧）に戻る
          Navigator.pushReplacementNamed(context, AppRoutes.circleDiscovery);
        }
      
      // ⬇️ 削除 ⬇️
      /*
      } else {
        setState(() { _isLoading = false; });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('登録に失敗しました'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
      */
      // ⬆️ 削除 ⬆️
    } catch (e) {
      setState(() { _isLoading = false; });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('登録に失敗しました: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'サークル登録',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: colorScheme.onSurface,
            size: 24,
          ),
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            child: Row(
              // ⬇️ ステップ数を 2 に変更 (0, 1) ⬇️
              children: List.generate(2, (index) { 
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.symmetric(horizontal: 1.w),
                    decoration: BoxDecoration(
                      color: index <= _currentStep
                          ? colorScheme.primary
                          : colorScheme.outline,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                // ⬇️ _buildStep1() (アカウント作成) を削除 ⬇️
                // _buildStep1(), 
                _buildStep2(), // サークル基本情報
                _buildStep3(), // 詳細情報
              ],
            ),
          ),

          // Navigation buttons
          Container(
            padding: EdgeInsets.all(6.w),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      child: const Text('戻る'),
                    ),
                  ),
                if (_currentStep > 0) SizedBox(width: 4.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isStepValid() && !_isLoading ? _nextStep : null,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        // ⬇️ ステップ数を 1 に変更 ⬇️
                        : Text(_currentStep == 1 ? '登録完了' : '次へ'), 
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ⬇️ _buildStep1() (アカウント作成) を削除 ⬇️
  /*
  Widget _buildStep1() {
    return SingleChildScrollView(
      // ... (email, password, confirmPassword, google button) ...
    );
  }
  */
  // ⬆️ 削除 ⬆️

  Widget _buildStep2() { // サークル基本情報 (旧Step2)
    return SingleChildScrollView(
      padding: EdgeInsets.all(6.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'サークル基本情報',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 1.h),
          Text(
            'あなたのサークル情報を登録してください。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          SizedBox(height: 3.h),
          TextFormField(
            controller: _universityController,
            decoration: const InputDecoration(
              labelText: '大学名',
              hintText: '例: 東京大学',
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
          SizedBox(height: 2.h),
          TextFormField(
            controller: _circleNameController,
            decoration: const InputDecoration(
              labelText: 'サークル名',
              hintText: '例: サッカー部',
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
          SizedBox(height: 2.h),
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory.isEmpty ? null : _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'カテゴリー',
            ),
            items: _categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value ?? '';
              });
            },
          ),
          SizedBox(height: 2.h),
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: '活動内容の説明',
              hintText: 'サークルの活動内容を詳しく説明してください',
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
          SizedBox(height: 2.h),
          TextFormField(
            controller: _memberCountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'メンバー数',
              hintText: '例: 30',
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() { // 詳細情報 (旧Step3)
    return SingleChildScrollView(
      padding: EdgeInsets.all(6.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '詳細情報 (オプション)',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 3.h),

          // Profile Image
          Row(
            // ... (変更なし) ...
            children: [
              Text('プロフィール画像', style: Theme.of(context).textTheme.titleMedium,),
              SizedBox(width: 2.w),
              Container(padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12),), child: Text('オプション', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer,),),),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Container(width: 20.w, height: 20.w, decoration: BoxDecoration(border: Border.all(color: Theme.of(context).colorScheme.outline), borderRadius: BorderRadius.circular(8),), child: ClipRRect(borderRadius: BorderRadius.circular(8), child: _buildImageWidget(imageFile: _profileImage, imageBytes: _profileImageBytes, placeholderIcon: Icons.add_photo_alternate, fit: BoxFit.cover,),),),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton(onPressed: () => _pickImage(ImageSource.gallery, 'profile'), child: const Text('ギャラリーから選択'),),
                    SizedBox(height: 1.h),
                    OutlinedButton(onPressed: () => _pickImage(ImageSource.camera, 'profile'), child: const Text('カメラで撮影'),),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Cover Image
          Row(
            // ... (変更なし) ...
            children: [
              Text('カバー画像', style: Theme.of(context).textTheme.titleMedium,),
              SizedBox(width: 2.w),
              Container(padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12),), child: Text('オプション', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer,),),),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Container(width: 30.w, height: 15.w, decoration: BoxDecoration(border: Border.all(color: Theme.of(context).colorScheme.outline), borderRadius: BorderRadius.circular(8),), child: ClipRRect(borderRadius: BorderRadius.circular(8), child: _buildImageWidget(imageFile: _coverImage, imageBytes: _coverImageBytes, placeholderIcon: Icons.add_photo_alternate, fit: BoxFit.cover,),),),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton(onPressed: () => _pickImage(ImageSource.gallery, 'cover'), child: const Text('ギャラリーから選択'),),
                    SizedBox(height: 1.h),
                    OutlinedButton(onPressed: () => _pickImage(ImageSource.camera, 'cover'), child: const Text('カメラで撮影'),),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Verification Document
          Row(
            // ... (変更なし) ...
            children: [
              Text('大学公認証明書', style: Theme.of(context).textTheme.titleMedium,),
              SizedBox(width: 2.w),
              Container(padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12),), child: Text('オプション', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer,),),),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Container(width: 20.w, height: 20.w, decoration: BoxDecoration(border: Border.all(color: Theme.of(context).colorScheme.outline), borderRadius: BorderRadius.circular(8),), child: ClipRRect(borderRadius: BorderRadius.circular(8), child: _buildImageWidget(imageFile: _verificationDocument, imageBytes: _verificationDocumentBytes, placeholderIcon: Icons.description, fit: BoxFit.cover,),),),
              SizedBox(width: 4.w),
              Expanded(child: ElevatedButton(onPressed: _pickDocument, child: const Text('証明書を選択'),),),
            ],
          ),

          SizedBox(height: 3.h),

          // Social Media Links
          Row(
            // ... (変更なし) ...
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ソーシャルメディアリンク', style: Theme.of(context).textTheme.titleMedium,),
              TextButton(onPressed: _addSocialMediaLink, child: const Text('追加'),),
            ],
          ),

          if (_socialMediaLinks.isNotEmpty)
            ...List.generate(_socialMediaLinks.length, (index) {
              return Card(
                child: ListTile(
                  title: Text(_socialMediaLinks[index]),
                  trailing: IconButton(onPressed: () => _removeSocialMediaLink(index), icon: const Icon(Icons.delete),),
                ),
              );
            }),
        ],
      ),
    );
  }
}