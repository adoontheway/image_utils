import 'dart:io';

import 'package:image_utils/compress/png_reader.dart';
import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart' show rootBundle;

typedef ProgressCallback = Function(num progress);
typedef ErrorCallback = Function(String errorInfo);
typedef SuccessCallback = Function();

class ImageCompress {
  ProgressCallback? onProgress;
  ErrorCallback? onError;
  SuccessCallback? onSuccess;
  start(String imagePath) async {
    File f = File(imagePath);
    bool exsit = await f.exists();
    if (!exsit) {
      onError ?? onError!('file $imagePath not exist');
      print('file $imagePath not exist');
      return;
    }
    f.readAsBytes().then((value) => analyse(value));
    // ByteData bytes = await rootBundle.load('assets/images/test.png');
  }

  // Uint8List === byte[]
  analyse(Uint8List imageBytes) {
    Uint8List bytes = Uint8List.fromList(imageBytes);
    var ispng = isPng(bytes);
  }
}

enum CompressType {
  Auto,
  Manual,
}

class CompressOptions {
  CompressType compressType;
  String path;
  CompressOptions({this.compressType = CompressType.Auto, required this.path});
}
