import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/enums/list_status.dart';
import 'package:otraku/models/date_time_mapping.dart';
import 'package:otraku/models/page_object.dart';

class MediaOverview extends PageObject {
  final String preferredTitle;
  final String romajiTitle;
  final String englishTitle;
  final String nativeTitle;
  final List<String> synonyms;
  final String cover;
  final String banner;
  final String description;
  final String format;
  final String status;
  ListStatus entryStatus;
  final int nextEpisode;
  final String timeUntilAiring;
  final int episodes;
  final String duration;
  final int chapters;
  final int volumes;
  final String startDate;
  final String endDate;
  final String season;
  final String averageScore;
  final String meanScore;
  final int popularity;
  final List<String> genres;
  final Map<String, int> studios;
  final Map<String, int> producers;
  final String source;
  final String hashtag;
  final String countryOfOrigin;

  MediaOverview._({
    @required int id,
    @required Browsable browsable,
    @required bool isFavourite,
    @required int favourites,
    @required this.preferredTitle,
    @required this.romajiTitle,
    @required this.englishTitle,
    @required this.nativeTitle,
    @required this.synonyms,
    @required this.cover,
    @required this.banner,
    @required this.description,
    @required this.format,
    @required this.status,
    @required this.entryStatus,
    @required this.nextEpisode,
    @required this.timeUntilAiring,
    @required this.episodes,
    @required this.duration,
    @required this.chapters,
    @required this.volumes,
    @required this.startDate,
    @required this.endDate,
    @required this.season,
    @required this.averageScore,
    @required this.meanScore,
    @required this.popularity,
    @required this.genres,
    @required this.studios,
    @required this.producers,
    @required this.source,
    @required this.hashtag,
    @required this.countryOfOrigin,
  }) : super(
          id: id,
          browsable: browsable,
          isFavourite: isFavourite,
          favourites: favourites,
        );

  factory MediaOverview(Map<String, dynamic> map) {
    String duration;
    if (map['duration'] != null) {
      int time = map['duration'];
      int hours = time ~/ 60;
      int minutes = time % 60;
      duration = (hours != 0 ? '$hours hours, ' : '') + '$minutes mins';
    }

    String season;
    if (map['season'] != null) {
      season = map['season'];
      season = season[0] + season.substring(1).toLowerCase();
      if (map['seasonYear'] != null) season += ' ${map["seasonYear"]}';
    }

    final Map<String, int> studios = {};
    final Map<String, int> producers = {};
    if (map['studios'] != null) {
      final List<dynamic> companies = map['studios']['edges'];
      for (final company in companies)
        if (company['isMain'])
          studios[company['node']['name']] = company['node']['id'];
        else
          producers[company['node']['name']] = company['node']['id'];
    }

    return MediaOverview._(
      id: map['id'],
      browsable: map['type'] == 'ANIME' ? Browsable.anime : Browsable.manga,
      isFavourite: map['isFavourite'],
      favourites: map['favourites'],
      preferredTitle: map['title']['userPreferred'],
      romajiTitle: map['title']['romaji'],
      englishTitle: map['title']['english'],
      nativeTitle: map['title']['native'],
      synonyms: List<String>.from(map['synonyms']),
      cover: map['coverImage']['extraLarge'] ?? map['coverImage']['large'],
      banner: map['bannerImage'],
      description: map['description'] != null
          ? map['description'].replaceAll(RegExp(r'<[^>]*>'), '')
          : null,
      format: clarifyEnum(map['format']),
      status: clarifyEnum(map['status']),
      entryStatus: map['mediaListEntry'] != null
          ? stringToEnum(
              map['mediaListEntry']['status'].toString(),
              ListStatus.values,
            )
          : null,
      nextEpisode: map['nextAiringEpisode'] != null
          ? map['nextAiringEpisode']['episode']
          : null,
      timeUntilAiring: map['nextAiringEpisode'] != null
          ? secondsToTime(map['nextAiringEpisode']['timeUntilAiring'])
          : null,
      episodes: map['episodes'],
      duration: duration,
      chapters: map['chapters'],
      volumes: map['volumes'],
      startDate:
          map['startDate'] != null ? mapToDateString(map['startDate']) : null,
      endDate: map['endDate'] != null ? mapToDateString(map['endDate']) : null,
      season: season,
      averageScore:
          map['averageScore'] != null ? '${map["averageScore"]}%' : null,
      meanScore: map['meanScore'] != null ? '${map["meanScore"]}%' : null,
      popularity: map['popularity'],
      genres: List<String>.from(map['genres']),
      studios: studios,
      producers: producers,
      source: clarifyEnum(map['source']),
      hashtag: map['hashtag'],
      countryOfOrigin: map['countryOfOrigin'],
    );
  }
}
