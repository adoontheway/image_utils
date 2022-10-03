import 'dart:ffi';

import 'package:ado_image/compress/chunk.dart';
import 'package:ado_image/util/utils.dart';
import 'package:flutter/foundation.dart';

final Uint8List PNGHeader =
    Uint8List.fromList(<int>[0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);

/// check if it is png
isPng(Uint8List bytes) {
  if (bytes.length < 8) return false;
  var len = PNGHeader.length;
  for (var i = 0; i < len; i++) {
    if (PNGHeader[i] != bytes[i]) {
      return false;
    }
  }
  return true;
}

class PNGReader {
  Uint8List bytes;
  List chunks = [];
  PNGReader({required this.bytes});
  analyse() {
    int offset = 8;
    while (true) {
      CriticalChunk chunk = CriticalChunk();
      offset = chunk.analyse(bytes, offset);
      chunks.add(chunk);
    }
  }
}

class CriticalChunk {
  // length of this chunk: 4 bytes
  late int length;
  // type of this chunk: 4 bytes
  late String chunkType;
  // data of this chunk
  late ChunkData data;
  // crc check: 4 bytes
  // late int crc;
  analyse(Uint8List bytes, int offset) {
    this.length = toInt32(bytes, offset);
    this.chunkType = String.fromCharCodes(bytes, offset + 4, offset + 4 + 4);
    print(this.chunkType);
    if (this.chunkType == 'IHDR') {
      this.data = IHDR();
    } else if (this.chunkType == 'zTXt') {
      this.data = zTXt(length: this.length);
    } else if (this.chunkType == 'bKGD') {
      this.data = bKGD(length: this.length);
    }
    offset = offset + this.length + 12;
    // offset = this.data.analyse(bytes, offset + 4 + 4);
    return offset;
  }
}

/// 文件头数据块
class IHDR extends ChunkData {
  // width: 4 bytes
  late int width;
  // height: 4 bytes
  late int height;

  /// Bit depth: 1 byte
  /// indexed-colorful image:1,2,4,8
  /// grey image: 1,2,4,8,16
  /// true color: 8,16
  late int bitDepth;

  /// Color Type: 1 byte
  /// 0: grey image - 1,2,4,8,16
  /// 2: true color image - 8,16
  /// 3: indexed colorful image - 1,2,4,8
  /// 4: grey with alhpa channel - 8,16
  /// 6:trye color image with alhpa - 8, 16
  late int colorType;

  // compression method: 1 byte
  late int compressMethod;
  // filter method: 1 byte
  late int filterMethod;

  /// interiace method 是否隔行扫描
  late int interlaceMethod;

  late int crc;

  analyse(Uint8List bytes, int startOffset) {
    this.width = toInt32(bytes, startOffset);
    this.height = toInt32(bytes, startOffset + 4);
    this.bitDepth = bytes[startOffset + 4 + 4];
    this.colorType = bytes[startOffset + 4 + 5];
    this.compressMethod = bytes[startOffset + 4 + 6];
    this.filterMethod = bytes[startOffset + 4 + 7];
    this.interlaceMethod = bytes[startOffset + 4 + 8];
    this.crc = toInt32(bytes, startOffset + 4 + 9);
    return startOffset + 4 + 9 + 4;
  }
}

/// 压缩文本数据块
class zTXt extends ChunkData {
  int length;
  late Uint8List data;
  late int crc;
  zTXt({required this.length});
  analyse(Uint8List bytes, int startOffset) {
    this.data = bytes.sublist(startOffset, startOffset + this.length);
    this.crc = toInt32(bytes, startOffset + 4 + 9);
    return startOffset + this.length + 4;
  }
}

// 背景颜色数据块 在PLTE之后 IDAT 之前
class bKGD extends ChunkData {
  int length;
  late Uint8List data;
  late int crc;
  bKGD({required this.length});
  analyse(Uint8List bytes, int startOffset) {
    this.data = bytes.sublist(startOffset, startOffset + this.length);
    this.crc = toInt32(bytes, startOffset + 4 + 9);
    return startOffset + this.length + 4;
  }
}

/// 物理像素尺寸数据块
class pHYs extends ChunkData {
  int length;
  late Uint8List data;
  late int crc;
  pHYs({required this.length});
  analyse(Uint8List bytes, int startOffset) {
    this.data = bytes.sublist(startOffset, startOffset + this.length);
    this.crc = toInt32(bytes, startOffset + 4 + 9);
    return startOffset + this.length + 4;
  }
}

class tIME extends ChunkData {
  int length;
  late Uint8List data;
  late int crc;
  tIME({required this.length});
  analyse(Uint8List bytes, int startOffset) {
    this.data = bytes.sublist(startOffset, startOffset + this.length);
    this.crc = toInt32(bytes, startOffset + 4 + 9);
    return startOffset + this.length + 4;
  }
}

class PLTE {
  late int Red;
  late int Green;
  late int Blue;
}

class IDAT {}

class IEND {}

class AncillatyChunk {}

class cHRM {}

class gAMA {}

class hIST {}

class sBIT {}

class tEXt {}

class tRNS {}
