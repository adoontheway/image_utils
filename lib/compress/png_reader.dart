import 'package:image_utils/compress/chunk.dart';
import 'package:image_utils/util/utils.dart';
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
    while (offset > 0) {
      Chunk chunk = Chunk();
      offset = chunk.analyse(bytes, offset);
      chunks.add(chunk);
    }
  }
}

class Chunk {
  // length of this chunk: 4 bytes
  late int length;
  // type of this chunk: 4 bytes
  late String chunkType;
  // data of this chunk
  late ChunkData data;
  // crc check: 4 bytes
  // late int crc;
  analyse(Uint8List bytes, int offset) {
    length = toInt32(bytes, offset);
    chunkType = String.fromCharCodes(bytes, offset + 4, offset + 4 + 4);
    print(chunkType);
    if (chunkType == 'IHDR') {
      data = IHDR();
    } else if (chunkType == 'zTXt') {
      data = zTXt(length: length);
    } else if (chunkType == 'bKGD') {
      data = bKGD(length: length);
    } else if (chunkType == 'pHYs') {
      data = pHYs(length: length);
    } else if (chunkType == 'IDAT') {
      data = IDAT(length: length);
    } else if (chunkType == 'IEND') {
      data = IEND(length: length);
    } else if (chunkType == 'tIME') {
      data = tIME(length: length);
    } else {
      data = MaybeIgnored(length: length);
    }

    offset = data.analyse(bytes, offset + 4 + 4);
    // offset = offset + length + 12;
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
  /// Allowed combinations of color type and bit depth
  /// 0: Greyscalee - 1,2,4,8,16
  /// 2: Truecolour - 8,16
  /// 3: Indexed-colour - 1,2,4,8
  /// 4: Greyscale with alpha - 8,16
  /// 6: Truecolour with alpha - 8, 16
  late int colorType;

  // compression method: 1 byte
  late int compressMethod;

  /// filter method: 1 byte
  late int filterMethod;

  /// interiace method 是否隔行扫描
  late int interlaceMethod;

  late int crc;

  analyse(Uint8List bytes, int startOffset) {
    width = toInt32(bytes, startOffset);
    height = toInt32(bytes, startOffset + 4);
    bitDepth = bytes[startOffset + 4 + 4];
    colorType = bytes[startOffset + 4 + 5];
    compressMethod = bytes[startOffset + 4 + 6];
    filterMethod = bytes[startOffset + 4 + 7];
    interlaceMethod = bytes[startOffset + 4 + 8];
    crc = toInt32(bytes, startOffset + 4 + 9);
    return startOffset + 4 + 9 + 4;
  }
}

class MaybeIgnored extends ChunkData {
  int length;
  late Uint8List data;
  late int crc;
  MaybeIgnored({required this.length});
  analyse(Uint8List bytes, int startOffset) {
    data = bytes.sublist(startOffset, startOffset + length);
    crc = toInt32(bytes, startOffset + length);
    return startOffset + length + 4;
  }
}

// 背景颜色数据块 在PLTE之后 IDAT 之前
class bKGD extends ChunkData {
  int length;

  /// Color type 0 & 4
  late int greyScale;

  /// Color type 2 & 6
  late int red;
  late int green;
  late int blue;

  /// Color type 3
  late int paletteIndex;

  late int crc;
  bKGD({required this.length});
  analyse(Uint8List bytes, int startOffset) {
    greyScale = toInt16(bytes, startOffset);
    red = toInt16(bytes, startOffset + 2);
    green = toInt16(bytes, startOffset + 4);
    blue = toInt16(bytes, startOffset + 6);
    paletteIndex = bytes[startOffset + 8];
    crc = toInt32(bytes, startOffset + length);
    return startOffset + length + 4;
  }
}

/// 物理像素尺寸数据块
class pHYs extends ChunkData {
  int length;
  late int pixelPerUnitX;
  late int pixelPerUnitY;

