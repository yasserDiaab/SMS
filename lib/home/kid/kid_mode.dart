import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pro/cubit/kid_profile/kid_profile_cubit.dart';
import 'package:pro/home/kid/kid_profile.dart';
import 'package:pro/home/kid/kid_settings.dart';
import 'package:pro/home/kid/parent_save.dart';
import 'package:pro/home/kid/timer_kid.dart';
import 'package:pro/cubit/sos/sos_cubit.dart';
import 'package:pro/cubit/sos/sos_state.dart';
import 'package:pro/core/di/di.dart';
import 'package:pro/repo/kid_profile_repo.dart';
import 'dart:developer';

class SafetyScreen extends StatefulWidget {
  @override
  _SafetyScreenState createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen> {
  // 🚨 Send SOS using SosCubit
  void _sendSOSAlert() {
    log("🚨 KID MODE: Sending SOS alert using SosCubit");

    // Send SOS using the cubit
    context.read<SosCubit>().sendSosNotification(
          message: "Emergency! Kid needs help!",
        );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: const SizedBox(
            width: 508,
            height: 144,
            child: Center(
              child: Text(
                "Are You Sure You Want to send SOS message?\n\nThis will alert all your trusted supporters with your location.",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog first
                _sendSOSAlert(); // Then send SOS
              },
              child: const Text("Yes",
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("No", style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SosCubit>()..initialize(),
      child: BlocListener<SosCubit, SosState>(
        listener: (context, state) {
          if (state is SosLoading) {
            // Show loading dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const AlertDialog(
                content: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 20),
                    Text('Sending SOS...'),
                  ],
                ),
              ),
            );
          } else if (state is SosSuccess) {
            // Close loading dialog
            Navigator.of(context).pop();

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🚨 SOS sent to all supporters!'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 4),
              ),
            );

            // Navigate to ParentSave
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return ParentSave();
            }));

            log("✅ SOS sent successfully");
          } else if (state is SosFailure) {
            // Close loading dialog
            Navigator.of(context).pop();

            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Failed to send SOS: ${state.error}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );

            log("❌ SOS failed: ${state.error}");
          }
        },
        child: Scaffold(
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF30C988), Color(0xFF37A3B6)],
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.03,
                right: MediaQuery.of(context).size.width * 0.00008,
                child: Image.asset("assets/images/sun.png",
                    width: 200, height: 200),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.22,
                left: MediaQuery.of(context).size.width * 0.01,
                child: Image.asset("assets/images/union.png",
                    width: 80, height: 52),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.18,
                right: MediaQuery.of(context).size.width * 0.01,
                child: Image.asset("assets/images/union.png",
                    width: 80, height: 52),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.07,
                    ),
                    const Text(
                      "Hello,Sarah ",
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const Text(
                      "I'm here to Keep you safe!",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    Image.asset("assets/images/girl.png",
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.width * 1),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const TimerWidgetKid();
                        }));
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize:
                            Size(MediaQuery.of(context).size.width * 0.8, 80),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                          side: const BorderSide(color: Colors.black, width: 2),
                        ),
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        shadowColor: Colors.black,
                        padding: EdgeInsets.zero,
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF41DB8E), Color(0xFF025F68)],
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: const Text(
                            "Safety Mode",
                            style: TextStyle(fontSize: 24, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildIconButton(Icons.settings,
                            const Color.fromRGBO(255, 181, 1, 1), () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return KidSettingsScreen();
                          }));
                        }),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.02),
                        GestureDetector(
                          onTap: _showConfirmationDialog,
                          child: const CircleAvatar(
                            radius: 50,
                            backgroundColor: Color.fromRGBO(254, 122, 128, 1),
                            child: Text(
                              "SOS",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.02),
                        _buildIconButton(
                            Icons.person, const Color.fromRGBO(255, 181, 1, 1),
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider(
                                create: (_) => KidProfileCubit(
                                    KidProfileRepository(Dio())),
                                child: KidProfileScreen(),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: CircleAvatar(
        radius: 50,
        backgroundColor: color,
        child: Icon(icon, size: 40, color: Colors.white),
      ),
    );
  }
}
