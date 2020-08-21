import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

class SingleMedia with ChangeNotifier {
  static const String _url = 'https://graphql.anilist.co';

  Map<String, String> _headers;

  SingleMedia(accessToken) {
    _headers = {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
      'Content-type': 'application/json',
    };
  }

  Future<Map<String, dynamic>> fetchData(int id) async {
    const query = r'''
      query Main($id: Int) {
        Media(id: $id) {
          type
          title {
            english
            romaji
          }
          nextAiringEpisode {
            airingAt
          }
          coverImage {
            extraLarge
            large
          }
          bannerImage
          isFavourite
          popularity
          favourites
          nextAiringEpisode {
            episode
            timeUntilAiring
          }
          mediaListEntry {
            status
          }
          description
          format
          status
          episodes
          duration
          chapters
          volumes
          season
          seasonYear
          countryOfOrigin
          startDate {
            year
            month
            day
          }
          endDate {
            year
            month
            day
          }
          averageScore
          meanScore
          studios {
            edges {
              node {
                name
              }
              isMain
            }
          }
        }
      }
    ''';

    final Map<String, int> variables = {
      'id': id,
    };

    final request = json.encode({
      'query': query,
      'variables': variables,
    });

    final response = await post(_url, body: request, headers: _headers);

    return (json.decode(response.body) as Map<String, dynamic>)['data']['Media']
        as Map<String, dynamic>;
  }

  Future<bool> toggleFavourite(int id, String entryType) async {
    final String type = entryType == 'ANIME' ? 'anime' : 'manga';

    final query = '''
      mutation(\$id: Int) {
        ToggleFavourite(${type}Id: \$id) {
          $type(page: 1, perPage: 1) {
            pageInfo {
              currentPage
            }
          }
        }
      }
    ''';

    final Map<String, Object> variables = {
      'id': id,
    };

    final request = json.encode({
      'query': query,
      'variables': variables,
    });

    final result = await post(_url, body: request, headers: _headers);
    return !(json.decode(result.body) as Map<String, dynamic>)
        .containsKey('errors');
  }
}