import 'package:flutter/material.dart';
import 'package:video/image2.dart';

class CustomImage extends StatelessWidget {
  const CustomImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            "assets/9.jpg",
            width: double.infinity,
            height: MediaQuery.of(context).size.height / 2,
            fit: BoxFit.fill,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 20),
            child: SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomImage2(),
                      ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
                child: Text(
                  "Indiki",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      )),
    );
  }
}
