import 'dart:io';

import 'package:image_utils/compress/compress.dart';
import 'package:image_utils/reader/jpeg/jpeg_reader.dart';
import 'package:image_utils/reader/png/png_reader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('File load test', () {
    ImageCompress compress = ImageCompress();
    compress.start('test_assets/images/test.png');
  });

  test('File isPng test', () async {
    File f = File('test_assets/images/test.png');
    Uint8List bytes = await f.readAsBytes();
    bool result = isPng(bytes);
    expect(result, true);
  });

  test('File ispng test on jpeg', () async {
    File f = File('test_assets/images/test.jpeg');
    Uint8List bytes = await f.readAsBytes();
    bool result = isPng(bytes);
    expect(result, false);
  });

  test('File isjpg test on jpeg', () async {
    File f = File('test_assets/images/test.jpeg');
    Uint8List bytes = await f.readAsBytes();
    bool result = isJpeg(bytes);
    expect(result, true);
  });

  test('File isjpg test on jpg', () async {
    File f = File('test_assets/images/test.jpg');
    Uint8List bytes = await f.readAsBytes();
    bool result = isJpeg(bytes);
    expect(result, true);
  });

  test('File isjpg test on png', () async {
    File f = File('test_assets/images/test.png');
    Uint8List bytes = await f.readAsBytes();
    bool result = isJpeg(bytes);
    expect(result, false);
  });
}