  /// 0, unit is unknown; 1, unit is the metre
  late int unitSpecifier;
  late int crc;
  pHYs({required this.length});
  @override
  analyse(Uint8List bytes, int startOffset) {
    pixelPerUnitX = toInt32(bytes, startOffset);
    pixelPerUnitY = toInt32(bytes, startOffset + 4);
    unitSpecifier = bytes[startOffset + 4 + 4];
    crc = toInt32(bytes, startOffset + 4 + 5);
    return startOffset + length + 4;
  }
}

/// tIME : Image last-modification time
class tIME extends ChunkData {
  int length;
  late int year;
  late int month;
  late int day;
  late int hour;
  late int minute;
  late int second;
  late int crc;
  tIME({required this.length});
  @override
  analyse(Uint8List bytes, int startOffset) {
    year = toInt16(bytes, startOffset);
    month = bytes[startOffset + 2];
    day = bytes[startOffset + 2];
    hour = bytes[startOffset + 2];
    minute = bytes[startOffset + 2];
    second = bytes[startOffset + 2];
    crc = toInt32(bytes, startOffset + length);
    return startOffset + length + 4;
  }
}

class PLTE extends ChunkData {
  int length;
  late int crc;

  late int Red;
  late int Green;
  late int Blue;

  PLTE({required this.length});
  analyse(Uint8List bytes, int startOffset) {
    Red = bytes[startOffset];
    Green = bytes[startOffset];
    Blue = bytes[startOffset];
    crc = toInt32(bytes, startOffset + length);
    return startOffset + length + 4;
  }
}

class IDAT extends ChunkData {
  int length;
  late Uint8List data;
  late int crc;
  IDAT({required this.length});
  analyse(Uint8List bytes, int startOffset) {
    data = bytes.sublist(startOffset, startOffset + length);
    crc = toInt32(bytes, startOffset + length);
    return startOffset + length + 4;
  }
}

class IEND extends ChunkData {
  int length;
  late Uint8List data;
  late int crc;
  IEND({required this.length});
  analyse(Uint8List bytes, int startOffset) {
    return -1;
  }
}

/// Transparency Information
class tRNS extends ChunkData {
  int length;

  late int greySampleValue;
  late int redSampleValue;
  late int blueSampleValue;
  late int greenSampleValue;
  late int alphaForPaletteIndex0;
  late int alphaForPaletteIndex1;
  late int etc;
  late int crc;
  tRNS({required this.length});
  @override
  analyse(Uint8List bytes, int startOffset) {
    greySampleValue = toInt16(bytes, startOffset);
    redSampleValue = toInt16(bytes, startOffset + 2);
    blueSampleValue = toInt16(bytes, startOffset + 4);
    greenSampleValue = toInt16(bytes, startOffset + 6);
    alphaForPaletteIndex0 = bytes[startOffset + 8];
    alphaForPaletteIndex1 = bytes[startOffset + 9];
    etc = bytes[startOffset + 10];
    crc = toInt32(bytes, startOffset + length);
    return startOffset + length + 4;
  }
}

/// Color space information
class cHRM extends ChunkData {
  int length;

  late int whitePointX;
  late int whitePointY;
  late int RedX;
  late int RedY;
  late int GreenX;
  late int GreenY;
  late int BlueX;
  late int BlueY;
  late int crc;
  cHRM({required this.length});
  @override
  analyse(Uint8List bytes, int startOffset) {
    whitePointX = toInt32(bytes, startOffset);
    whitePointY = toInt32(bytes, startOffset + 4);
    RedX = toInt32(bytes, startOffset + 8);
    RedY = toInt32(bytes, startOffset + 12);
    GreenX = toInt32(bytes, startOffset + 16);
    GreenY = toInt32(bytes, startOffset + 20);
    BlueX = toInt32(bytes, startOffset + 24);
    BlueY = toInt32(bytes, startOffset + 28);

    crc = toInt32(bytes, startOffset + length);
    return startOffset + length + 4;
  }
}

/// gAMA :Image gamma
class gAMA extends ChunkData {
  int length;

