import 'package:flutter/material.dart';
import 'package:video/api/login_api.dart';
import 'package:video/bottombar.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4BB44),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Image.asset(
                "assets/4.jpg",
                width: double.infinity,
              ),
              SizedBox(height: 10),
              Text(
                "Girmek",
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 2),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      hintText: "Peýdalanyjy",
                      // prefixIcon: Icon(Icons.person, color: Colors.blue),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Password Field
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 2),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Parol",
                      // prefixIcon: Icon(Icons.lock, color: Colors.blue),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 2),
                child: SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      String username = usernameController.text.trim();
                      String password = passwordController.text.trim();

                      if (username.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Peýdalanyjy adyňyzy girizilmeli!"),
                          ),
                        );
                      } else if (password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Parolyňyz girizilmeli!"),
                          ),
                        );
                      } else {
                        try {
                          bool isSuccess =
                              await LoginService().login(username, password);
                          if (isSuccess) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BottomNavBar(),
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Ulanyjy adyňyz ýa-da parolyňyz nädogry!",
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow.shade900,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                    child: Text(
                      "Girmek",
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
          ),
        ),
      ),
    );
  }
}
