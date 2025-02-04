import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Image.asset(
              'lib/view/images/welcome_images/logo.png',
              height: 250,
            ),
          ),

          Column(
            children: [
              Text(
                "Search for favorite food\nnear you",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "Discover foods from over 3250 restaurants.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),

          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(backgroundColor: Colors.grey, radius: 4),
                  SizedBox(width: 5),
                  CircleAvatar(backgroundColor: Colors.green, radius: 4),
                  SizedBox(width: 5),
                  CircleAvatar(backgroundColor: Colors.grey, radius: 4),
                ],
              ),
              SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.green),
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          GoRouter.of(context).push('/register');
                        },
                        child: Text("Sign Up",
                            style: TextStyle(color: Colors.green)),
                      ),
                    ),
                    SizedBox(width: 10),

                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          GoRouter.of(context).push('/login');
                        },
                        child:
                        Text("Sign In", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ],
      ),
    );
  }
}