  late int imageGamma;
  late int crc;
  gAMA({required this.length});
  @override
  analyse(Uint8List bytes, int startOffset) {
    imageGamma = toInt32(bytes, startOffset);
    crc = toInt32(bytes, startOffset + length);
    return startOffset + length + 4;
  }
}

/// iCCP: embedded ICC profile
/// ICC :  International Color Consortium
class iCCP extends ChunkData {
  int length;
  // 1-79 bytes character string
  late String profileName;
  // late int nullSeprator;
  late int compressionMethod;
  late String compressionProfile;
  late int crc;
  iCCP({required this.length});
  @override
  analyse(Uint8List bytes, int startOffset) {
    var i = 0;
    var endOfProfileName = -1;
    // find the separator
    while (i < 80) {
      if (bytes[i + startOffset] == 0) {
        endOfProfileName = i + startOffset;
        break;
      }
      i++;
    }
    if (endOfProfileName != -1) {
      profileName =
          String.fromCharCodes(bytes.sublist(startOffset, endOfProfileName));
      compressionMethod = bytes[endOfProfileName + 2];
      compressionProfile = String.fromCharCodes(
          bytes.sublist(endOfProfileName + 3, startOffset + length));
    }
    crc = toInt32(bytes, startOffset + length);
    return startOffset + length + 4;
  }
}

class sBIT extends ChunkData {
  int length;

  /// Color type 0
  late int significantGreyScaleBits;

  /// Color type 2 and 3
  late int significantRedBits;
  late int significantGreenBits;
  late int significantBlueBits;

  /// Color type 4
  late int significantGreyScaleBits4;
  late int significantAlphaBits4;

  /// Color type 6
  late int significantRedBits6;
  late int significantGreenBits6;
  late int significantBlueBits6;
  late int significantAlphaBits6;
  late int crc;
  sBIT({required this.length});
  @override
  analyse(Uint8List bytes, int startOffset) {
    significantGreyScaleBits = bytes[startOffset];
    significantRedBits = bytes[startOffset + 1];
    significantGreenBits = bytes[startOffset + 2];
    significantBlueBits = bytes[startOffset + 3];
    significantGreyScaleBits4 = bytes[startOffset + 4];
    significantAlphaBits4 = bytes[startOffset + 5];
    significantRedBits6 = bytes[startOffset + 6];
    significantGreenBits6 = bytes[startOffset + 7];
    significantBlueBits6 = bytes[startOffset + 8];
    significantAlphaBits6 = bytes[startOffset + 9];
    crc = toInt32(bytes, startOffset + length);
  }
}

/// sRGB: standard RGB color space
/// rendering intent:0,1,2,3
class sRGB extends ChunkData {
  int length;
  late int renderIntent;
  late int crc;
  sRGB({required this.length});
  @override
  analyse(Uint8List bytes, int startOffset) {
    renderIntent = bytes[startOffset];
    crc = toInt32(bytes, startOffset + length);
  }
}

/// tEXt : Texture data
class tEXt extends ChunkData {
  int length;
  late String keyword;
  // late int nullSeprator;
  late String textString;
  late int crc;
  tEXt({required this.length});
  @override
  analyse(Uint8List bytes, int startOffset) {
    var i = 0;
    var endOfKeyword = -1;
    // find the separator
    while (i < 80) {
      if (bytes[i + startOffset] == 0) {
        endOfKeyword = i + startOffset;
        break;
      }
      i++;
    }
    if (endOfKeyword != -1) {
      keyword = String.fromCharCodes(bytes.sublist(startOffset, endOfKeyword));
      // null seperator have 1 byte
      textString = String.fromCharCodes(
          bytes.sublist(endOfKeyword + 1, startOffset + length));
    }
    crc = toInt32(bytes, startOffset + length);
    return startOffset + length + 4;
  }
}

/// zTXt :  Compressed texture data 压缩文本数据块
class zTXt extends ChunkData {
  int length;
  // 1-79 bytes character string
  late String keyword;
  // late int nullSeprator;
  late int compressionMethod;
  // n bytes
  late String compressedTextData;
  late int crc;
  zTXt({required this.length});
  @override
  analyse(Uint8List bytes, int startOffset) {
    var i = 0;
    var endOfProfileName = -1;
    // find the separator
    while (i < 80) {
      if (bytes[i + startOffset] == 0) {
        endOfProfileName = i + startOffset;
        break;
      }
      i++;
    }
    if (endOfProfileName != -1) {
      keyword =
          String.fromCharCodes(bytes.sublist(startOffset, endOfProfileName));
      compressionMethod = bytes[endOfProfileName + 1];
      compressedTextData = String.fromCharCodes(
          bytes.sublist(endOfProfileName + 2, startOffset + length));
    }
    crc = toInt32(bytes, startOffset + length);
    return startOffset + length + 4;
  }
}

/// iTXt :  International texture data 压缩文本数据块
class iTXt extends ChunkData {
  int length;
  // 1-79 bytes character string
  late String keyword;
  // late int nullSeprator;
  late int compressionFlag;
  late int compressionMethod;
  late String languageTag;
  // late int nullSeprator;
  // 0 or more bytes
  late String translatedKeyword;
  // late int nullSeprator;
  // 0 or n bytes
  late String text;
  late int crc;
  iTXt({required this.length});
  @override
  analyse(Uint8List bytes, int startOffset) {
    var proceedIndex = startOffset;
    var i = 0;
    var nullIndex = -1;
    // find the separator
    while (i < 80) {
      if (bytes[i + startOffset] == 0) {
        nullIndex = i + startOffset;
        break;
      }
      i++;
    }
    if (nullIndex != -1) {
      keyword = String.fromCharCodes(bytes.sublist(startOffset, nullIndex));
      compressionFlag = bytes[nullIndex + 1];
      compressionMethod = bytes[nullIndex + 2];
      proceedIndex = nullIndex + 3;
      // exclude 0 bytes
      if (bytes[proceedIndex] != 0) {
        nullIndex = -1;
        i = 1;
        while (i < 500) {
          // fixme: the limit is not 500, and also no limit
          if (bytes[i + proceedIndex] == 0) {
            nullIndex = i + proceedIndex;
            break;
          }
          i++;
        }
        // this is 0 or
        if (nullIndex != -1) {
          languageTag = String.fromCharCodes(bytes, proceedIndex, nullIndex);
          proceedIndex = nullIndex;
        }
      }

      // 3.
      proceedIndex++;
      if (bytes[proceedIndex] != 0) {
        nullIndex = -1;
        i = 1;
        while (i < 500) {
          // fixme: the limit is not 500, and also no limit
          if (bytes[i + proceedIndex] == 0) {
            nullIndex = i + proceedIndex;
            break;
          }
          i++;
        }
        // this is 0 or more
        if (nullIndex != -1) {
          translatedKeyword =
              String.fromCharCodes(bytes, proceedIndex, nullIndex);
          proceedIndex = nullIndex + 1;
        }
      }

      text = String.fromCharCodes(bytes, proceedIndex, startOffset + length);
    }

    crc = toInt32(bytes, startOffset + length);
    return startOffset + length + 4;
  }
}

/// hIST: Image histogram
class hIST extends ChunkData {
  int length;
  //
  late int frequency;
  late int crc;
  hIST({required this.length});
  @override
  analyse(Uint8List bytes, int startOffset) {
    frequency = toInt16(bytes, startOffset);
    return startOffset + length + 4;
  }
}

//sPLT : Suggested palette
class sPLT extends ChunkData {
  int length;
  late String paletteName;
  // late int nullSeperator;
  late int sampleDepth;

