import 'dart:io';

bool onPhone() {
  return Platform.isAndroid || Platform.isIOS;
}