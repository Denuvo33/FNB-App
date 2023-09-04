import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_food_app/login/signup_page.dart';
import 'package:new_food_app/auht_service.dart';
import 'package:new_food_app/main.dart';

// ignore: must_be_immutable
class SigninPage extends StatelessWidget {
  SigninPage({super.key});
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String message = '';

  void signInUser() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // User sign-in is successful, navigate to HomePage
    } on FirebaseAuthException catch (e) {
      if (e.code == 'The email address is badly formatted') {
        print('No User found');
      } else if (e.code == 'wrong-password') {
        message = 'WrongPassword';
        print('WrongPassword');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
              child: Text(
                'Welcome Back',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text('Email'),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text('Password'),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(
              height: 10,
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => SignUpPage()));
                },
                child: Text('Doesnt have account? create now')),
            Center(
                child: ElevatedButton(
                    onPressed: () {
                      if (_emailController.text.isEmpty ||
                          _passwordController.text.isEmpty) {
                        debugPrint('Failed');
                      } else {
                        debugPrint('Signin');
                        signInUser();
                      }
                    },
                    child: Text('Sign In'))),
            SizedBox(
              height: 10,
            ),
            Center(child: Text('Or')),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: () async {
                    AuthService authService = AuthService();
                    await authService.signInWithGoogle();
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => HomePage()));
                  },
                  child: Image.asset('images/google logo.png'),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.white, padding: EdgeInsets.all(10)),
                ),
                SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Image.asset('images/apple.png'),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.white, padding: EdgeInsets.all(10)),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Divider(
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
