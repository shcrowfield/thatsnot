import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:thatsnot/button_style.dart';

class GoogleAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  User? gUser;

  Future<void> signIn() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        final UserCredential authResult = await _auth.signInWithCredential(credential);
        gUser = authResult.user;
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    gUser = null;
  }

  Widget buildGoogleSignInOutButton(BuildContext context, VoidCallback signInCallback, VoidCallback signOutCallback) {
    if (gUser == null) {
      // Google user not signed in, show sign-in button
      return ElevatedButton.icon(
        onPressed: signInCallback,
        style: googleButtonStyle,
        icon: const Icon(FontAwesomeIcons.google),
        label: const Text('Google bejelentkezés'),
      );
    } else {
      // Google user is signed in, show sign-out button
      return ElevatedButton.icon(
        onPressed: signOutCallback,
        style: googleButtonStyle,
        icon: const Icon(FontAwesomeIcons.google),
        label: const Text('Kijelentkezés Googleból'),
      );
    }
  }
}
