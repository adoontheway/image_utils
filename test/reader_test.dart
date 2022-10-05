import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_utils/reader/jpeg/jpeg_reader.dart';
import 'package:image_utils/reader/png/png_reader.dart';

void main() {
  test('PNGReader CriticalChunk', () async {
    File f = File('assets/images/test.png');
    Uint8List bytes = await f.readAsBytes();
    PNGReader reader = PNGReader(bytes: bytes);
    reader.analyse();
  });

  test('PNGReader CriticalChunk', () async {
    File f = File('assets/images/test.png');
    Uint8List bytes = await f.readAsBytes();
    JPEGReader reader = JPEGReader(bytes: bytes);
    reader.analyse();
  });
}
