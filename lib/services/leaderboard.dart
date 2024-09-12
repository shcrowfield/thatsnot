import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeaderboardService {

  final Map<String, dynamic> player;

  LeaderboardService(this.player);

  final CollectionReference lobbyCollection =
  FirebaseFirestore.instance.collection('leaderboard');

  Future setLeaderboardData(String uid, String name, int points) async {
    User user = FirebaseAuth.instance.currentUser!;
    String userName = user.providerData[0].displayName!;
    return await lobbyCollection.doc(uid).set({
      'name': userName,
      'uid': uid,
      'nickName': name,
      'points': points,
      'wins': 1,
    });
  }

  Future updateLeaderboardData(String uid, int points) async {
    var document = await lobbyCollection.doc(uid).get();
    int currentPoint = document['points'];
    points += currentPoint;
    return await lobbyCollection.doc(uid).update({
      'points': points,
      'wins': FieldValue.increment(1),
    });
  }

  Future newOrExistingUser(String uid, String name, int points) async {
    User user = FirebaseAuth.instance.currentUser!;
    if(user.isAnonymous != true) {
      var document = await lobbyCollection.doc(uid).get();
      if (document.exists) {
        return await updateLeaderboardData(uid, points);
      } else {
        return await setLeaderboardData(uid, name, points);
      }
    }else{
      print('Anonymous user');
    }
  }

}
