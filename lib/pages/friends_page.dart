import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/friends.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/layouts/tile_grid.dart';
import 'package:otraku/widgets/navigation/custom_app_bar.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';

class FriendsPage extends StatelessWidget {
  static const ROUTE = '/friends';

  final int id;
  FriendsPage(this.id);

  @override
  Widget build(BuildContext context) => GetBuilder<Friends>(
        tag: id.toString(),
        builder: (friends) => Scaffold(
          extendBody: true,
          appBar: CustomAppBar(
            title: friends.onFollowing ? 'Following' : 'Followers',
          ),
          bottomNavigationBar: NavBar(
            options: {
              'Following': Ionicons.people_circle,
              'Followers': Ionicons.person_circle,
            },
            onChanged: (page) => friends.onFollowing = page == 0 ? true : false,
            initial: friends.onFollowing ? 0 : 1,
          ),
          body: Padding(
            padding: EdgeInsets.only(bottom: NavBar.offset(context)),
            child: AnimatedSwitcher(
              duration: Config.TAB_SWITCH_DURATION,
              child: Center(
                key: friends.key,
                child: friends.users.isNotEmpty
                    ? TileGrid(
                        tileData: friends.users,
                        tileModel: Config.squareTile,
                        scrollCtrl: friends.scrollCtrl,
                      )
                    : Text(
                        'No Users',
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
              ),
            ),
          ),
        ),
      );
}
