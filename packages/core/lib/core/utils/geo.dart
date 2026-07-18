import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';

/// Great-circle distance between two points in kilometres.
double haversineKm(GeoPoint a, GeoPoint b) {
  const r = 6371.0;
  final dLat = _rad(b.latitude - a.latitude);
  final dLng = _rad(b.longitude - a.longitude);
  final h = math.pow(math.sin(dLat / 2), 2) +
      math.cos(_rad(a.latitude)) *
          math.cos(_rad(b.latitude)) *
          math.pow(math.sin(dLng / 2), 2);
  return 2 * r * math.asin(math.sqrt(h.toDouble()));
}

double _rad(double deg) => deg * math.pi / 180;
