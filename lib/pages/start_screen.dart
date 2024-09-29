import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thatsnot/pages/leaderboard_page.dart';
import 'package:thatsnot/pages/rules_screen.dart';
import 'package:thatsnot/button_style.dart';
import 'package:thatsnot/services/google_auth.dart';
import 'package:thatsnot/pages/lobby_creation_page.dart';
import 'package:thatsnot/pages/lobby_list_page.dart';
import 'package:thatsnot/language.dart';


class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

User? get user {
  return FirebaseAuth.instance.currentUser;
}

class _StartPageState extends State<StartPage> {
  final GoogleAuth _googleAuth = GoogleAuth();
  String nickName = '';
  late TextEditingController nickNameController;
  String dropdownValue = 'Hun';
  //Map<String, dynamic> anyad = {};

  @override
  initState() {
    super.initState();
    nickNameController = TextEditingController();
    if (user == null || user!.uid.isEmpty) {
      _loginAnonymously();
    }
  }

  @override
  dispose() {
    nickNameController.dispose();
    super.dispose();
  }

  _onRulesNext() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const RulesPage()));
  }

  _onLobbyNext() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                LobbyCreationPage(user: user, nickName: nickName)));
  }

  _onLobbyListNext() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => LobbiesListPage(user: user)));
  }

  _onResultsNext() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => LeaderboardPage(user: user)));
  }

  String? getLoginType() {
    if (user != null) {
      for (var userInfo in user!.providerData) {
        if (userInfo.providerId == 'google.com') {
          return '${userInfo.displayName}';
        }
      }
      return 'Anonymous';
    }
    return null;
  }

  Future<bool> isOnLeaderboard(User user) async {
    DocumentSnapshot leaderboards = await FirebaseFirestore.instance
        .collection('leaderboard')
        .doc(user.uid)
        .get();
    return leaderboards.exists;
  }

  Map<String, dynamic> sizes(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final buttonWidth = screenWidth * 0.23;
    final buttonHeight = screenHeight * 0.1;
    final imageWidth = screenWidth * 0.4;
    final imageHeight = screenHeight * 0.4;
    final textSize = screenWidth * 0.02;
    return {
      'screenWidth': screenWidth,
      'screenHeight': screenHeight,
      'buttonWidth': buttonWidth,
      'buttonHeight': buttonHeight,
      'imageWidth': imageWidth,
      'imageHeight': imageHeight,
      'textSize': textSize,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple, Colors.deepOrange],
          ),
        ),
        height: sizes(context)['screenHeight'],
        width: sizes(context)['screenWidth'],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset('assets/images/logo.png',
                width: sizes(context)['imageWidth'],
                height: sizes(context)['imageHeight']),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    _googleAuth.buildGoogleSignInOutButton(context, () async {
                      await _googleAuth.signIn();
                      setState(() {});
                    }, () async {
                      await _googleAuth.signOut();
                      setState(() {});
                    }),
                    Text(languageMap['${getLoginType()}'] ?? '${getLoginType()}',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: sizes(context)['textSize'])),
                   /* ElevatedButton(
                        onPressed: () {
                          LeaderboardService(anyad).setLeaderboardData(
                              'SYRPZAdTHkhGKgzb4OJBTIo6uPP2', 'name', 10);
                        },
                        child: Text('set')),
                    ElevatedButton(
                        onPressed: () {
                          LeaderboardService(anyad).updateLeaderboardData(
                              'SYRPZAdTHkhGKgzb4OJBTIo6uPP2', -5);
                        },
                        child: Text('update')),
                    ElevatedButton(
                        onPressed: () {
                          LeaderboardService(anyad)
                              .newOrExistingUser('uidd', 'name', 10);
                        },
                        child: Text('newOrExisting')),*/
                  ],
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        getLoginType() != 'Anonymous'
                            ? _onLobbyNext()
                            : ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                                  content: Text(
                                      languageMap['JustGoogleForLobby'] ?? ''),
                                ),
                              );
                      },
                      style: getLoginType() != 'Anonymous'
                          ? menuButtonStyle.copyWith(
                              minimumSize: WidgetStateProperty.all(Size(
                                  sizes(context)['buttonWidth'],
                                  sizes(context)['buttonHeight'])),
                            )
                          : disabledMenuButtonStyle.copyWith(
                              minimumSize: WidgetStateProperty.all(Size(
                                  sizes(context)['buttonWidth'],
                                  sizes(context)['buttonHeight'])),
                            ),
                      child: Text(languageMap['CreateLobby'] ?? '',
                          style:
                              TextStyle(fontSize: sizes(context)['textSize'])),
                    ),
                    SizedBox(height: sizes(context)['screenHeight'] * 0.01),
                    ElevatedButton(
                      onPressed: () {
                        _onLobbyListNext();
                      },
                      style: menuButtonStyle.copyWith(
                        minimumSize: WidgetStateProperty.all(Size(
                            sizes(context)['buttonWidth'],
                            sizes(context)['buttonHeight'])),
                      ),
                      child: Text(languageMap['ActiveLobbies'] ?? ''),
                    ),
                    SizedBox(height: sizes(context)['screenHeight'] * 0.01),
                    ElevatedButton(
                      onPressed: () async {
                        if (getLoginType() != 'Anonymous' &&
                            await isOnLeaderboard(user!)) {
                          _onResultsNext();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  languageMap['JustGoogleForResults'] ?? ''),
                            ),
                          );
                        }
                      },
                      style: getLoginType() != 'Anonymous'
                          ? menuButtonStyle.copyWith(
                              minimumSize: WidgetStateProperty.all(Size(
                                  sizes(context)['buttonWidth'],
                                  sizes(context)['buttonHeight'])),
                            )
                          : disabledMenuButtonStyle.copyWith(
                              minimumSize: WidgetStateProperty.all(Size(
                                  sizes(context)['buttonWidth'],
                                  sizes(context)['buttonHeight'])),
                            ),
                      child: Text(languageMap['Results'] ?? ''),
                    ),
                    SizedBox(height: sizes(context)['screenHeight'] * 0.01),
                    //user == null ? buildSignInButton() : buildSignOutButton(),
                  ],
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _onRulesNext();
                      },
                      style: menuButtonStyle.copyWith(
                        minimumSize: WidgetStateProperty.all(Size(
                            sizes(context)['buttonWidth'],
                            sizes(context)['buttonHeight'])),
                      ),
                      child: Text(languageMap['Rules'] ?? ''),
                    ),
                    SizedBox(height: sizes(context)['screenHeight'] * 0.01),
                    langDropdown(),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget langDropdown() {
    return Container(
      height: sizes(context)['buttonHeight'],
      width: sizes(context)['buttonWidth'],
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
      ),
      child: DropdownButton<String>(
        value: dropdownValue,
        icon: const Icon(Icons.arrow_downward),
        iconSize: 24,
        elevation: 16,
        style: const TextStyle(color: Colors.black),
        underline: Container(
          height: 2,
          color: Colors.white,
        ),
        onChanged: (String? newValue) {
          setState(() {
            dropdownValue = newValue!;
            setLanguage(newValue);
          });
        },
        items: <String>['Hun', 'Eng', 'Tur']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  Widget buildSignInButton() {
    Map<String, String> languageMap = changeLanguageMap();
    return ElevatedButton(
      onPressed: () async {
        try {
          await FirebaseAuth.instance.signInAnonymously();
          setState(() {});
        } on FirebaseAuthException catch (e) {
          print(e);
        }
      },
      style: menuButtonStyle.copyWith(
        minimumSize: WidgetStateProperty.all(Size(
            sizes(context)['buttonWidth'], sizes(context)['buttonHeight'])),
      ),
      child: Text(languageMap['SignIn'] ?? ''),
    );
  }

  Widget buildSignOutButton() {
    Map<String, String> languageMap = changeLanguageMap();
    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            setState(() {});
          },
          style: menuButtonStyle.copyWith(
            minimumSize: WidgetStateProperty.all(Size(
                sizes(context)['buttonWidth'], sizes(context)['buttonHeight'])),
          ),
          child: Text(languageMap['SignOut'] ?? ''),
        ),
      ],
    );
  }

  Future<void> _loginAnonymously() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      setState(() {});
      print("Signed in with temporary account.");
    } catch (e) {
      print("Failed to sign in anonymously: $e");
    }
  }
}
