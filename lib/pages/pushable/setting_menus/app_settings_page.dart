import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/enums/theme_enum.dart';
import 'package:otraku/controllers/app_config.dart';
import 'package:otraku/tools/fields/input_field_structure.dart';
import 'package:otraku/tools/headers/custom_app_bar.dart';

class AppSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final box = GetStorage();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'App',
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        children: [
          _RadioGrid(
            title: 'Startup Page',
            initialValue: box.read(AppConfig.STARTUP_PAGE),
            options: [
              'Inbox',
              'Anime List',
              'Manga List',
              'Explore',
              'Profile',
            ],
            onChanged: (val) => box.write(AppConfig.STARTUP_PAGE, val),
          ),
          _RadioGrid(
            title: 'Theme',
            initialValue: box.read(AppConfig.THEME),
            options: Themes.values
                .map((t) => clarifyEnum(describeEnum(Themes.values[t.index])))
                .toList(),
            onChanged: (val) {
              Get.changeTheme(Themes.values[val].themeData);
              box.write(AppConfig.THEME, val);
            },
          ),
        ],
      ),
    );
  }
}

class _RadioGrid extends StatefulWidget {
  final String title;
  final int initialValue;
  final List<String> options;
  final Function(int) onChanged;

  _RadioGrid({
    @required this.title,
    @required this.initialValue,
    @required this.options,
    @required this.onChanged,
  });

  @override
  __RadioGridState createState() => __RadioGridState();
}

class __RadioGridState extends State<_RadioGrid> {
  int current;

  @override
  Widget build(BuildContext context) {
    return InputFieldStructure(
      enforceHeight: false,
      title: widget.title,
      body: GridView.count(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 15),
        crossAxisCount: 2,
        childAspectRatio: 5,
        shrinkWrap: true,
        children: [
          for (int i = 0; i < widget.options.length; i++) ...[
            RadioListTile(
              value: i,
              groupValue: current,
              onChanged: (val) {
                setState(() => current = val);
                widget.onChanged(val);
              },
              title: Text(
                widget.options[i],
                style: Theme.of(context).textTheme.bodyText1,
              ),
              activeColor: Theme.of(context).accentColor,
              dense: true,
            ),
          ],
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    current = widget.initialValue ?? 0;
  }
}
