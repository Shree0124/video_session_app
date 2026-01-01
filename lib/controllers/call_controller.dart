import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CallController extends GetxController {
  final stopwatch = Stopwatch();
  final elapsedSeconds = 0.obs;
  Timer? timer;

  void startTimer() {
    stopwatch.start();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsedSeconds.value = stopwatch.elapsed.inSeconds;
    });
  }

  Future<void> endCall(String sessionId) async {
    stopwatch.stop();
    timer?.cancel();

    await FirebaseFirestore.instance
        .collection('sessions')
        .doc(sessionId)
        .update({
      'status': 'completed',
      'durationSeconds': elapsedSeconds.value,
    });
  }
}
