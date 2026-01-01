import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/call_controller.dart';

class VideoCallScreen extends StatelessWidget {
  final String sessionId;
  final controller = Get.put(CallController());

  VideoCallScreen({super.key, required this.sessionId}) {
    controller.startTimer();
  }

  String formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
    
            Center(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: Icon(
                    Icons.videocam,
                    size: 100,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),

            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  const Text(
                    "Video Call",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Obx(
                    () => Text(
                      formatTime(controller.elapsedSeconds.value),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

      
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CallButton(
                    icon: Icons.mic_off,
                    color: Colors.grey.shade800,
                    onTap: () {},
                  ),
                  _CallButton(
                    icon: Icons.call_end,
                    color: Colors.red,
                    onTap: () async {
                      await controller.endCall(sessionId);
                      Get.back();
                    },
                  ),
                  _CallButton(
                    icon: Icons.videocam_off,
                    color: Colors.grey.shade800,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _CallButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CallButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        width: 64,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }
}
