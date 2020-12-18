abstract class Filterable {
  static const STATUS_IN = 'status_in';
  static const STATUS_NOT_IN = 'status_not_in';
  static const FORMAT_IN = 'format_in';
  static const FORMAT_NOT_IN = 'format_not_in';
  static const ID_NOT_IN = 'id_not_in';
  static const GENRE_IN = 'genre_in';
  static const GENRE_NOT_IN = 'genre_not_in';
  static const TAG_IN = 'tag_in';
  static const TAG_NOT_IN = 'tag_not_in';
  static const ON_LIST = 'onList';
  static const IS_ADULT = 'isAdult';
  static const SEARCH = 'search';
  static const TYPE = 'type';
  static const SORT = 'sort';
  static const PAGE = 'page';

  dynamic getFilterWithKey(String key);

  void setFilterWithKey(String key, {dynamic value, bool update = false});

  void clearAllFilters({bool update = true});

  void clearFiltersWithKeys(List<String> keys, {bool update = true});

  bool anyActiveFilterFrom(List<String> keys);
}