import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:civic_connect/features/auth/signup_page.dart';
import 'package:civic_connect/core/auth/google_auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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


  Login() async{
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      if(e.code == 'user-not-found'){
       showError('No Account Found For This Email');
      }
      else if(e.code == 'invalid-email'){
        showError('Invalid Email Format');
      }
      else if(e.code == 'wrong-password'){
        showError('Incorrect Password');
      }
      else{
        showError('Something Went Wrong');
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
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
                onPressed: Login,
                child: Text('Login')
            ),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignupPage(),
                      ),
                  );
                },
                child: Text('Sign Up')
            ),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: () async {
                  try {
                    await GoogleAuthService.signInWithGoogle();
                  }
                  catch(e){
                    print(e);
                  }
                },
                child: Text('Sign In With Google'),
            ),
          ],
        ),
      ),
    );
  }
}
