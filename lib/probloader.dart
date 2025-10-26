// @dart=2.9
import 'dart:math';
import 'mysound.dart';

Map<String,int> makeHomonyms(
    List<List<String>> homonyms_,
    Map<String,int> H
    ) {
  H ??= Map<String,int>();
  if(homonyms_==null || homonyms_.length==0) return H;
  var homonyms = List<List<String>>();
  H.forEach((k,v) {
    while(homonyms.length<=v) homonyms.add(List<String>());
    homonyms[v].add(k);
  });
  homonyms.addAll(homonyms_);
  H = Map<String,int>();
  for(var j=0;j<homonyms.length;j++)
  {
    final h=homonyms[j];
    int b=j;
    Set<int> mods = Set<int>();
    mods.add(b);
    h.forEach((x) {
      if(H.containsKey(x)) {
        if(H[x]!=b) {
          mods.add(max(b,H[x]));
          b = min(b,H[x]);
        }
      }
    });
    mods.add(j);
    mods.forEach((k) {
      final w = homonyms[k];
      w.forEach((x) { H[x] = b; });
    });
  }
  return H;
}

Map<String,dynamic> fixprobset2(Map<String,dynamic> P,
    {Map<String,int> homonyms }) {
  var foo = Map<String,dynamic>.from(P);
  if(!foo.containsKey("name")) {
    foo["name"] = ((foo["spelling"] ?? foo["tileset"]) as List).join(" ");
  }
  if(foo.containsKey("tileset") && !foo.containsKey("hints")) {
    foo["hints"] = foo["tileset"];
  }
  var baz = List<List<String>>();
  var boo = foo["homonyms"] ?? [];
  for(var k=0;k<boo.length;k++) {
    var bak = List<String>();
    bak.addAll(boo[k].cast<String>());
    baz.add(bak);
  }
  homonyms = makeHomonyms(baz,homonyms);
  foo["homonyms"] = homonyms;
  void copyOption(x,y,z,w) {
    if(!x.containsKey(z)) x[z] = w;
    if(y.containsKey(z)) return;
    y[z] = x[z];
  };
  if(foo.containsKey("children")) {
    var Q = List<Map<String,dynamic>>.from(foo["children"]);
    for(var k=0; k<Q.length;k++) {
      copyOption(foo,Q[k],"fontChoices",["Roboto"]);
      copyOption(foo,Q[k],"keyboard",["QWERTYUIOP","ASDFGHJKL","ZXCVBNM"]);
      copyOption(foo,Q[k],"titleHint",false);
      copyOption(foo,Q[k],"maxtime",15);
      copyOption(foo,Q[k],"numTiles",10);
      copyOption(foo,Q[k],"language","detect");
      copyOption(foo,Q[k],"decrypt",{});
      copyOption(foo,Q[k],"keyboardshift",1.0);
      Q[k] = fixprobset2(Q[k],homonyms:homonyms);
    }
    foo["children"] = Q;
  }
  return foo;
}

