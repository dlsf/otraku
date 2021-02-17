import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:otraku/helpers/graph_ql.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/helpers/fn_helper.dart';
import 'package:otraku/enums/media_sort.dart';
import 'package:otraku/models/anilist/person_model.dart';
import 'package:otraku/models/studio_connection_list.dart';
import 'package:otraku/models/browse_result_model.dart';

class Studio extends GetxController {
  // ***************************************************************************
  // CONSTANTS
  // ***************************************************************************

  static const _studioQuery = r'''
    query Studio($id: Int, $page: Int = 1, $sort: [MediaSort], $isMain: Boolean, $onList: Boolean, $withStudio: Boolean = false) {
      Studio(id: $id) {
        ...studio @include(if: $withStudio)
        media(page: $page, sort: $sort, isMain: $isMain, onList: $onList) {
          pageInfo {hasNextPage}
          nodes {
            id
            title {userPreferred}
            coverImage {large}
            startDate {year}
            status(version: 2)
          }
        }
      }
    }
    fragment studio on Studio {
      id
      name
      favourites
      isFavourite
    }
  ''';

  static const _toggleFavouriteMutation = r'''
    mutation ToggleFavouriteStudio($id: Int) {
      ToggleFavourite(studioId: $id) {
        studios(page: 1, perPage: 1) {pageInfo {currentPage}}
      }
    }
  ''';

  // ***************************************************************************
  // DATA
  // ***************************************************************************

  final int _id;
  Studio(this._id);

  final _company = Rx<PersonModel>();
  final _media = Rx<StudioConnectionList>();
  MediaSort _sort = MediaSort.START_DATE_DESC;

  PersonModel get company => _company();

  StudioConnectionList get media => _media();

  MediaSort get sort => _sort;

  set sort(MediaSort value) {
    _sort = value;
    refetch();
  }

  // ***************************************************************************
  // FETCHING
  // ***************************************************************************

  Future<void> fetch() async {
    if (_company.value != null) return;

    final body = await GraphQL.request(
      _studioQuery,
      {'id': _id, 'withStudio': true, 'sort': describeEnum(_sort)},
    );
    if (body == null) return;

    final data = body['Studio'];

    _company(PersonModel.studio(data));

    _initLists(data['media']);
  }

  Future<void> refetch() async {
    final body = await GraphQL.request(
      _studioQuery,
      {'id': _id, 'sort': describeEnum(_sort)},
    );

    if (body == null) return;

    _initLists(body['Studio']['media']);
  }

  Future<void> fetchPage() async {
    final body = await GraphQL.request(
      _studioQuery,
      {
        'id': _id,
        'page': _media().nextPage,
        'sort': describeEnum(_sort),
      },
    );

    if (body == null) return;

    final data = body['Studio']['media'];

    List<String> categories = [];
    List<List<BrowseResultModel>> results = [];
    for (final node in data['nodes']) {
      final String category =
          (node['startDate']['year'] ?? FnHelper.clarifyEnum(node['status']))
              .toString();

      if (categories.isEmpty || categories.last != category) {
        categories.add(category);
        results.add([]);
      }

      results.last.add(BrowseResultModel(
        id: node['id'],
        text1: node['title']['userPreferred'],
        imageUrl: node['coverImage']['large'],
        browsable: Browsable.anime,
      ));
    }

    _media.update((m) => m.append(
          categories,
          results,
          data['pageInfo']['hasNextPage'],
        ));
  }

  Future<bool> toggleFavourite() async =>
      await GraphQL.request(
        _toggleFavouriteMutation,
        {'id': _id},
        popOnErr: false,
      ) !=
      null;

  // ***************************************************************************
  // HELPER FUNCTIONS
  // ***************************************************************************

  void _initLists(Map<String, dynamic> data) {
    final List<dynamic> nodes = data['nodes'];
    if (nodes.isEmpty) {
      _media(StudioConnectionList([], [], false));
      return;
    }

    List<String> categories = [];
    List<List<BrowseResultModel>> results = [];
    for (final node in nodes) {
      final String category =
          (node['startDate']['year'] ?? FnHelper.clarifyEnum(node['status']))
              .toString();

      if (categories.isEmpty || categories.last != category) {
        categories.add(category);
        results.add([]);
      }

      results.last.add(BrowseResultModel(
        id: node['id'],
        text1: node['title']['userPreferred'],
        imageUrl: node['coverImage']['large'],
        browsable: Browsable.anime,
      ));
    }

    _media(StudioConnectionList(
      categories,
      results,
      data['pageInfo']['hasNextPage'],
    ));
  }

  @override
  void onInit() {
    super.onInit();
    fetch();
  }
}
