import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxList<QueryDocumentSnapshot> sessions = <QueryDocumentSnapshot>[].obs;

  @override
  void onInit() {
    fetchUpcomingSessions();
    super.onInit();
  }

  void fetchUpcomingSessions() {
    _firestore
        .collection('sessions')
        // .where('status', isEqualTo: 'upcoming' )
        .snapshots()
        .listen((snapshot) {
      sessions.value = snapshot.docs;
    });
  }

  Future<void> markSessionOngoing(String sessionId) async {
    await _firestore.collection('sessions').doc(sessionId).update({
      'status': 'ongoing',
    });
  }
}
