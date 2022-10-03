import 'dart:io';

import 'package:image_utils/compress/compress.dart';
import 'package:image_utils/compress/png_reader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('File load test', () {
    ImageCompress compress = ImageCompress();
    compress.start('assets/images/test.png');
  });

  test('File isPng test', () async {
    File f = File('assets/images/test.png');
    Uint8List bytes = await f.readAsBytes();
    bool result = isPng(bytes);
    expect(result, true);
  });

  test('File ispng test on jpeg', () async {
    File f = File('assets/images/test.jpeg');
    Uint8List bytes = await f.readAsBytes();
    bool result = isPng(bytes);
    expect(result, false);
  });

  test('PNGReader CriticalChunk', () async {
    File f = File('assets/images/test.png');
    Uint8List bytes = await f.readAsBytes();
    PNGReader reader = PNGReader(bytes: bytes);
    reader.analyse();
  });
}
