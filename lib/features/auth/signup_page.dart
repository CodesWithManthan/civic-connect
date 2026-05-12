import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  void showError(String message){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Future<void> signUp() async{
    try{
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account created successfully'),
            backgroundColor: Colors.green,
          ),
      );

      Navigator.pop(context);
    }
    on FirebaseAuthException catch (e){
      if (e.code == 'email-already-in-use') {
        showError('Email already registered');
      } else if (e.code == 'weak-password') {
        showError('Password should be at least 6 characters');
      } else if (e.code == 'invalid-email') {
        showError('Invalid email format');
      } else {
        showError('Signup failed. Try again.');
      }
    }
  }

  @override
  void dispose(){
    email.dispose();
    password.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SignUp Page'),
        backgroundColor: Colors.greenAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
                controller: email,
                decoration: InputDecoration(
                    hintText: 'Email',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0)
                    )
                )
            ),
            SizedBox(height: 20),
            TextField(
                controller: password,
                obscureText: true,
                decoration: InputDecoration(
                    hintText: 'Password',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0)
                    )
                )
            ),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: signUp,
                child: Text('Sign Up')
            )
          ],
        ),
      ),
    );
  }
}
