import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kary_win/routing/routing.dart';
import 'package:kary_win/screens/auth/auth_handler.dart';
import 'package:kary_win/screens/auth/signup.dart';
import 'package:kary_win/screens/auth/reset_password.dart';

class NewLoginPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  NewLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                height: 400,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/background.png'),
                        fit: BoxFit.fill)),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      child: Container(
                        margin: const EdgeInsets.only(top: 50),
                        child: const Center(
                          child: Text(
                            "Login",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                                color: Color.fromRGBO(143, 148, 251, .2),
                                blurRadius: 20.0,
                                offset: Offset(0, 10))
                          ]),
                      child: Column(
                        children: <Widget>[
                          //email field
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(color: Colors.grey))),
                            child: TextField(
                              controller: emailController,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Email",
                                  hintStyle:
                                      TextStyle(color: Colors.grey[400])),
                            ),
                          ),
                          //password field
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: passwordController,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Password",
                                  hintStyle:
                                      TextStyle(color: Colors.grey[400])),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ResetPassword()),
                        );
                      },
                      child: Container(
                        alignment:
                            Alignment.centerRight, // Adjust alignment as needed
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Color.fromRGBO(143, 148, 251, 1),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    //login button
                    GestureDetector(
                      onTap: () async {
                        try {
                          await FirebaseAppCheck.instance.activate(
                              androidProvider: AndroidProvider.playIntegrity);
                          // await _auth.signOut();
                          String email = emailController.text;
                          String password = passwordController.text;
                          handleLogin(context, email, password);
                        } catch (e) {
                          // Handle login errors here
                          print("Error: $e");
                          // You can show a snackbar or dialog to inform the user about the error.
                        }
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(colors: [
                            Color.fromRGBO(143, 148, 251, 1),
                            Color.fromRGBO(143, 148, 251, .6),
                          ]),
                        ),
                        child: const Center(
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    //other auth
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //facebook auth
                          IconButton(
                            onPressed: () {},
                            icon: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.transparent,
                              child: Image.asset(
                                'assets/images/icons/facebook.png',
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                          //google auth
                          IconButton(
                            onPressed: () {},
                            icon: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.transparent,
                              child: Image.asset(
                                'assets/images/icons/google.png',
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.transparent,
                              child: Image.asset(
                                'assets/images/icons/linkedin.png',
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigate to the registration screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NewSignupPage()),
                        );
                      },
                      child: const Text(
                        "You don't have an account?",
                        style:
                            TextStyle(color: Color.fromRGBO(143, 148, 251, 1)),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
