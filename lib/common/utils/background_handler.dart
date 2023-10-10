import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:otraku/modules/notification/notification_model.dart';
import 'package:otraku/common/utils/api.dart';
import 'package:otraku/common/utils/graphql.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/common/utils/route_arg.dart';
import 'package:otraku/common/widgets/overlays/dialogs.dart';
import 'package:workmanager/workmanager.dart';

final _notificationPlugin = FlutterLocalNotificationsPlugin();

class BackgroundHandler {
  BackgroundHandler._();

  static bool _didInit = false;
  static bool _didCheckLaunch = false;

  static Future<void> init() async {
    if (_didInit) return;
    _didInit = true;

    _notificationPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('notification_icon'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: _handleNotification,
    );

    await Workmanager().initialize(_fetch);

    if (Platform.isAndroid) {
      Workmanager().registerPeriodicTask(
        '0',
        'notifications',
        constraints: Constraints(networkType: NetworkType.connected),
      );
    }
  }

  /// Check if the app has permission to send notifications.
  static Future<bool> checkPermission() async {
    final android = _notificationPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return true;

    return await android.areNotificationsEnabled() ?? true;
  }

  /// Request permission to send notifications.
  static Future<bool> requestPermission() async {
    final android = _notificationPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return true;

    return await android.requestNotificationsPermission() ?? true;
  }

  /// Should be called, for example, when the user logs out of an account.
  static void clearNotifications() => _notificationPlugin.cancelAll();

  /// If the app was launched by a notification, handle it.
  static void handleNotificationLaunch() {
    if (_didCheckLaunch) return;
    _didCheckLaunch = true;

    _notificationPlugin.getNotificationAppLaunchDetails().then(
      (launchDetails) {
        if (launchDetails?.notificationResponse != null) {
          _handleNotification(launchDetails!.notificationResponse!);
        }
      },
    );
  }

  /// Pushes a different page, depeding on the notification that was pressed.
  static void _handleNotification(NotificationResponse response) {
    if (response.payload == null) return;

    final uri = Uri.parse(response.payload!);
    if (uri.pathSegments.length < 2) return;

    final id = int.tryParse(uri.pathSegments[1]) ?? -1;
    if (id < 0) return;

    final context = RouteArg.navKey.currentContext;
    if (context == null) return;

    if (uri.pathSegments[0] == RouteArg.thread) {
      showPopUp(
        context,
        const ConfirmationDialog(title: 'Sorry! Forum is not yet supported!'),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/${uri.pathSegments[0]}',
      arguments: RouteArg(id: id),
    );
  }
}

@pragma('vm:entry-point')
void _fetch() => Workmanager().executeTask((_, __) async {
      // Initialise local settings.
      await Options.init();
      if (Options().account == null) return true;
      Options().lastBackgroundWork = DateTime.now();

      // Log in.
      if (!Api.loggedIn()) {
        final ok = await Api.logIn(Options().account!);
        if (!ok) return true;
      }

      // Get new notifications.
      Map<String, dynamic> data;
      try {
        data = await Api.get(GqlQuery.notifications, const {'withCount': true});
      } catch (_) {
        return true;
      }

      int count = data['Viewer']?['unreadNotificationCount'] ?? 0;
      final ns = data['Page']?['notifications'] ?? [];
      if (count > ns.length) count = ns.length;
      if (count == 0) return true;

      final last = Options().lastNotificationId;
      Options().lastNotificationId = ns[0]?['id'] ?? -1;

      // Show notifications.
      for (int i = 0; i < count && ns[i]?['id'] != last; i++) {
        final notification = SiteNotification.maybe(ns[i]);
        if (notification == null) continue;

        (switch (notification.type) {
          NotificationType.FOLLOWING => _show(
              notification,
              'New Follow',
              '${RouteArg.user}/${notification.bodyId}',
            ),
          NotificationType.ACTIVITY_MESSAGE => _show(
              notification,
              'New Message',
              '${RouteArg.activity}/${notification.bodyId}',
            ),
          NotificationType.ACTIVITY_REPLY => _show(
              notification,
              'New Reply',
              '${RouteArg.activity}/${notification.bodyId}',
            ),
          NotificationType.ACTIVITY_REPLY_SUBSCRIBED => _show(
              notification,
              'New Reply To Subscribed Activity',
              '${RouteArg.activity}/${notification.bodyId}',
            ),
          NotificationType.ACTIVITY_MENTION => _show(
              notification,
              'New Mention',
              '${RouteArg.activity}/${notification.bodyId}',
            ),
          NotificationType.ACTIVITY_LIKE => _show(
              notification,
              'New Activity Like',
              '${RouteArg.activity}/${notification.bodyId}',
            ),
          NotificationType.ACTIVITY_REPLY_LIKE => _show(
              notification,
              'New Reply Like',
              '${RouteArg.activity}/${notification.bodyId}',
            ),
          NotificationType.THREAD_COMMENT_REPLY => _show(
              notification,
              'New Forum Reply',
              '${RouteArg.thread}/${notification.bodyId}',
            ),
          NotificationType.THREAD_COMMENT_MENTION => _show(
              notification,
              'New Forum Mention',
              '${RouteArg.thread}/${notification.bodyId}',
            ),
          NotificationType.THREAD_SUBSCRIBED => _show(
              notification,
              'New Forum Comment',
              '${RouteArg.thread}/${notification.bodyId}',
            ),
          NotificationType.THREAD_LIKE => _show(
              notification,
              'New Forum Like',
              '${RouteArg.thread}/${notification.bodyId}',
            ),
          NotificationType.THREAD_COMMENT_LIKE => _show(
              notification,
              'New Forum Comment Like',
              '${RouteArg.thread}/${notification.bodyId}',
            ),
          NotificationType.AIRING => _show(
              notification,
              'New Episode',
              '${RouteArg.media}/${notification.bodyId}',
            ),
          NotificationType.RELATED_MEDIA_ADDITION => _show(
              notification,
              'New Addition',
              '${RouteArg.media}/${notification.bodyId}',
            ),
          NotificationType.MEDIA_DATA_CHANGE => _show(
              notification,
              'Modified Media',
              '${RouteArg.media}/${notification.bodyId}',
            ),
          NotificationType.MEDIA_MERGE => _show(
              notification,
              'Merged Media',
              '${RouteArg.media}/${notification.bodyId}',
            ),
          NotificationType.MEDIA_DELETION =>
            _show(notification, 'Deleted Media', ''),
        });
      }

      return true;
    });

() _show(SiteNotification notification, String title, String payload) {
  _notificationPlugin.show(
    notification.id,
    title,
    notification.texts.join(),
    NotificationDetails(
      android: AndroidNotificationDetails(
        notification.type.name,
        notification.type.text,
        channelDescription: notification.type.text,
      ),
    ),
    payload: payload,
  );
  return ();
}
