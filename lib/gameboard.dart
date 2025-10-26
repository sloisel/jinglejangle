import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'dart:math';
import 'dart:async';
import 'mysound.dart';
import 'package:flutter/scheduler.dart';


final textsizes = <double>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 33, 36, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 200, 220, 240, 260, 280, 300].reversed.toList();
enum TtsState { playing, stopped }

Widget makeButton({
  required String text,
  required Function onpress,
  required double width,
  required double height,
  required double x,
  required double y,
  double marginLeft = 5,
  double marginRight = 5,
  double marginTop = 5,
  double marginBottom = 5,
  Color color = Colors.grey,
  String fontFamily = "Roboto"
}) {
  return Positioned(
      left: x + marginLeft,
      top: y + marginTop,
      child: SizedBox(
          width: width - marginLeft - marginRight,
          height: height - marginTop - marginBottom,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(height/5),
                  side: const BorderSide(color: Colors.blue)
              ),
            ),
            onPressed: onpress as void Function()?,
            child: Center(
                child: AutoSizeText(
                  text,
                  presetFontSizes: textsizes,
                  style: TextStyle(fontFamily: fontFamily),
                  textAlign: TextAlign.center,
                )),
          )));
}

class Tile {
  String label;
  double x, y, dy;

  Tile(this.label, this.x, this.y, this.dy);
}


class GameBoard extends StatefulWidget {
  const GameBoard({Key? key}) : super(key: key);

  @override
  GameBoardState createState() => GameBoardState();
}


class GameBoardState extends State<GameBoard> {
  Timer? finaltimer;
  late List tileset;
  List? oldtileset;
  late List hints;
  late Map args;
  late Map homonyms;
  late List<int> score;
  late double H, W;
  double oldH = 0, oldW = 0;
  late double wtile, htile;
  late double pad;
  late List<List<Tile?>> tiles;
  late int rows, cols, ntiles;
  int? questionNumber;
  int lastdt=0, numTiles=10;
  String gametitle = "";
  late List<Widget> tilesW;
  String question = "";
  late String language;
  late String fontFamily;
  late DateTime time, oldtime;
  DateTime? turnStart;
  late bool madeError;
  late bool titleHint;
  late Random rng;
  double elapsed = 0;
  final blinktime = 12;
  final fasttime = 6;

  void setTiles(Map args) {
    if(args==this.args) return;
    this.args = args;
    List tiles = args['tileset'];
    List hints = args['hints'];
    Map homonyms = args['homonyms'];
    fontFamily = args["fontChoice"];
    tileset = tiles;
    this.hints = hints;
    this.homonyms = homonyms;
    titleHint = args['titleHint'];
    numTiles = args['numTiles'];
    language = args['language'];
    score = List<int>.filled(tiles.length, 0);
  }

  GameBoardState() {
    args = {};
    setTiles({'tileset': ["1","2","3","4","5"],'homonyms': {},'hints':["1","2","3","4","5"],'fontChoice':'Roboto','titleHint':false,'numTiles':10,'language':'en'});
    oldtime = DateTime.now();
    rng = Random();
  }


  @override
  void dispose() {
    super.dispose();
    finaltimer?.cancel();
  }

  void doPhysics() {
    final g = htile * 50.0;
    time = DateTime.now();
    final dt = min(time.difference(oldtime).inMicroseconds / 1000000.0, 0.5);
    lastdt = (dt*1000).round();
    oldtime = time;
    for (var j = 0; j < tiles.length; j++) {
      var t0 = tiles[j];
      t0.sort((a, b) => (b?.y ?? 0).compareTo(a?.y ?? 0));
      for (var k = 0; k < t0.length; k++) {
        if (t0[k] == null) continue;
        t0[k]!.dy += dt * g;
        t0[k]!.y += dt * t0[k]!.dy;
        var maxy = H - (pad + 1) * htile;
        if (k > 0 && t0[k - 1] != null) {
          maxy = min(maxy, t0[k - 1]!.y - htile);
        }
        if (t0[k]!.y >= maxy) {
          t0[k]!.y = maxy;
          t0[k]!.dy = 0;
        }
      }
    }
  }

  void givehint() {
    say(titleHint?gametitle:question,language:language);
  }

  bool boardvalid() => tiles.any((e) => e.any((f) => question == (f?.label ?? '')));

  void clearboard() {
    tiles = List<List<Tile?>>.filled(cols, []);
    for (var j = 0; j < cols; j++) {
      tiles[j] = List<Tile?>.filled(rows, null);
    }
  }

