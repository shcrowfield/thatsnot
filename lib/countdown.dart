import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:thatsnot/services/database.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:timer_count_down/timer_controller.dart';

class CountDown extends StatefulWidget {

  final CountdownController controller;
  final String lobbyId;

  const CountDown({super.key, required this.controller, required this.lobbyId});

  @override
  State<CountDown> createState() => _CountDownState();
}

class _CountDownState extends State<CountDown> {



  @override
  Widget build(BuildContext context) {
    return Countdown(
      seconds: 10,
      controller: widget.controller,
      build: (BuildContext context, double time) => Text(time.toString()),
      interval: const Duration(milliseconds: 100),
      onFinished: () async {
    await DatabaseService(lobbyId: widget.lobbyId).setPassCount();
    await DatabaseService(lobbyId: widget.lobbyId).checkActivePlayer();

      },
    );
  }
}