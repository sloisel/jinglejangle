// @dart=2.9
import 'package:flutter/material.dart';
import 'gameboard.dart';
import 'navigation.dart';
import 'package:flutter/scheduler.dart';
import 'spelling.dart';

void main_() {
  runApp(Foo());
}

class Foo extends StatefulWidget {
  Foo({ Key key, this.duration }) : super(key: key);

  final Duration duration;

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
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jingle Jangle',
      initialRoute: '/',
      routes: {
//        '/': (context) => Spelling(),
        '/': (context) => Selector(),
        '/PreGame': (context) => PreGame(),
        '/GameBoard': (context) => GameBoard(),
        '/Win': (context) => Win(),
        '/Spelling': (context) => Spelling(),
      },
    );
  }
}
