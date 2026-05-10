import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';

class QRScanScreen extends ConsumerStatefulWidget {
  const QRScanScreen({super.key});

  @override
  ConsumerState<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends ConsumerState<QRScanScreen> {
  final TextEditingController _inputController = TextEditingController();
  bool _isLoading = false;
  String? _eventId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['eventId'] != null) {
      _eventId = args['eventId'];
    }
  }

  Future<void> _processScan(String scanData) async {
    if (_eventId == null) return;
    if (scanData.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      // scanData in this mvp is the userId. 
      // In real app, it might be encrypted token.
      
      await firestoreService.markAttendance(
        eventId: _eventId!,
        userId: scanData,
        scanData: scanData,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('出席を確認しました: $scanData'),
            backgroundColor: Colors.green,
          ),
        );
        _inputController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('エラー: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_eventId == null) {
      return const Scaffold(body: Center(child: Text('Event ID missing')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('QR出席確認')),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Container(
              height: 40.h,
              width: double.infinity,
              color: Colors.black,
              child: const Center(
                child: Text(
                  'Camera Preview Here\n(Add mobile_scanner dependency)',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            const Text('または手動入力 (User ID)'),
            SizedBox(height: 2.h),
            TextField(
              controller: _inputController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'User ID',
                suffixIcon: Icon(Icons.qr_code),
              ),
            ),
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _processScan(_inputController.text),
                child: _isLoading 
                    ? const CircularProgressIndicator()
                    : const Text('確認'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
