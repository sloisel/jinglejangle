import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'gameboard.dart';
import 'mysound.dart';
import 'probloader.dart';


class PreGame extends StatefulWidget {
  const PreGame({Key? key}) : super(key: key);

  @override
  PreGameState createState() => PreGameState();
}

class PreGameState extends State<PreGame> {
  int fontChoice = 0;
  @override
  Widget build(BuildContext context) {
    Map args = (ModalRoute.of(context)?.settings.arguments ?? {}) as Map;
    late List tileset;
    late String nav;
    print("i love you");
    if(args.containsKey('tileset')) {
      tileset = args['tileset'];
      nav = "/GameBoard";
    } else if(args.containsKey('spelling')) {
      tileset = args['spelling'];
      nav = "/Spelling";
    } else if(args.containsKey('arithmetic')) {
      print("hiyo");
      print(args);
      tileset = args['arithmetic'];
      nav = "/Arithmetic";
    } else {
      tileset = [];
      nav = "/";
    }
    String name=args['name'] ?? '';
    final fc = args["fontChoices"];
    args["fontChoice"] = fc[fontChoice];
    List<Widget> L = []; //[Text("hi")];
    if(fc.length>1) {
      for(var k=0;k<fc.length;++k) {
        L.add(
            RadioListTile<int>(
              title: Text(fc[k],style: const TextStyle(fontSize: 30)),
              value: k,
              groupValue: fontChoice,
              onChanged: (int? value) {
                if (value != null) {
                  fontChoice = value;
                  args["fontChoice"] = value;
                  setState(() { });
                }
              },
            )
        );
      }
    }
    var w = List<Widget>.filled(tileset.length, Container());
    for(var k=0;k<tileset.length;k++) {
      w[k] = Container(
          padding: const EdgeInsets.all(8),
          height:60,
          child: ElevatedButton(
            onPressed: (() => say(tileset[k])),
            style: ElevatedButton.styleFrom(
              elevation: 6.0,
              padding: const EdgeInsets.only(left: 20, right:20 ),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: const StadiumBorder(
                  side: BorderSide(
                    width: 1,
                    color: Colors.blueAccent,
                  )),
            ),
            child: AutoSizeText(
              tileset[k],
              presetFontSizes: textsizes,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: "NotoSansJP"),
            ),
          ));
    }
//    L[0] = Wrap(children: w);

    return SafeArea(child: Scaffold(
      appBar: AppBar(title: Text(name)),
      body: SingleChildScrollView(child: Wrap(children: w)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.popAndPushNamed(context, nav, arguments: args);
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.arrow_forward_ios),
      ),
      bottomNavigationBar: L.isNotEmpty?BottomAppBar(child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: L))):null,
    ));
  }
}

class Win extends StatefulWidget {
  const Win({Key? key}) : super(key: key);

  @override
  WinState createState() => WinState();
}

class WinState extends State<Win> {
  Timer? finish;
  @override
  void dispose() {
    super.dispose();
    finish?.cancel();
  }
  @override
  Widget build(BuildContext context) {
    finish ??= Timer(const Duration(seconds: 7), () {
      Navigator.pop(context);
    });
    return Scaffold(
      appBar: AppBar(title: const Text("You Win!")),
      body:
      Center( child:
      Image.asset('assets/images/dancing.gif', fit: BoxFit.contain),
      ),
    );
  }
}

class Selector extends StatefulWidget {
  const Selector({Key? key}) : super(key: key);

  @override
  SelectorState createState() => SelectorState();
}

class SelectorState extends State<Selector> {
  Map? problemset;
  bool requested = false;
  @override
  Widget build(BuildContext context) {
    if(!requested) {
      requested = true;
      Future<String> ps = rootBundle.loadString('assets/problemset.json');
      ps.then((val) {
        problemset = fixprobset2(jsonDecode(val));
        setState(() {});
      });
    }
    say.initTts();
    player.init();
    if (problemset == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Loading...")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final Map foo = (ModalRoute.of(context)?.settings.arguments ?? problemset) as Map;
    String name = foo["name"] ?? "";
    final entries = List<String>.from(foo["children"].map((x)=>x["name"]));
    final routenames = (
        List<String>.from(foo["children"].map((x) {
          final target=(x.containsKey("tileset") || x.containsKey('spelling') || x.containsKey('arithmetic')?'/PreGame':
          x.containsKey("children")?'/':'');
          print(x);
          print(target);
          return target;}))
    );
    final routeargs = foo["children"];

    final lv = (ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: entries.length,
        itemBuilder: (BuildContext context, int index) {
          final theText = (Text(entries[index],style: routenames[index]==''?const TextStyle(fontSize:25,fontWeight: FontWeight.bold,color: Colors.blue):const TextStyle(fontSize:18), overflow: TextOverflow.ellipsis));
          return Container(
            margin: const EdgeInsets.only(top: 10.0),
            height: 50,
            child: routenames[index]==''?Center(child:theText):Center(child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.blue)
                ),
              ),
              onPressed: () {
                if(routenames[index]!='') {
                  Navigator.pushNamed(context,
                      routenames[index],
                      arguments: routeargs[index]);
                }
              },
              child: Align(alignment: Alignment.centerLeft, child: theText),/*AutoSizeText(
                    entries[index],
                    presetFontSizes: textsizes,
                    textAlign: TextAlign.center,
                  )*/
            )),
          );
        }
    ));
    return SafeArea(child: Scaffold(
        appBar: AppBar(title: Text(name)),
        body: lv
    ));
  }
}
