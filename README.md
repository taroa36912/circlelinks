# Flutter

A modern Flutter-based mobile application utilizing the latest mobile development technologies and tools for building responsive cross-platform applications.

## 📋 Prerequisites

- Flutter SDK (^3.29.2)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Android SDK / Xcode (for iOS development)

## 🛠️ Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Run the application:
```bash
flutter run
```

## 📁 Project Structure

```
flutter_app/
├── android/            # Android-specific configuration
├── ios/                # iOS-specific configuration
├── lib/
│   ├── core/           # Core utilities and services
│   │   └── utils/      # Utility classes
│   ├── presentation/   # UI screens and widgets
│   │   └── splash_screen/ # Splash screen implementation
│   ├── routes/         # Application routing
│   ├── theme/          # Theme configuration
│   ├── widgets/        # Reusable UI components
│   └── main.dart       # Application entry point
├── assets/             # Static assets (images, fonts, etc.)
├── pubspec.yaml        # Project dependencies and configuration
└── README.md           # Project documentation
```

## 🧩 Adding Routes

To add new routes to the application, update the `lib/routes/app_routes.dart` file:

```dart
import 'package:flutter/material.dart';
import 'package:package_name/presentation/home_screen/home_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String home = '/home';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    home: (context) => const HomeScreen(),
    // Add more routes as needed
  }
}
```

## 🎨 Theming

This project includes a comprehensive theming system with both light and dark themes:

```dart
// Access the current theme
ThemeData theme = Theme.of(context);

// Use theme colors
Color primaryColor = theme.colorScheme.primary;
```

The theme configuration includes:
- Color schemes for light and dark modes
- Typography styles
- Button themes
- Input decoration themes
- Card and dialog themes

## 📱 Responsive Design

The app is built with responsive design using the Sizer package:

```dart
// Example of responsive sizing
Container(
  width: 50.w, // 50% of screen width
  height: 20.h, // 20% of screen height
  child: Text('Responsive Container'),
)
```
## 📦 Deployment

Build the application for production:

```bash
# For Android
flutter build apk --release

# For iOS
flutter build ios --release
```

