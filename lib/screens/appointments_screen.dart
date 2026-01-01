
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../controllers/appointments_controller.dart';
import 'video_call_screen.dart';

class AppointmentsScreen extends StatelessWidget {
  AppointmentsScreen({super.key});

  final AppointmentsController controller =
      Get.put(AppointmentsController());


  Future<bool> _checkPermissions() async {
    final cam = await Permission.camera.request();
    final mic = await Permission.microphone.request();
    return cam.isGranted && mic.isGranted;
  }

  Future<void> _createSession(
    String title,
    DateTime scheduledAt,
  ) async {
    final id = const Uuid().v4();

    await FirebaseFirestore.instance.collection('sessions').doc(id).set({
      'title': title,
      'status': 'upcoming',
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'durationSeconds': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }


  String formatDateTime(DateTime dateTime) {
    return DateFormat("MMMM d, yyyy 'at' hh:mm a")
        .format(dateTime);
  }


Future<DateTime?> _pickDateTimeFromBottomSheet(
    BuildContext context) async {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  return await Get.bottomSheet<DateTime>(
    StatefulBuilder(
      builder: (context, setState) {
        // Display text for buttons
        String getDateText() =>
            selectedDate != null
                ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                : "Select Date";

        String getTimeText() =>
            selectedTime != null
                ? "${selectedTime!.hourOfPeriod.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')} ${selectedTime!.period == DayPeriod.am ? "AM" : "PM"}"
                : "Select Time";

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Select Date & Time",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Date Button
              InkWell(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() => selectedDate = pickedDate);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B5694), // button color
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      getDateText(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                ),
              ),

              // Time Button
              InkWell(
                onTap: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: selectedTime ?? TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() => selectedTime = pickedTime);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B5694), // button color
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      getTimeText(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Confirm Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (selectedDate == null || selectedTime == null) {
                      Get.snackbar("Error", "Please select date & time");
                      return;
                    }

                    final dateTime = DateTime(
                      selectedDate!.year,
                      selectedDate!.month,
                      selectedDate!.day,
                      selectedTime!.hour,
                      selectedTime!.minute,
                    );

                    Get.back(result: dateTime);
                  },
                  child: const Text(
                    "Confirm",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    ),
    isScrollControlled: true,
  );
}


  void _showCreateSessionDialog(BuildContext context) {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController dateTimeController = TextEditingController();

  DateTime? selectedDateTime;

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ===== HEADER =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Create Session",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ===== SESSION TITLE =====
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: "Session title",
                filled: true,
                fillColor: const Color(0xFFF2F7FD),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),

            // ===== DATE & TIME =====
            TextField(
              controller: dateTimeController,
              readOnly: true,
              decoration: InputDecoration(
                hintText: "Select Date & Time",
                filled: true,
                fillColor: const Color(0xFFF2F7FD),
                suffixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onTap: () async {
                final picked = await _pickDateTimeFromBottomSheet(context);
                if (picked != null) {
                  selectedDateTime = picked;
                  dateTimeController.text = formatDateTime(picked);
                }
              },
            ),
            const SizedBox(height: 20),

            // ===== ACTION BUTTON =====
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8F1FF), // light blue
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                  ),
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty ||
                        selectedDateTime == null) {
                      Get.snackbar("Error", "All fields are required");
                      return;
                    }

                    await _createSession(
                      titleController.text.trim(),
                      selectedDateTime!,
                    );

                    Get.back();
                    Get.snackbar("Success", "Session created");
                  },
                  child: const Text(
                    "Create",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB), // dark blue text
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: false,
  );
}



  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7FD),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF1B5694),
        title: const Text(
          "Sessions Details",
          style: TextStyle(color: Color(0xFFF8F8F8)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1B5694),
        onPressed: () => _showCreateSessionDialog(context),
        child: const Icon(Icons.add, color: Color(0xFFF8F8F8)),
      ),
      body: Obx(() {
        if (controller.sessions.isEmpty) {
          return const Center(child: Text("No sessions found"));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: controller.sessions.length,
          itemBuilder: (_, index) {
            final session = controller.sessions[index];
            final String status = session['status'];
            final Timestamp ts = session['scheduledAt'];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Card(
                color: const Color(0xFFF8F8F8),
                child: ListTile(
                  title: Text(session['title']),
                  subtitle: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatDateTime(ts.toDate()),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Status: ${status.capitalizeFirst}",
                        style: TextStyle(
                          fontSize: 12,
                          color: status == 'completed'
                              ? Colors.grey
                              : status == 'ongoing'
                                  ? Colors.green
                                  : Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  trailing:
                      (status == 'upcoming' || status == 'ongoing')
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text("Join"),
                              onPressed: () async {
                                final granted =
                                    await _checkPermissions();
                                if (!granted) {
                                  Get.snackbar(
                                    "Permission Denied",
                                    "Camera & Microphone required",
                                  );
                                  return;
                                }

                                await controller
                                    .markSessionOngoing(session.id);

                                Get.to(() => VideoCallScreen(
                                      sessionId: session.id,
                                    ));
                              },
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "Completed",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight:
                                          FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Duration: ${session['durationSeconds']} sec",
                                  style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
