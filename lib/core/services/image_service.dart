import 'package:embutido_tracker/core/logging/logger_access.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class ImageService {
  Uint8List normalizeToPng(Uint8List imageBytes) {
    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception("Invalid image file");

    final converted = Uint8List.fromList(img.encodePng(image));
    LoggerAccess.logger.debug(
      "Input size: ${imageBytes.length}, Output size: ${converted.length}",
    );
    return converted;
  }
}
