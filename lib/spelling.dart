import 'package:flutter/material.dart';
import 'dart:math';
import 'gameboard.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'mysound.dart';
import 'dart:async';


class Spelling extends StatefulWidget {
  const Spelling({Key? key}) : super(key: key);

  @override
  SpellingState createState() => SpellingState();
}


class SpellingState extends State<Spelling> {
  late double H,W,keyW,keyH;
  late List<String> tileset;
  late List<int> scores;
  int maxScore = 1;
  late int maxTileLength;
  late String question, solution;
  late int questionNumber;
  String answer = "";
  String title="";
  late Map decrypt;
  late List<String> answers;
  late List<String> solutions;
  bool titleHint = false;
  late bool madeError;
  late String language;
  final maxAnswersLength = 1;
  List<String> rows = ["QWERTYUIOP","ASDFGHJKL","ZXCVBNM"];
  late Random rng;
  Map? oldargs;
  Timer? finaltimer, hinter;
  late DateTime turnStart;
  int maxtime = 30;
  bool highlight = false;
  bool gaveHint = false;
  late double keyboardshift;

  @override
  void dispose() {
    super.dispose();
    finaltimer?.cancel();
    hinter?.cancel();
  }

  SpellingState() {
    rng = Random();
  }
  
  void genQuestion() {
    madeError = false;
    var cs = List<double>.filled(scores.length, 0.0);
    num P(x) => pow(maxScore-x,2.0);
    cs[0] = P(scores[0]).toDouble();
    for (var p=1;p<scores.length;p++) {
      cs[p] = cs[p-1]+P(scores[p]).toDouble();
    }
    final foo = cs[scores.length-1]>0?rng.nextDouble()*cs[scores.length-1]:-1.0;
    questionNumber = cs.indexWhere((e) => e>foo);
    question = tileset[questionNumber];
    String foz = solutions[questionNumber];
    for (var x in decrypt.keys) {
      foz = foz.replaceAll(x, decrypt[x]);
    }
    solution = foz;
    if(titleHint) { title=question; }
    if(cs[scores.length-1]>0) {
      say('$question.',language:language);
    } else {
      player.play('SMALL_CROWD_APPLAUSE-Yannick_Lemieux-recompressed.mp3',volume: 0.2);
      player2.play('joy.mp3',volume: 0.2);
      finaltimer = Timer(const Duration(milliseconds: 500), () {
        Navigator.popAndPushNamed(context, "/Win");
      });
    }
    answer = "";
    startTurn();
    gaveHint = false;
  }
  
  void setTiles(Map args) {
    if(args==oldargs) return;
    oldargs = args;
    tileset = args["spelling"].cast<String>();
    rows = args["keyboard"].cast<String>();
    titleHint = args["titleHint"];
    maxtime = args["maxtime"];
    decrypt = args["decrypt"];
    language = args["language"];
    keyboardshift = args["keyboardshift"];
    if(args.containsKey("solutions")) {
      solutions = args["solutions"].cast<String>();
    } else {
      solutions = tileset;
    }
    scores = tileset.map((e) => 0).toList();
    List<int> tilelens = tileset.map((e) => e.length).toList();
    maxTileLength = tilelens.reduce((e,v) => max(e,v));
    answers = List<String>.filled(maxAnswersLength, '');
    genQuestion();
  }
  
  void startTurn() {
    highlight = false;
    turnStart = DateTime.now();
    hinter?.cancel();
    hinter = Timer(Duration(seconds: maxtime), () {
      highlight = true; gaveHint = true; setState(() {}); });
  }
  
  String getAnswer() {
    return (titleHint?"$question=":"")+answer;
  }
  
