import 'package:flutter/foundation.dart';

abstract class ChunkData {
  analyse(Uint8List bytes, int startOffset);
}
