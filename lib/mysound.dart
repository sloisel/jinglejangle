// @dart=2.9
import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'gameboard.dart';

const hiragana = ["あ","い","う","え","お",
  "か","き","く","け","こ",
  "さ","し","す","せ","そ",
  "た","ち","つ","て","と",
  "な","に","ぬ","ね","の",
  "は","ひ","ふ","へ","ほ",
  "ま","み","む","め","も",
  "や","ゆ","よ",
  "ら","り","る","れ","ろ",
  "わ","を",
  "ん",
  "が","ぎ","ぐ","げ","ご",
  "ざ","じ","ず","ぜ","ぞ",
  "だ","ぢ","づ","で","ど",
  "ば","び","ぶ","べ","ぼ",
  "ぱ","ぴ","ぷ","ぺ","ぽ",
  "きゃ","きゅ","きょ",
  "しゃ","しゅ","しょ",
  "ちゃ","ちゅ","ちょ",
  "にゃ","にゅ","にょ",
  "ひゃ","ひゅ","ひょ",
  "みゃ","みゅ","みょ",
  "りゃ","りゅ","りょ",
  "ぎゃ","ぎゅ","ぎょ",
  "じゃ","じゅ","じょ",
  "びゃ","びゅ","びょ",
  "ぴゃ","ぴゅ","ぴょ"];

const katakana = ["ア","イ","ウ","エ","オ",
  "カ","キ","ク","ケ","コ",
  "サ","シ","ス","セ","ソ",
  "タ","チ","ツ","テ","ト",
  "ナ","ニ","ヌ","ネ","ノ",
  "ハ","ヒ","フ","ヘ","ホ",
  "マ","ミ","ム","メ","モ",
  "ヤ","ユ","ヨ",
  "ラ","リ","ル","レ","ロ",
  "ワ","ヲ",
  "ン",
  "ガ","ギ","グ","ゲ","ゴ",
  "ザ","ジ","ズ","ゼ","ゾ",
  "ダ","ヂ","ヅ","デ","ド",
  "バ","ビ","ブ","ベ","ボ",
  "パ","ピ","プ","ペ","ポ",
  "キャ","キュ","キョ",
  "シャ","シュ","ショ",
  "チャ","チュ","チョ",
  "ニャ","ニュ","ニョ",
  "ヒャ","ヒュ","ヒョ",
  "ミャ","ミュ","ミョ",
  "リャ","リュ","リョ",
  "ギャ","ギュ","ギョ",
  "ジャ","ジュ","ジョ",
  "ビャ","ビュ","ビョ",
  "ピャ","ピュ","ピョ"];

class Speaker implements Function {
  FlutterTts flutterTts;
  dynamic languages;
  final isLatin = RegExp(r"^[\000-\377]*$");
  final isJapanese = RegExp(r"^([一-龠]|[ぁ-ゔ]|[ァ-ヴー]|[ａ-ｚＡ-Ｚ０-９]|[々〆〤])*$");
  String language;
  double volume = 1.0;
  double pitch = 1.0;
  double rate = 0.5;
  bool initialized = false;
  dynamic voices;
  TtsState ttsState = TtsState.stopped;
  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;

  initTts() {
    if(initialized) return;
    initialized = true;
    flutterTts = FlutterTts();

    _getLanguages();
    flutterTts.setStartHandler(() {
      print("Playing");
      ttsState = TtsState.playing;
    });

    flutterTts.setCompletionHandler(() {
      print("Complete");
      ttsState = TtsState.stopped;
    });

    flutterTts.setErrorHandler((msg) {
      print("error: $msg");
      ttsState = TtsState.stopped;
    });
  }

  Future _getLanguages() async {
    voices = await flutterTts.getVoices;
    languages = await flutterTts.getLanguages;
    if (languages != null) {
    }
  }

  Future call(text, {language = "default"}) async {
    if(hiragana.contains(text)) {
      player.play('marina/${hiragana.indexOf(text)}.mp3');
      return;
    }
    if(katakana.contains(text)) {
      player.play('marina/${katakana.indexOf(text)}.mp3');
      return;
    }
//    final lang=isLatin.hasMatch(text)?"en-US":"ja-JP";
    final lang=(language=="default"?(isJapanese.hasMatch(text)?"ja-JP":"en-US"):language);
    print(lang);
    print(text);
    initTts();
    await flutterTts.setLanguage(lang);
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    var result = await flutterTts.speak(text);
    if (result == 1) ttsState = TtsState.playing;
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) ttsState = TtsState.stopped;
  }
}

var say = Speaker();
//AudioCache ac = AudioCache();

class SoundFX extends AudioCache {
  List<String> mp3Paths;
  bool do_init = true;
//  void play(String filename, {double volume: 1.0}) async {
  void init() async {
    if(do_init) {
      do_init=false;
      final manifestContent = await rootBundle.loadString('AssetManifest.json');

      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      mp3Paths = manifestMap.keys
          .where((String key) => key.contains('.mp3'))
          .map((s) => s.substring("assets/".length))
          .toList();
      print('Preloading:');
      print(mp3Paths);
      loadAll(mp3Paths);
    }
//    ac.play(filename);
  }
}
var player = SoundFX();

