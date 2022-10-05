import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_utils/util/utils.dart';

void main() {
  test('toInt16_1  test', () {
    int refer = 0xef12;
    Uint8List raw = Uint8List.fromList([0xef, 0x12]);
    var result = toInt16_1(raw, 0);
    expect(refer, result);
  });

  test('toInt32_1 enough bytes  test', () {
    int refer = 0xef123344;
    Uint8List raw = Uint8List.fromList([0xef, 0x12, 0x33, 0x44]);
    var result = toInt32_1(raw, 0);
    expect(refer, result);
  });
}
