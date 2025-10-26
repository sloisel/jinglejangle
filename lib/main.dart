import 'package:flutter/material.dart';
import 'gameboard.dart';
import 'navigation.dart';
import 'package:flutter/scheduler.dart';
import 'spelling.dart';

void main_() {
  runApp(const Foo());
}

class Foo extends StatefulWidget {
  const Foo({ Key? key, this.duration }) : super(key: key);

  final Duration? duration;

  @override
  _FooState createState() => _FooState();
}

class _FooState extends State<Foo> {
  @override
  Widget build(BuildContext context) {
    print("tic");
    SchedulerBinding.instance.addPostFrameCallback((_) { setState(() {}); });
    return Container(); // ...
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jingle Jangle',
      initialRoute: '/',
      routes: {
//        '/': (context) => const Spelling(),
        '/': (context) => const Selector(),
        '/PreGame': (context) => const PreGame(),
        '/GameBoard': (context) => const GameBoard(),
        '/Win': (context) => const Win(),
        '/Spelling': (context) => const Spelling(),
      },
    );
  }
}