## 🙏 Acknowledgments
- Built with [Rocket.new](https://rocket.new)
- Powered by [Flutter](https://flutter.dev) & [Dart](https://dart.dev)
- Styled with Material Design

Built with ❤️ on Rocket.new

















# CircleLink (仮) アプリケーション README

これは、大学サークルの管理と交流を目的としたFlutterアプリケーションです。

## 認証機能 (Authentication)

- **メール/パスワード認証:**
  - `firebase_auth_service.dart` にて、メールとパスワードによるサインアップ (`createUserWithEmailAndPassword`) とログイン (`signInWithEmailAndPassword`) 機能を提供します。
  - `login_screen.dart`: ログインフォームを提供します。
  - `circle_registration.dart`: サインアップフォーム（ステップ1）でアカウントを作成します。

- **Googleログイン:**
  - `firebase_auth_service.dart` にて、`kIsWeb` (Web) とモバイル (iOS/Android) で処理を分岐します。
  - **Web:** `signInWithPopup` を使用します。
  - **モバイル:** `google_sign_in` パッケージ (`v6`) を使用してトークンを取得し、`signInWithCredential` でFirebaseに連携します。
  - `login_screen.dart`: `SocialLoginWidget` を介してログインボタンを提供します。

- **LINEログイン:**
  - `firebase_auth_service.dart` にて、モバイル専用 (iOS/Android) のログイン機能を提供します。
  - `flutter_line_sdk` を使用してLINE IDトークンを取得します。
  - `cloud_functions` を呼び出し、バックエンド (未実装) でIDトークンを検証し、Firebaseカスタムトークンを取得します。
  - `signInWithCustomToken` を使用してFirebaseにサインインします。
  - `login_screen.dart`: `SocialLoginWidget` を介してログインボタンを提供します。

- **ログアウト:**
  - マイページ (`my_page_screen.dart` - *新規*) からログアウトが可能です。

## サークル機能 (Circle Features)

### 1. サークル登録 (`circle_registration.dart`)
- 新規ユーザー（サークル管理者）がアカウント作成と同時にサークル情報を登録する、3ステップのページャー形式のフォームです。
  - **ステップ1 (アカウント):** メール/パスワード設定。
  - **ステップ2 (基本情報):** 大学名、サークル名、カテゴリ、説明、メンバー数。
  - **ステップ3 (詳細情報):** プロフィール画像、カバー画像、公認証明書、SNSリンク。
- **マルチプラットフォーム対応:**
  - `kIsWeb` で判定し、Webでは画像/ドキュメントを `Uint8List` として、モバイルでは `File` として `FirebaseStorageService` にアップロードします。
  - `ImagePicker` を使用して画像・ドキュメントを選択します。
- 登録完了後、`CircleModel` オブジェクトを `FirebaseFirestoreService` に送信して `circles` コレクションに保存します。

### 2. サークル一覧 (発見) (`circle_discovery.dart`)
- ログイン後のメイン画面です。
- `NestedScrollView` と `SliverAppBar` を使用したUIです。
- **検索:** `SearchBarWidget` によるサークル名、大学名、説明のキーワード検索。
- **カテゴリタブ:** `TabBar` により、「All」「Sports」「Culture」などでカテゴリを絞り込めます。
- **フィルタリング:** FAB (フローティングアクションボタン) から `FilterModalWidget` を呼び出し、大学名、活動タイプ、スキル、メンバー数で絞り込めます。
- **ソート:** `SortButtonWidget` により、関連度、距離（モック）、メンバー数などで並び替えが可能です。
- **表示:** `ListView.builder` でサークル情報を `CircleCardWidget` として一覧表示します。
- **その他:**
  - `RefreshIndicator` によるプルリフレッシュ（`_refreshCircles`）。
  - `_loadMoreCircles` による無限スクロール（現在はモック）。
  - AppBarから「コネクション」画面へ遷移するボタンがあります。

### 3. サークル詳細プロフィール (`circle_profile.dart`)
- サークル一覧から特定のサークルをタップすると遷移する詳細画面です。
- `didChangeDependencies` で `ModalRoute` から `circleId` を受け取り、Firestoreからサークル情報を取得します。
- `NestedScrollView` と `SliverAppBar` を使用し、カバー画像をヘッダーに表示します。
- **タブ:** 「About」と「Contact」のタブがあります。
  - **About:** 基本情報（大学名、カテゴリ、メンバー数）、活動内容、SNSリンクを表示します。
  - **Contact:** 連絡先情報（メールアドレスなど）を表示します。
- **アクション:**
  - FABから「コネクションリクエスト」を送信できます (`_handleSendConnectionRequest`)。
  - AppBarからサークル情報をシェアできます (`_handleShareCircle`)。

## ソーシャル機能 (Connections & Chat)

### 1. コネクション管理 (`connections.dart`)
- サークル間の接続を管理する画面です。
- **タブ:** 「受信リクエスト」と「接続済みサークル」のタブがあります。
- **受信リクエスト:**
  - 自分 (`_currentUserId`) が `toCircleId` になっている `pending` 状態のリクエストをFirestoreからストリームで取得します。
  - ユーザーはリクエストを「承認」(`_approveRequest`) または「却下」(`_declineRequest`) できます。
- **接続済みサークル:**
  - 自分が関わっており `approved` 状態のコネクションをストリームで取得します。
  - 接続済みのサークルをタップすると、チャット画面 (`/chat`) に遷移します。

### 2. チャット (`chat.dart`)
- 接続済みのサークルと1対1でチャットを行う画面です。
- `connectionId` を元に、Firestoreの `messages` サブコレクションからメッセージをストリームで取得し、`ListView.builder` で表示します。
- 相手のサークル名がAppBarに表示されます。
- `_buildMessageInput` でメッセージ入力欄と送信ボタンを提供し、`_sendMessage` でFirestoreに新しいメッセージを書き込みます。

## イベント機能 (Event Management)

### 1. イベント作成 (`event_creation.dart`)
- 新しいイベントを作成するための詳細なフォーム画面です。
- 以下のセクション（`widgets` フォルダ内のウィジェット）で構成されています:
  - 基本情報 (タイトル、説明、カテゴリ)
  - 日時 (日付、開始/終了時刻)
  - 場所 (テキスト入力、Google Maps連携)
  - 出欠設定 (RSVP締切、定員、出欠オプション)
  - 支払い (費用、PayPay連携)
  - 詳細オプション (写真アルバム、共同投稿など)
- **機能:**
  - `_saveDraft`: フォーム入力中に自動で下書き保存する（現在はモック）。
  - `_getSmartSuggestions`: 選択したカテゴリに基づき「おすすめ設定」を提案する。
  - `_showPreview`: 作成前にモーダルでプレビューを表示する。

### 2. イベント詳細 (`event_details.dart`)
- イベントの詳細情報を表示する画面です。（現在は**モックデータ**で動作しています）
- **UI:** `CustomScrollView` と `SliverAppBar` を使用し、イベントのヒーローイメージをヘッダーに表示します。
- **表示内容:**
  - `EventInfoCardWidget`: 基本情報（日時、場所など）。
  - `AttendanceSectionWidget`: 出欠状況と参加者一覧。
  - `AdditionalDetailsWidget`: 写真、費用内訳など（スクロールに応じて表示）。
  - `CommentsSectionWidget`: コメントの表示と投稿。
- **アクション:** `ActionButtonsWidget`（`BottomSheet`）により、RSVP（出欠確認）のステータスを変更できます。

## ユーザー機能 (User Features)

### 1. ポートフォリオビルダー (`portfolio_builder.dart`)
- ユーザー（サークルメンバー個人）の活動実績やスキルをまとめる画面です。（現在は**モックデータ**で動作しています）
- **タブ:** 「Portfolio」と「Skills」のタブがあります。
  - **Portfolio:** Leadership (役職), Event Organization, Project Contributions をセクションごとに表示・編集・追加できます。
  - **Skills:** スキル一覧と、それに対する推薦 (Endorsement) を管理します。
- **機能:**
  - プロフィールの編集。
  - 各実績の検証リクエスト。
  - スキルの推薦リクエスト。
  - `ExportOptionsWidget` を呼び出し、ポートフォリオをエクスポートする機能（FAB）。