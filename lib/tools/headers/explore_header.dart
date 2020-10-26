import 'dart:ui';

import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/enums/theme_enum.dart';
import 'package:otraku/pages/pushable/filter_page.dart';
import 'package:otraku/providers/explorable.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/headers/header_search_bar.dart';
import 'package:otraku/tools/title_segmented_control.dart';
import 'package:otraku/tools/overlays/explore_sort_sheet.dart';
import 'package:provider/provider.dart';

class ExploreHeader extends StatelessWidget {
  final ScrollController scrollCtrl;

  const ExploreHeader(this.scrollCtrl);

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _ExploreHeaderDelegate(context, scrollCtrl),
    );
  }
}

class _ExploreHeaderDelegate implements SliverPersistentHeaderDelegate {
  static const _height = 95.0;

  ScrollController _scrollCtrl;

  _ExploreHeaderDelegate(
      BuildContext context, ScrollController scrollController) {
    _scrollCtrl = scrollController;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final provider = Provider.of<Explorable>(context, listen: false);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: _height,
          color: Theme.of(context).cardColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TitleSegmentedControl(
                initialValue:
                    Provider.of<Explorable>(context, listen: false).type,
                pairs: Map.fromIterable(
                  Browsable.values,
                  key: (v) => clarifyEnum(describeEnum(v)),
                  value: (v) => v,
                ),
                onNewValue: (value) {
                  Provider.of<Explorable>(context, listen: false).type = value;
                  if (_scrollCtrl.offset > 100) _scrollCtrl.jumpTo(100);
                  _scrollCtrl.animateTo(0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.decelerate);
                },
                onSameValue: (_) {
                  if (_scrollCtrl.offset > 100) _scrollCtrl.jumpTo(100);
                  _scrollCtrl.animateTo(0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.decelerate);
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SizedBox(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ExploreSearchBar(
                        provider.getFilterWithKey(Explorable.SEARCH),
                        (value) => provider.setFilterWithKey(
                          Explorable.SEARCH,
                          value: value,
                          notify: true,
                          refetch: true,
                        ),
                      ),
                      Flexible(child: _FilterButton()),
                      Flexible(
                        child: IconButton(
                          icon: const Icon(
                            FluentSystemIcons.ic_fluent_arrow_sort_filled,
                          ),
                          onPressed: () => showModalBottomSheet(
                            context: context,
                            builder: (ctx) => ExploreSortSheet(),
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => _height;

  @override
  double get minExtent => _height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;

  @override
  FloatingHeaderSnapConfiguration get snapConfiguration => null;

  @override
  OverScrollHeaderStretchConfiguration get stretchConfiguration => null;

  @override
  PersistentHeaderShowOnScreenConfiguration get showOnScreenConfiguration =>
      null;

  @override
  TickerProvider get vsync => null;
}

class _FilterButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<Explorable>(context, listen: false);

    return Provider.of<Explorable>(context).anyActiveFilterFrom([
      Explorable.STATUS_IN,
      Explorable.STATUS_NOT_IN,
      Explorable.FORMAT_IN,
      Explorable.FORMAT_NOT_IN,
      Explorable.GENRE_IN,
      Explorable.GENRE_NOT_IN,
      Explorable.TAG_IN,
      Explorable.TAG_NOT_IN,
    ])
        ? GestureDetector(
            onTap: () => Navigator.of(context).push(
              CupertinoPageRoute(builder: (_) => FilterPage()),
            ),
            onLongPress: () {
              provider.setFilterWithKey(Explorable.STATUS_IN, value: null);
              provider.setFilterWithKey(Explorable.STATUS_NOT_IN, value: null);
              provider.setFilterWithKey(Explorable.FORMAT_IN, value: null);
              provider.setFilterWithKey(Explorable.FORMAT_IN, value: null);
              provider.setFilterWithKey(Explorable.GENRE_IN, value: null);
              provider.setFilterWithKey(Explorable.GENRE_NOT_IN, value: null);
              provider.setFilterWithKey(Explorable.TAG_IN, value: null);
              provider.setFilterWithKey(Explorable.TAG_NOT_IN,
                  value: null, notify: true, refetch: true);
            },
            child: Container(
              width: ViewConfig.MATERIAL_TAP_TARGET_SIZE,
              height: ViewConfig.CONTROL_HEADER_ICON_HEIGHT,
              decoration: BoxDecoration(
                borderRadius: ViewConfig.BORDER_RADIUS,
                color: Theme.of(context).accentColor,
              ),
              child: const Icon(
                FluentSystemIcons.ic_fluent_filter_filled,
                size: Styles.ICON_SMALL,
                color: Colors.white,
              ),
            ),
          )
        : IconButton(
            icon: const Icon(FluentSystemIcons.ic_fluent_filter_filled),
            onPressed: () => Navigator.of(context).push(
              CupertinoPageRoute(builder: (_) => FilterPage()),
            ),
          );
  }
}
