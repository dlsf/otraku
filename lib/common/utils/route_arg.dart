import 'package:flutter/material.dart';
import 'package:otraku/modules/activity/activities_view.dart';
import 'package:otraku/modules/activity/activity_view.dart';
import 'package:otraku/modules/calendar/calendar_view.dart';
import 'package:otraku/modules/collection/collection_view.dart';
import 'package:otraku/modules/favorites/favorites_view.dart';
import 'package:otraku/modules/studio/studio_view.dart';
import 'package:otraku/modules/auth/auth_view.dart';
import 'package:otraku/modules/character/character_view.dart';
import 'package:otraku/modules/social/social_view.dart';
import 'package:otraku/modules/home/home_view.dart';
import 'package:otraku/modules/media/media_view.dart';
import 'package:otraku/modules/notification/notifications_view.dart';
import 'package:otraku/modules/review/review_view.dart';
import 'package:otraku/modules/settings/settings_view.dart';
import 'package:otraku/modules/staff/staff_view.dart';
import 'package:otraku/modules/statistics/statistics_view.dart';
import 'package:otraku/modules/review/reviews_view.dart';
import 'package:otraku/modules/user/user_view.dart';

/// A routing helper. When passing arguments to named routes, they should always
/// be an instance of [RouteArg] or `null`.
class RouteArg {
  const RouteArg({this.id, this.info, this.variant, this.callback});

  final int? id;
  final String? info;
  final bool? variant;
  final void Function(dynamic)? callback;

  /// Used to provide context when it's unavailable
  /// through [RouteArg.navKey.currentContext].
  static final navKey = GlobalKey<NavigatorState>();

  /// Used by [MaterialApp.onGenerateRoute].
  static Route<dynamic> generateRoute(RouteSettings route) {
    if (route.arguments is! RouteArg?) return _unknown;

    final arg = route.arguments as RouteArg?;
    switch (route.name) {
      case '/':
      case auth:
        return MaterialPageRoute(builder: (_) => const AuthView());
      case home:
        if (arg?.id == null) return _unknown;
        return MaterialPageRoute(builder: (_) => HomeView(arg!.id!));
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsView());
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsView());
      case collection:
        if (arg?.id == null || arg?.variant == null) return _unknown;
        return MaterialPageRoute(
          builder: (_) => CollectionView(arg!.id!, arg.variant!),
        );
      case calendar:
        return MaterialPageRoute(builder: (_) => const CalendarView());
      case media:
        if (arg?.id == null) return _unknown;
        return MaterialPageRoute(
          builder: (_) => MediaView(arg!.id!, arg.info),
        );
      case character:
        if (arg?.id == null) return _unknown;
        return MaterialPageRoute(
          builder: (_) => CharacterView(arg!.id!, arg.info),
        );
      case staff:
        if (arg?.id == null) return _unknown;
        return MaterialPageRoute(builder: (_) => StaffView(arg!.id!, arg.info));
      case studio:
        if (arg?.id == null) return _unknown;
        return MaterialPageRoute(
          builder: (_) => StudioView(arg!.id!, arg.info),
        );
      case review:
        if (arg?.id == null) return _unknown;
        return MaterialPageRoute(
          builder: (_) => ReviewView(arg!.id!, arg.info),
        );
      case user:
        if (arg?.id == null) return _unknown;
        return MaterialPageRoute(builder: (_) => UserView(arg!.id!, arg.info));
      case activities:
        if (arg?.id == null) return _unknown;
        return MaterialPageRoute(builder: (_) => ActivitiesView(arg!.id!));
      case favourites:
        if (arg?.id == null) return _unknown;
        return MaterialPageRoute(builder: (_) => FavoritesView(arg!.id!));
      case friends:
        if (arg?.id == null) return _unknown;
        return MaterialPageRoute(builder: (_) => SocialView(arg!.id!));
      case statistics:
        if (arg?.id == null) return _unknown;
        return MaterialPageRoute(builder: (_) => StatisticsView(arg!.id!));
      case reviews:
        if (arg?.id == null) return _unknown;
        return MaterialPageRoute(builder: (_) => ReviewsView(arg!.id!));
      case activity:
        if (arg?.id == null) return _unknown;
        return MaterialPageRoute(
          builder: (_) => ActivityView(arg!.id!, arg.callback),
        );
      default:
        return _unknown;
    }
  }

  // Available routes.
  static const auth = '/auth';
  static const home = '/home';
  static const settings = '/settings';
  static const notifications = '/notifications';
  static const collection = '/collection';
  static const calendar = '/calendar';
  static const media = '/media';
  static const character = '/character';
  static const staff = '/staff';
  static const studio = '/studio';
  static const review = '/review';
  static const user = '/user';
  static const activities = '/activities';
  static const favourites = '/favourites';
  static const friends = '/friends';
  static const statistics = '/statistics';
  static const reviews = '/reviews';
  static const activity = '/activity';
  static const thread = '/thread';

  // A placeholder for unknown routes.
  static final _unknown = MaterialPageRoute(
    builder: (context) => Scaffold(
      body: Center(
        child: Text('404', style: Theme.of(context).textTheme.titleLarge),
      ),
    ),
  );
}
