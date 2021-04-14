import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/collection.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/enums/score_format.dart';
import 'package:otraku/enums/themes.dart';
import 'package:otraku/models/list_entry_model.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/loader.dart';
import 'package:otraku/widgets/browse_indexer.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';

class MediaList extends StatelessWidget {
  final String? collectionTag;

  MediaList(this.collectionTag);

  @override
  Widget build(BuildContext context) {
    final collection = Get.find<Collection>(tag: collectionTag);
    final sidePadding = MediaQuery.of(context).size.width > 620
        ? (MediaQuery.of(context).size.width - 600) / 2.0
        : 10.0;

    return Obx(() {
      if (collection.isFullyEmpty) {
        if (collection.isLoading)
          return const SliverFillRemaining(child: Center(child: Loader()));

        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'No ${collection.ofAnime ? 'Anime' : 'Manga'}',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ],
            ),
          ),
        );
      }

      if (collection.isEmpty)
        return SliverFillRemaining(
          child: Center(
            child: Text(
              'No ${collection.ofAnime ? 'Anime' : 'Manga'} Results',
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
        );

      final entries = collection.entries;
      final scoreFormat = collection.scoreFormat;

      return SliverPadding(
        padding: EdgeInsets.only(
          left: sidePadding,
          right: sidePadding,
          top: 15,
        ),
        sliver: SliverFixedExtentList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => _MediaListTile(entries[i], scoreFormat!),
            childCount: entries.length,
          ),
          itemExtent: 150,
        ),
      );
    });
  }
}

class _MediaListTile extends StatelessWidget {
  final ListEntryModel entry;
  final ScoreFormat scoreFormat;

  _MediaListTile(this.entry, this.scoreFormat);

  @override
  Widget build(BuildContext context) {
    final details = <String>[Convert.clarifyEnum(entry.format).toString()];
    if (entry.timeUntilAiring != null)
      details.add(' • Ep ${entry.nextEpisode} in ${entry.timeUntilAiring}');
    if (entry.nextEpisode != null && entry.nextEpisode! - 1 > entry.progress)
      details.add(' • ${entry.nextEpisode! - 1 - entry.progress} ep behind');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: Config.BORDER_RADIUS,
      ),
      child: BrowseIndexer(
        id: entry.mediaId!,
        browsable: Browsable.anime,
        imageUrl: entry.cover,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: entry.mediaId!,
              child: ClipRRect(
                child: Container(
                  width: 95,
                  color: Theme.of(context).primaryColor,
                  child: FadeImage(entry.cover),
                ),
                borderRadius: Config.BORDER_RADIUS,
              ),
            ),
            Expanded(
              child: Padding(
                padding: Config.PADDING,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Flexible(
                            child: Text(
                              entry.title!,
                              style: Theme.of(context).textTheme.bodyText1,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            details.join(),
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 5,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      decoration: entry.progressMax != null
                          ? BoxDecoration(
                              borderRadius: Config.BORDER_RADIUS,
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).disabledColor,
                                  Theme.of(context).disabledColor,
                                  Theme.of(context).backgroundColor,
                                  Theme.of(context).backgroundColor,
                                ],
                                stops: [
                                  0.0,
                                  entry.progress.toDouble() /
                                      entry.progressMax!,
                                  entry.progress.toDouble() /
                                      entry.progressMax!,
                                  1.0,
                                ],
                              ),
                            )
                          : BoxDecoration(
                              color: Theme.of(context).disabledColor,
                              borderRadius: Config.BORDER_RADIUS,
                            ),
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Center(
                            child: Tooltip(
                              message: 'Progress',
                              child: Text(
                                entry.progress != entry.progressMax
                                    ? '${entry.progress} / ${entry.progressMax ?? '?'}'
                                    : entry.progress.toString(),
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Center(
                            child: scoreFormat.getWidget(context, entry.score),
                          ),
                        ),
                        Flexible(
                          child: Center(
                            child: entry.repeat > 0
                                ? Tooltip(
                                    message: 'Repeats',
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          FluentIcons
                                              .arrow_repeat_all_20_filled,
                                          size: Style.ICON_SMALL,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          entry.repeat.toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1,
                                        ),
                                      ],
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        Flexible(
                          child: Center(
                            child: entry.notes != null
                                ? SizedBox(
                                    height: 20,
                                    child: IconButton(
                                      tooltip: 'Comment',
                                      padding: const EdgeInsets.all(0),
                                      icon: const Icon(
                                        Icons.comment,
                                        size: Style.ICON_SMALL,
                                      ),
                                      onPressed: () => showPopUp(
                                        context,
                                        TextDialog(
                                          title: 'Comment',
                                          text: entry.notes!,
                                        ),
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}