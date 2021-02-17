import 'package:get/get.dart';
import 'package:otraku/controllers/collection.dart';
import 'package:otraku/controllers/explorer.dart';
import 'package:otraku/controllers/viewer.dart';
import 'package:otraku/models/anilist/settings_model.dart';
import 'package:otraku/helpers/filterable.dart';

class Settings extends GetxController {
  final Map<String, dynamic> _changes = {};
  SettingsModel _data;
  int _pageIndex = 0;

  Map<String, dynamic> get changes => _changes;

  SettingsModel get data => _data;

  int get pageIndex => _pageIndex;

  set pageIndex(int val) {
    _pageIndex = val;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    _data = Get.find<Viewer>().settings;
  }

  @override
  void onClose() async {
    if (changes.length > 0) {
      final ok = await Get.find<Viewer>().updateSettings(changes);
      if (ok) {
        if (changes.containsKey('displayAdultContent')) {
          if (changes['displayAdultContent']) {
            Get.find<Explorer>().setFilterWithKey(Filterable.IS_ADULT);
          } else {
            Get.find<Explorer>()
                .setFilterWithKey(Filterable.IS_ADULT, value: false);
          }
        }

        if (changes.containsKey('scoreFormat') ||
            changes.containsKey('titleLanguage')) {
          Get.find<Collection>(tag: Collection.ANIME).fetch();
          Get.find<Collection>(tag: Collection.MANGA).fetch();
          return;
        }

        if (changes.containsKey('splitCompletedAnime')) {
          Get.find<Collection>(tag: Collection.ANIME).fetch();
        }

        if (changes.containsKey('splitCompletedManga')) {
          Get.find<Collection>(tag: Collection.MANGA).fetch();
        }
      }
    }
    super.onClose();
  }
}
