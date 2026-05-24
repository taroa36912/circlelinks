import '../../core/app_export.dart';

final openProjectsProvider = StreamProvider.autoDispose<List<ProjectModel>>(
  (ref) => ref.watch(firestoreServiceProvider).getOpenProjects(),
);

final projectProvider =
    StreamProvider.autoDispose.family<ProjectModel?, String>(
  (ref, projectId) =>
      ref.watch(firestoreServiceProvider).getProjectStream(projectId),
);

final currentUserModelProvider = FutureProvider.autoDispose<UserModel?>((ref) {
  final firebaseUser = ref.watch(firebaseAuthServiceProvider).currentUser;
  if (firebaseUser == null) return Future.value(null);
  return ref.watch(firestoreServiceProvider).getUser(firebaseUser.uid);
});
