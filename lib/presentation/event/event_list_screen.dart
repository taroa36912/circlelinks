import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/models/event_model.dart';

class EventListScreen extends ConsumerStatefulWidget {
  const EventListScreen({super.key});

  @override
  ConsumerState<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends ConsumerState<EventListScreen> {
  late Future<List<EventModel>> _eventsFuture;
  final Map<String, String> _circleNameCache = {};

  @override
  void initState() {
    super.initState();
    _eventsFuture = _loadEvents();
  }

  Future<List<EventModel>> _loadEvents() async {
    final currentUser = ref.read(firebaseAuthServiceProvider).currentUser;
    if (currentUser == null) {
      return [];
    }

    final events = await ref
        .read(firestoreServiceProvider)
        .getVisibleEventsForUser(currentUser.uid);
    await _hydrateCircleNames(events);
    return events;
  }

  Future<void> _hydrateCircleNames(List<EventModel> events) async {
    final service = ref.read(firestoreServiceProvider);
    final creatorCircleIds = events.map((e) => e.circleId).toSet();
    final missingIds = creatorCircleIds
        .where((id) => !_circleNameCache.containsKey(id))
        .toList();

    final circles = await Future.wait(missingIds.map(service.getCircle));
    for (final circle in circles) {
      if (circle == null) continue;
      _circleNameCache[circle.id] = circle.circleName;
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _eventsFuture = _loadEvents();
    });
    await _eventsFuture;
  }

  String _creatorName(EventModel event) {
    return _circleNameCache[event.circleId] ?? 'サークル';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('イベント一覧')),
      body: FutureBuilder<List<EventModel>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('イベント読み込みエラー: ${snapshot.error}'));
          }

          final events = snapshot.data ?? [];
          if (events.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: const [
                  SizedBox(height: 180),
                  Center(child: Text('閲覧可能なイベントはまだありません')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: EdgeInsets.all(4.w),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                final timeLabel =
                    '${DateFormat('yyyy/MM/dd HH:mm').format(event.startTime)} - ${DateFormat('HH:mm').format(event.endTime)}';
                final isPrivate = event.visibility == 'private';

                return Card(
                  margin: EdgeInsets.only(bottom: 1.5.h),
                  child: ListTile(
                    title: Text(
                      event.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(timeLabel),
                        Text('${_creatorName(event)} • ${event.location}'),
                        Text(isPrivate ? '非公開イベント' : '公開イベント'),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.eventDetails,
                        arguments: {'eventId': event.id},
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