  /// 1or 2 byte: depending on sample depth-> 8 for 1, 16 for 2
  late int red;
  late int green;
  late int blue;
  late int alpha;
  late int frequency;
  late int crc;
  sPLT({required this.length});
  analyse(Uint8List bytes, int startOffset) {
    var i = 0;
    var nullIndex = -1;
    // find the separator
    while (i < 80) {
      if (bytes[i + startOffset] == 0) {
        nullIndex = i + startOffset;
        break;
      }
      i++;
    }
    if (nullIndex != -1) {
      paletteName = String.fromCharCodes(bytes.sublist(startOffset, nullIndex));
      sampleDepth = toInt16(bytes, nullIndex + 1);
      if (sampleDepth == 8) {
        red = bytes[nullIndex + 3];
        green = bytes[nullIndex + 4];
        blue = bytes[nullIndex + 5];
        alpha = bytes[nullIndex + 6];
        frequency = toInt16(bytes, nullIndex + 7);
      } else if (sampleDepth == 16) {
        red = toInt16(bytes, nullIndex + 3);
        green = toInt16(bytes, nullIndex + 5);
        blue = toInt16(bytes, nullIndex + 7);
        alpha = toInt16(bytes, nullIndex + 9);
        frequency = toInt16(bytes, nullIndex + 11);
      }
    }
    crc = toInt32(bytes, startOffset + length);
    return startOffset + length + 4;
  }
}
