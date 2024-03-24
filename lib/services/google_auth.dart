import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:thatsnot/button_style.dart';
import 'package:thatsnot/language.dart';

class GoogleAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  User? user;

  Future<void> signIn() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        final UserCredential authResult =
            await _auth.signInWithCredential(credential);
        user = authResult.user;
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    user = null;
  }

  Widget buildGoogleSignInOutButton(BuildContext context,
      VoidCallback signInCallback, VoidCallback signOutCallback) {


    if (user == null) {
      return ElevatedButton.icon(
        onPressed: signInCallback,
        style: googleButtonStyle,
        icon: const Icon(FontAwesomeIcons.google),
        label: Text(languageMap['GoogleSignIn'] ?? ''),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: signOutCallback,
            style: googleButtonStyle,
            icon: const Icon(FontAwesomeIcons.google),
            label: Text(languageMap['GoogleSignOut'] ?? ''),
          ),
          Text('Bejelentkezve: ${user!.displayName}'),
        ],
      );
    }
  }
}
