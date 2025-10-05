import 'dart:io';
import 'package:flutter/material.dart';

Widget buildAuctionImage(
  String? path, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
}) {
  if (path == null || path.isEmpty) {
    // Placeholder si aucune image
    return Image.network(
      'https://picsum.photos/200/200',
      width: width,
      height: height,
      fit: fit,
    );
  }

  if (path.startsWith('http')) {
    // Si c’est une vraie URL internet
    return Image.network(path, width: width, height: height, fit: fit);
  } else {
    // Sinon on suppose que c’est un chemin local
    return Image.file(File(path), width: width, height: height, fit: fit);
  }
}
