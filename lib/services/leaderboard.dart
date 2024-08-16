import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardService {

  final Map<String, dynamic> player;

  LeaderboardService(this.player);

  final CollectionReference lobbyCollection =
  FirebaseFirestore.instance.collection('leaderboard');

  Future setLeaderboardData(String uid, String name, int points) async {
    return await lobbyCollection.doc(uid).set({
      'uid': uid,
      'name': name,
      'points': points,
    });
  }

  Future updateLeaderboardData(String uid, int points) async {
    var document = await lobbyCollection.doc(uid).get();
    int currentPoint = document['points'];
    points += currentPoint;
    return await lobbyCollection.doc(uid).update({
      'points': points,
    });
  }

  Future newOrExistingUser(String uid, String name, int points) async {
    var document = await lobbyCollection.doc(uid).get();
    if (document.exists) {
      return await updateLeaderboardData(uid, points);
    } else {
      return await setLeaderboardData(uid, name, points);
    }
  }

}
