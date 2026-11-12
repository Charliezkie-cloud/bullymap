import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

Future<Uint8List> svgToPng(
  String asset, {
  required double width,
  required double height,
  double pixelRatio = 3,
}) async {
  final info = await vg.loadPicture(SvgAssetLoader(asset), null);
  final w = (width * pixelRatio).round();
  final h = (height * pixelRatio).round();

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  
  canvas.scale(w / info.size.width, h / info.size.height);
  canvas.drawPicture(info.picture);

  final image = await recorder.endRecording().toImage(w, h);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);

  info.picture.dispose();
  image.dispose();
  
  return data!.buffer.asUint8List();
}