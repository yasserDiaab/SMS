import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pro/cubit/user_cubit.dart';
import 'package:pro/cubit/user_state.dart';

import 'otp1.dart';

class SignUpListener extends StatelessWidget {
  const SignUpListener({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserCubit, UserState>(
      listener: (context, state) {
        if (state is SignUpLoading) {
          _showLoading(context);
        } else if (state is SignUpSuccess) {
          _hideLoading(context);
          _showMessage(context, "Sign-up successful 🎉",
              Colors.green); // ✅ Success message

          final userId = state.signUpModel.userId;
          log("========================================userId:$userId!");
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return OTP(
                id: userId,
              );
            }));
          });
        } else if (state is SignUpFailure) {
          _hideLoading(context);
          _showMessage(context, state.errMessage, Colors.red);
        }
      },
      child:
          const SizedBox.shrink(), // Empty child since this is a listener only
    );
  }

  void _showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _hideLoading(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _showMessage(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
