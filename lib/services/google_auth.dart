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

  Map<String, dynamic> buttonSizes(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final buttonWidth = screenWidth * 0.23;
    final buttonHeight = screenHeight * 0.1;
    return {
      'screenWidth': screenWidth,
      'screenHeight': screenHeight,
      'buttonWidth': buttonWidth,
      'buttonHeight': buttonHeight,
    };
  }

  getUserName() {
    for (var userInfo in user!.providerData) {
      return userInfo.displayName;
    }
  }

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

        user = FirebaseAuth.instance.currentUser;
        if (user != null && user!.isAnonymous) {
          try {
            final UserCredential userCredential =
            await user!.linkWithCredential(credential);
            user = userCredential.user;
            print('Anonymous user linked to Google account');
          } catch (e) {
            print(e);
            if (e is FirebaseAuthException &&
                e.code == 'credential-already-in-use') {
              final authResult = await _auth.signInWithCredential(credential);
              user = authResult.user;
              print('Anonymous user already linked to Google account');
            } else {
              print(e);
            }
          }
        } else {
          final UserCredential authResult =
          await _auth.signInWithCredential(credential);
          user = authResult.user;
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    user = null;
    await FirebaseAuth.instance.signInAnonymously();
    user = FirebaseAuth.instance.currentUser;
  }

  Widget buildGoogleSignInOutButton(BuildContext context,
      VoidCallback signInCallback, VoidCallback signOutCallback) {
    if (user == null || user!.isAnonymous) {
      return ElevatedButton.icon(
        onPressed: signInCallback,
        style: googleButtonStyle.copyWith(
          minimumSize: WidgetStateProperty.all<Size>(Size(
              buttonSizes(context)['buttonWidth'],
              buttonSizes(context)['buttonHeight'])),
        ),
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
          //Text('Bejelentkezve: ${getUserName()}', style: const TextStyle(fontSize: 20, color: Colors.white)),
        ],
      );
    }
  }
}