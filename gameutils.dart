library gameutils;

import 'dart:html';

void gSetVisible(bool v, String name) {
  var el = querySelector("#" + name);
  if (el == null) {
    return;
  }
  if (v) {
    el.classes.remove("invisible");
  } else {
    el.classes.add("invisible");
  }
}

void gSetTangible(bool v, String name) {
  var el = querySelector("#" + name);
  if (el == null) {
    return;
  }
  if (v) {
    el.classes.remove("intangible");
  } else {
    el.classes.add("intangible");
  }
}

String gAsciiArt(String art) {
  return art.replaceAll("\n", "<br>").replaceAll(" ", "&nbsp;");
}