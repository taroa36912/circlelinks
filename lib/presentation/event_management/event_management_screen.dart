import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import '../../core/services/firestore_service.dart';
import '../../core/models/event_model.dart';
import '../../routes/app_routes.dart';

class EventManagementScreen extends ConsumerStatefulWidget {
  const EventManagementScreen({super.key});

  @override
  ConsumerState<EventManagementScreen> createState() => _EventManagementScreenState();
}

class _EventManagementScreenState extends ConsumerState<EventManagementScreen> {
  String? _circleId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['circleId'] != null) {
      _circleId = args['circleId'] as String;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_circleId == null) {
      return const Scaffold(body: Center(child: Text('Error: No Circle ID provided')));
    }

    final firestoreService = ref.watch(firestoreServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('イベント管理'),
        actions: [
          IconButton(
             icon: const Icon(Icons.add),
             onPressed: () {
               Navigator.pushNamed(
                 context, 
                 AppRoutes.eventCreation, // Assumes this route exists or we create it
                 arguments: {'circleId': _circleId}
               );
             },
          ),
        ],
      ),
      body: StreamBuilder<List<EventModel>>(
        stream: firestoreService.getEventsForCircle(_circleId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
             return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final events = snapshot.data ?? [];
          
          if (events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Icon(Icons.event_busy, size: 64, color: Colors.grey),
                   SizedBox(height: 2.h),
                   const Text('イベントがまだありません'),
                   TextButton(
                     onPressed: () {
                       Navigator.pushNamed(
                         context, 
                         AppRoutes.eventCreation, 
                         arguments: {'circleId': _circleId}
                       );
                     },
                     child: const Text('イベントを作成する'),
                   )
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: events.length,
            padding: EdgeInsets.all(4.w),
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                margin: EdgeInsets.only(bottom: 2.h),
                child: ListTile(
                  title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '${event.startTime.year}/${event.startTime.month}/${event.startTime.day} @ ${event.location}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Go to details (in management mode potentially)
                    Navigator.pushNamed(
                      context, 
                      AppRoutes.eventDetails, 
                      arguments: {'eventId': event.id, 'isManager': true}
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
