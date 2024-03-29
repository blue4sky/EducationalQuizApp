import 'package:education_app/helpers/preference_helper.dart';
import 'package:education_app/models/network_response.dart';
import 'package:education_app/models/user_by_email.dart';
import 'package:education_app/repository/auth_api.dart';
import 'package:education_app/view/main_page.dart';
import 'package:education_app/view/register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:education_app/constant/r.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  static const String route = "login_screen";

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff3f7f8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  R.strings.login,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: 30),
              Image.asset(R.assets.imgLogin),
              SizedBox(height: 56),
              Text(
                R.strings.welcome,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 10),
              Text(
                R.strings.loginDescription,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins().copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: R.colours.greySubtitle,
                ),
              ),
              Spacer(),

              // Login with Google
              ButtonLogin(
                onTap: () async {
                  await signInWithGoogle();

                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    // Check with the API
                    final dataUser = await AuthApi().getUserByEmail();
                    if (dataUser.status == Status.success) {
                      final data = UserByEmail.fromJson(dataUser.data!);
                      // Check if user has register or no (1 registered, 0 not yet)
                      if (data.status == 1) {
                        await PreferenceHelper().setUserData(data.data!);
                        Navigator.of(context).pushNamed(MainPage.route);
                      } else {
                        Navigator.of(context).pushNamed(RegisterPage.route);
                      }
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Login failed!"),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                backgroundColor: Colors.white,
                borderColor: Color(0xff01b1af),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(R.assets.icGoogle),
                    SizedBox(width: 12),
                    Text(
                      R.strings.loginWithGoogle,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: R.colours.blackLogin,
                      ),
                    ),
                  ],
                ),
              ),

              // Login with Apple
              ButtonLogin(
                onTap: () {},
                backgroundColor: Colors.black,
                borderColor: Colors.black,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(R.assets.icApple),
                    SizedBox(width: 12),
                    Text(
                      R.strings.loginWithApple,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ButtonLogin extends StatelessWidget {
  const ButtonLogin({
    Key? key,
    required this.backgroundColor,
    required this.child,
    required this.borderColor,
    required this.onTap,
    this.radius,
  }) : super(key: key);
  final double? radius;
  final Color backgroundColor;
  final Widget child;
  final Color borderColor;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: backgroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(radius ?? 25), // ?? is if null op
            side: BorderSide(
              color: borderColor,
            ),
          ),
          fixedSize: Size(MediaQuery.of(context).size.width * 0.8, 50),
        ),
        onPressed: onTap,
        child: child,
      ),
    );
  }
}
