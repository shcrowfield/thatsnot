import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class LeaderboardService {

  final Map<String, dynamic> player;
  final Map<String, dynamic> winner;

  LeaderboardService(this.winner, this.player);

  final CollectionReference lobbyCollection =
  FirebaseFirestore.instance.collection('leaderboard');

  Future setLeaderboardData(String uid, String name, int points) async {
    User user = FirebaseAuth.instance.currentUser!;
    String userName = user.providerData[0].displayName!;
    List<int> games = [points];
    if(winner['uid'] == FirebaseAuth.instance.currentUser?.uid){
    return await lobbyCollection.doc(uid).set({
      'name': userName,
      'uid': uid,
      'nickName': name,
      'points': points,
      'winCounter': 1,
      'games': games,
    });}else{
      return await lobbyCollection.doc(uid).set({
        'name': userName,
        'uid': uid,
        'nickName': name,
        'points': points,
        'winCounter': 0,
        'games': games
      });
    }
  }

  Future updateLeaderboardData(String uid, int points) async {
    var document = await lobbyCollection.doc(uid).get();
    int currentPoint = document['points'];
    int newPoint = points + currentPoint;
    List<dynamic> currentGames = List.from(document['games'] ?? []);
    currentGames.add(points);
    if(winner['uid'] == FirebaseAuth.instance.currentUser?.uid){
      return await lobbyCollection.doc(uid).update({
        'points': newPoint,
        'winCounter': FieldValue.increment(1),
        'games': currentGames,
      });
    }else{
      return await lobbyCollection.doc(uid).update({
        'points': newPoint,
        'games': currentGames,
      });
    }

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