  void genboard() {
    if (!tileset.contains(question)) {
      var cs = List<double>.filled(score.length, 0.0);
      num P(x) => pow(4.0-x,2);
      cs[0] = P(score[0]).toDouble();
      for (var p=1;p<score.length;p++) {
        cs[p] = cs[p-1]+P(score[p]).toDouble();
      }
      final foo = cs[score.length-1]>0?rng.nextDouble()*cs[score.length-1]:-1.0;
      questionNumber = cs.indexWhere((e) => e>foo);
      question = tileset[questionNumber!];
      if(titleHint) { gametitle = hints[questionNumber!]; }

      turnStart = DateTime.now();
      madeError = false;
      if(cs[score.length-1]>0) {
        givehint();
      } else {
        player.play('SMALL_CROWD_APPLAUSE-Yannick_Lemieux-recompressed.mp3',volume: 0.2);
        player2.play('joy.mp3',volume: 0.2);
        finaltimer = Timer(const Duration(milliseconds: 500), () {
          Navigator.popAndPushNamed(context, "/Win");
        });
      }
    }
    while (true) {
      for (var j = 0; j < cols; j++) {
        for (var k = 0; k < rows; k++) {
          tiles[j][k] = tiles[j][k] ?? Tile(tileset[rng.nextInt(tileset.length)], j * wtile.toDouble(), -k * (htile * 1.5), 0);
        }
      }
      if (boardvalid()) return;
      clearboard();
    }
  }

  void updateElapsed() {
    final time = DateTime.now();
    elapsed = turnStart != null ? (time.difference(turnStart!).inMicroseconds/1e6):10000;
  }

  bool isCorrect(String text) {
    final h1 = homonyms[text] ?? -1;
    final h2 = homonyms[question] ?? -2;
    return text==question || h1==h2;
  }
  
  void press(int j, int k) {
    if (tiles[k][j] == null) return;
    if (isCorrect(tiles[k][j]!.label)) {
      updateElapsed();
      final points = (madeError || elapsed>blinktime)?0:((elapsed<fasttime)?2:1);
      score[questionNumber!] = min(4, score[questionNumber!] + points);
      for (var p = 0; p < cols; p++) {
        tiles[p][j] = null;
      }
      for (var p = 0; p < rows; p++) {
        tiles[k][p] = null;
      }
      question = "";
      genboard();
    } else {
      madeError = true;
      score[questionNumber!] = 0;
      player.play('fail-buzzer-01.mp3');
    }
  }

  @override
  Widget build(BuildContext context) {
    Map foo = (ModalRoute.of(context)?.settings.arguments ?? {}) as Map;
    setTiles(foo);
    SchedulerBinding.instance.addPostFrameCallback((_) { setState(() {}); });
    return SafeArea(child: Scaffold(
      appBar: AppBar(title: Text(gametitle, style: const TextStyle(fontSize: 30.0),)),
      body:
      LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
        H = constraints.maxHeight;
        W = constraints.maxWidth;
        if (H != oldH || W != oldW || tileset != oldtileset) {
          oldtileset = tileset;
          oldH = H;
          oldW = W;
          const R = 3;
          final N = numTiles;
          const p = 1.5;
          final disc = sqrt(4 * H * N * R * W + W * W * p * p) - W * p;
          final w = disc / (2 * N), h = disc / (2 * N * R);
          int cols0 = max((W / w).floor(), 2), rows0 = max((H / h - p).floor(), 2);
          ntiles = 99999;
          for (var j = cols0; j <= cols0 + 1; j++) {
            for (var k = rows0; k <= rows0 + 1; k++) {
              if ((j * k - N).abs() < (ntiles - N).abs()) {
                rows = k;
                cols = j;
                ntiles = j * k;
              }
            }
          }
          wtile = W / cols;
          htile = H / (rows + p);
          pad = p;
          clearboard();
          genboard();
        }
        doPhysics();
        updateElapsed();
        var t = List<Widget>.filled(ntiles + 2, Container());
        for (var j = 0; j < rows; j++) {
          for (var k = 0; k < cols; k++) {
            if (tiles[k][j] == null) continue;
            final color = (elapsed>30 && (elapsed%1)<0.1 && isCorrect(tiles[k][j]!.label)) ? Colors.yellowAccent : Colors.white;
            t[j * cols + k] = makeButton(
              text: tiles[k][j]!.label,
              x: tiles[k][j]!.x,
              y: tiles[k][j]!.y,
              onpress: () {
                press(j, k);
                setState(() {});
              },
              width: wtile,
              height: htile,
              color: color,
              fontFamily: fontFamily,
            );
          }
        }
        t[ntiles] = Positioned(
            left: W - pad * htile*0.9,
            top: H - pad * htile*0.9,
            child: SizedBox(
              width: pad * htile*0.8,
              height: pad * htile*0.8,
              child: Ink(
                decoration: const ShapeDecoration(
                  color: Colors.lightGreen,
                  shape: Border(),
                ),
                child: IconButton(
                  icon: Icon(Icons.announcement,size: pad*htile/2),
                  color: Colors.white,
                  onPressed: () {
                    givehint();
                  },
                ),
              ),
            ));
        final S = score.reduce((a, b) => a + b) / (4 * score.length);
        t[ntiles + 1] = Positioned(
            left: 0,
            top: H - (0.5 * (1 + pad)) * htile,
            child: SizedBox(
                width: W - pad * htile,
                height: htile,
                child: Container(
                    margin: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent)
                    ),
                    child: LinearProgressIndicator(
                      value: S,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.lightGreenAccent),
                      backgroundColor: Colors.white,
                    ))));
        tilesW = t;
        return Stack(children: tilesW);
      }),
    ));
  }
}
