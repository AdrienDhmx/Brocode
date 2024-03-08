import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

/// print the instance of all the children of the component and their children
void printChildren(Component parent, {int level = 0}) {
  if(!kDebugMode) {
    return;
  }

  for(int i = 0; i < parent.children.length; ++i) {
    final child = parent.children.elementAt(i);
    String levelIndicator = "";
    for(int j = 0; j < level; ++j) {
      levelIndicator += "  ";
    }
    debugPrint(levelIndicator + child.toString());
    if(child.hasChildren) {
      printChildren(child, level: level + 1);
    }
  }
}