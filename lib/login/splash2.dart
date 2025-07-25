import 'package:flutter/material.dart';
import 'package:pro/login/Splash3.dart';
import 'package:pro/widgets/login_button.dart';
import 'package:pro/widgets/overlappingimage.dart';
// import 'package:graduationproject1/components/CustomButton.dart';
// import 'package:graduationproject1/components/CustomImage.dart';
// import 'package:graduationproject1/views/LOGIN/splash3.dart';

class Splach2 extends StatelessWidget {
  const Splach2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              // Skip button action
            },
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const Splach3();
                    },
                  ),
                );
              },
              child: const Text(
                "Skip",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Color(0xff212429),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 30,
          ),
          const Padding(
            padding: EdgeInsets.all(18),
            child: SizedBox(
              width: double.infinity,
              height: 300, // Adjusted the height for proper display
              child: OverlappingImages(
                photo1: 'assets/images/img3.png',
                photo2: 'assets/images/img4.png',
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 35,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 35,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xff193869),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 35,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(
                height: 20,
              )
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Make sure your child\'s safety',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Poppins',
                color: Color(
                  0xff212429,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(
              'A simplified interface for children to easily access help in emergencies.With pre-configured emergency contacts and actions to ensure children can easily call for help',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                color: Color(
                  0xff212429,
                ),
              ),
              // maxLines: 4,
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          LoginButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const Splach3();
                    },
                  ),
                );
              },
              label: 'Next',
              Color1: const Color(0xff193869),
              color2: Colors.white,
              color3: const Color(0xff193869))
        ],
      ),
    );
  }
}
