import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/loaders.dart/sliver_refresh_control.dart';
import 'package:otraku/widgets/overlays/drag_sheets.dart';
import 'package:otraku/widgets/layouts/media_list.dart';
import 'package:otraku/widgets/navigation/action_button.dart';
import 'package:otraku/widgets/navigation/sliver_filterable_app_bar.dart';
import 'package:otraku/widgets/layouts/nav_layout.dart';

import '../utils/client.dart';

class CollectionView extends StatelessWidget {
  final int id;
  final bool ofAnime;
  final String ctrlTag;

  CollectionView({
    required this.id,
    required this.ofAnime,
    required this.ctrlTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: CollectionActionButton(ctrlTag),
      body: SafeArea(
        child: HomeCollectionView(
          id: id,
          ofAnime: ofAnime,
          collectionTag: ctrlTag,
          key: null,
        ),
      ),
    );
  }
}

class HomeCollectionView extends StatelessWidget {
  final int id;
  final bool ofAnime;
  final String collectionTag;

  HomeCollectionView({
    required this.id,
    required this.ofAnime,
    required this.collectionTag,
    required key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CollectionController>(tag: collectionTag);
    return CustomScrollView(
      physics: Config.PHYSICS,
      controller: ctrl.scrollCtrl,
      slivers: [
        SliverCollectionAppBar(collectionTag, id != Client.viewerId),
        SliverRefreshControl(
          onRefresh: ctrl.refetch,
          canRefresh: () => !ctrl.isLoading,
        ),
        MediaList(collectionTag),
        SliverToBoxAdapter(child: SizedBox(height: NavLayout.offset(context))),
      ],
    );
  }
}

class CollectionActionButton extends StatelessWidget {
  final String ctrlTag;
  const CollectionActionButton(this.ctrlTag, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingListener(
      scrollCtrl: Get.find<CollectionController>(tag: ctrlTag).scrollCtrl,
      child: ActionButton(
        tooltip: 'Lists',
        icon: Ionicons.menu_outline,
        onTap: () => DragSheet.show(
          context,
          CollectionDragSheet(context, ctrlTag),
        ),
      ),
    );
  }
}
