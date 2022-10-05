import 'dart:typed_data';

int toInt16(Uint8List bytes, int start) {
  Uint8List bytesArray = Uint8List.sublistView(bytes, start, start + 2);
  ByteBuffer buffer = bytesArray.buffer;
  ByteData data = ByteData.view(buffer);
  int short = data.getInt16(0, Endian.big);
  return short;
}

int toInt32(Uint8List bytes, int start) {
  Uint8List bytesArray = bytes.sublist(start, start + 4);
  ByteBuffer buffer = bytesArray.buffer;
  ByteData data = ByteData.view(buffer);
  int short = data.getInt32(0, Endian.big);
  return short;
}

int toInt64(Uint8List bytes, int start) {
  Uint8List bytesArray = Uint8List.sublistView(bytes, start, start + 8);
  ByteBuffer buffer = bytesArray.buffer;
  ByteData data = ByteData.view(buffer);
  int short = data.getInt64(0, Endian.big);
  return short;
}

int toInt16_1(Uint8List bytes, int start, {bool bigEndian = true}) {
  int result = 0;
  for (int i = start; i < 2; i++) {
    if (bigEndian) {
      result += (bytes[i - start] << ((1 - i) * 8));
    } else {
      result += (bytes[start + i] << (i * 8));
    }
  }
  return result;
}

int toInt32_1(Uint8List bytes, int start, {bool bigEndian = true}) {
  int result = 0;
  for (int i = start; i < 4; i++) {
    if (bigEndian) {
      result += (bytes[i - start] << ((3 - i) * 8));
    } else {
      result += (bytes[start + i] << (i * 8));
    }
  }
  return result;
}
