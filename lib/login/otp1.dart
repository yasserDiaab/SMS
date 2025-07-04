import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pro/cubit/otp/otp_cubit.dart';
import 'package:pro/login/login.dart';
import 'package:pro/widgets/text_field_otp.dart';
import 'package:pro/widgets/login_button.dart';
import 'package:pro/core/di/di.dart';

class OTP extends StatefulWidget {
  const OTP({super.key, required this.id});
  final String id;

  @override
  State<OTP> createState() => _OTPState();
}

class _OTPState extends State<OTP> {
  final TextEditingController c1 = TextEditingController();
  final TextEditingController c2 = TextEditingController();
  final TextEditingController c3 = TextEditingController();
  final TextEditingController c4 = TextEditingController();

  @override
  void dispose() {
    c1.dispose();
    c2.dispose();
    c3.dispose();
    c4.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<OtpCubit>(),
      child: BlocListener<OtpCubit, OtpState>(
        listener: (context, state) {
          if (state is OtpSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("OTP verified successfully!"),
                duration:
                    Duration(seconds: 2), // مدة ظهور الـ SnackBar (2 ثانية)
              ),
            );
            // تأخير التنقل حتى يختفي الـ SnackBar
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.pop(context);
            });
          } else if (state is OtpError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            children: [
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "Follow Safe",
                  style: TextStyle(
                    color: Color(0xff193869),
                    fontFamily: 'Poppins',
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "Enter Verification Code",
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 20),
                ),
              ),
              const SizedBox(height: 20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "We have sent a code to  ",
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 10),
                  ),
                  Text(
                    "your email address",
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextFieldOTP(controller: c1, first: true, last: false),
                  TextFieldOTP(controller: c2, first: false, last: false),
                  TextFieldOTP(controller: c3, first: false, last: false),
                  TextFieldOTP(controller: c4, first: false, last: true),
                ],
              ),
              const SizedBox(height: 100),
              BlocBuilder<OtpCubit, OtpState>(
                builder: (context, state) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: LoginButton(
                      onPressed: () async {
                        String otp = c1.text + c2.text + c3.text + c4.text;
                        if (otp.length < 4) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Please enter a valid OTP")),
                          );
                          return;
                        }
                        log("Entered OTP: $otp");
                        context
                            .read<OtpCubit>()
                            .confirmEmailOtp(otp, widget.id);
                      },
                      label:
                          state is OtpLoading ? "Verifying..." : "Verify Now",
                      Color1: const Color(0xff193869),
                      color2: Colors.white,
                      color3: const Color(0xff193869),
                    ),
                  );
                },
              ),
              const SizedBox(height: 50),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive any code?",
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 11),
                  ),
                  SizedBox(width: 7),
                  Text(
                    "Resend code",
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Color(0xff193869),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xff193869)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
