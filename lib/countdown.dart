import 'package:flutter/material.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:timer_count_down/timer_controller.dart';

class CountDown extends StatefulWidget {

  final CountdownController controller;

  const CountDown({super.key, required this.controller});

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
      onFinished: () {
        print('Timer is done!');
      },
    );
  }
}