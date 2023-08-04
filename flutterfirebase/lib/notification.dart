import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutterfirebase/main.dart';

class NotificationClass extends StatefulWidget {
  final int tot_notication;
  NotificationClass({required this.tot_notication});

  @override
  State<NotificationClass> createState() =>
      _NotificationClassState(this.tot_notication);
}

class _NotificationClassState extends State<NotificationClass> {
  int tot_notication;
  _NotificationClassState(this.tot_notication);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification'),
      ),
      body: Container(
        child: Center(
          child: Text('${tot_notication}'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showNotification();
        },
        child: Icon(Icons.notifications_active_outlined),
      ),
    );
  }

  void showNotification() {
    setState(() {
      tot_notication++;
    });
    flutterLocalNotificationsPlugin.show(
        0,
        "Testing $tot_notication",
        "How you doin ?",
        NotificationDetails(
            android: AndroidNotificationDetails(channel.id, channel.name,
                channelDescription: channel.description,
                importance: Importance.high,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher')));
  }
}
