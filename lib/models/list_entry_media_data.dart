import 'package:flutter/foundation.dart';

class ListEntryMediaData {
  final int id;
  final String title;
  final String cover;
  final String format;
  final double score;
  final int progress;
  final String totalEpCount;

  ListEntryMediaData({
    @required this.id,
    @required this.title,
    @required this.cover,
    @required this.format,
    @required this.score,
    @required this.progress,
    @required this.totalEpCount,
  });
}