  void press(key) {
    print(key);
    print(solution);
    if (answer.length < solution.length) {
      print(solution[answer.length]);
      if(key==solution[answer.length].toUpperCase()) {
        startTurn();
        answer = answer+solution[answer.length];
        if(answer.length == solution.length) {
          answers = answers.sublist(1);
          answers.add(getAnswer());
          if(!madeError) {
            scores[questionNumber] = min(scores[questionNumber] + (gaveHint?0:1),maxScore);
          }
          genQuestion();
        }
        setState(() {});
      } else {
        scores[questionNumber] = 0;
        madeError = true;
        player.play('fail-buzzer-01.mp3');
        setState(() {});
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    Map foo = (ModalRoute.of(context)?.settings.arguments ?? {}) as Map;
    setTiles(foo);
    final lens = rows.map((e) => e.length).toList();
    final maxl = lens.reduce((v,e) => max(v,e));
    final totl = lens.reduce((v,e) => v+e);
    return SafeArea(child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body:
        LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
          H = constraints.maxHeight;
          W = constraints.maxWidth;
          final W0=W/maxl, H0=H/(rows.length+maxAnswersLength+2.5);
          final W1=W/(maxl+2), H1=H/(rows.length+1);
          double y0,xrep,yrep;
          double barW;
          if(W0<=H0) {
            keyH = keyW = min(H0,W0);
            y0 = (H-(rows.length)*keyH);
            xrep = W-0.9*2*keyW;
            yrep = H-0.9*2*keyH-rows.length*keyH;
            barW = xrep-5;
          } else {
            keyH = keyW = min(H1,W1);
            y0 = (H-(rows.length)*keyH);
            xrep = W-0.9*2*keyW;
            yrep = H-0.9*2*keyH;
            barW = W;
          }
          var keys = List<Widget>.filled(totl+3, Container());
          var count = 0;
          final textW = W-keyW;
          final mysizes = textsizes.where((e) => e<textW/10).toList();
          final textH = (maxAnswersLength+1)*keyH;
          for(var j=0;j<rows.length;j++) {
            var rj = rows[j];
            for (var k = 0; k < rj.length; k++) {
              final color = (highlight && answer.length < solution.length && rj[k]==solution[answer.length].toUpperCase())?Colors.lightBlueAccent:Colors.white;
              keys[count] = makeButton(
                  text: rj[k],
                  onpress: () { press(rj[k]); },
                  width: keyW,
                  height: keyH,
                  x: (k+keyboardshift*.4*j) * keyW,
                  y: y0 +j * keyH,
                  marginLeft: 1,
                  marginRight: 1,
                  color: color,
                  marginTop: 1,
                  marginBottom:1);
              count = count+1;
            }
          }
          final barY = max(y0-1.8*keyH,textH+0.1*keyH);
          final barH = min(y0-0.1*keyH-barY,1.6*keyH);
          final textX = keyW/2;
          final textY = 0.5*(min(y0,barY)-textH);
          final S = (scores.reduce((e,v) => e+v))/(maxScore*scores.length);
          keys[count] = Positioned(
              left: xrep,
              top: yrep,
              child: SizedBox(
                width: 2*keyW*0.8,
                height: 2*keyH*0.8,
                child: Ink(
                  decoration: const ShapeDecoration(
                    color: Colors.lightGreen,
                    shape: Border(),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.announcement,size: 1*keyW),
                    color: Colors.white,
                    onPressed: () {
                      say('$question.',language:language);
                    },
                  ),
                ),
              ));
          final foo = "${answers.join("\n")}\n${getAnswer()}_";
          print(foo);
          keys[count+1] = Positioned(
              left: textX,
              top: textY,
              child: SizedBox(
                  width: textW,
                  height: textH,
                  child: AutoSizeText(
                      foo,
                      presetFontSizes: mysizes)
              ));
          keys[count+2] = Positioned(
              left: 0,
              top: barY,
              child: SizedBox(
                  width: barW,
                  height: barH,
                  child: Container(
                      margin: const EdgeInsets.all(2.0),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueAccent)
                      ),
                      child: LinearProgressIndicator(
                        value: S,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.lightGreenAccent),
                        backgroundColor: Colors.white,
                      ))));
          return Stack(children: keys);
        })));

  }
}
