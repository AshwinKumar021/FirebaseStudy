import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutterfirebase/flutter.dart';
import 'package:flutterfirebase/notification.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('A bg message just showed up :  ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.

        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Stream<QuerySnapshot> collectionReference =
      Firebaseentry.readEmployee();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher',
              ),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title!),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(notification.body!)],
                  ),
                ),
              );
            });
      }
    });
  }

  int _counter = 0;
  List<entry> addeditem = [];

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NotificationClass(
                              tot_notication: _counter,
                            )));
              },
              icon: Icon(Icons.share)),
          IconButton(
              onPressed: () {
                print(addeditem.length.toString() + 'length of item array');
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Container(
                        height: 400,
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: addeditem.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(addeditem[index].name ?? ''),
                                subtitle: Text(addeditem[index].rate ?? ''),
                              );
                            }),
                      );
                    });
              },
              icon: Icon(Icons.receipt))
        ],
      ),
      body: StreamBuilder(
        stream: collectionReference,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          var userSnapshot = snapshot.data?.docs;
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: userSnapshot?.length,
                itemBuilder: (context, snapshot) {
                  return Card(
                    color: userSnapshot![snapshot]['status'] == '0'
                        ? Colors.yellow
                        : Colors.red,
                    child: ListTile(
                      onTap: () {
                        if (userSnapshot[snapshot]['status'] == '1') {
                          var response = Firebaseentry.updatestatus(
                              userSnapshot[snapshot].id, '0');
                          // addeditem.forEach((element) {
                          //   print(element.id.toString() + 'Check is it unique');
                          // });
                          print(addeditem.length.toString() +
                              ' addeditemlength before');
                          // addeditem.rem(snapshot);?
                          addeditem.removeWhere((element) =>
                              element.name == userSnapshot[snapshot]['Name']);
                          print(
                              addeditem.length.toString() + ' addeditemlength');
                        } else {
                          var response = Firebaseentry.updatestatus(
                              userSnapshot[snapshot].id, '1');

                          setState(() {
                            addeditem.add(entry(
                                (snapshot).toString(),
                                userSnapshot[snapshot]['Name'],
                                userSnapshot[snapshot]['Qty'],
                                userSnapshot[snapshot]['Rate']));
                          });
                        }
                      },
                      title: Text(userSnapshot[snapshot]['Name']),
                      subtitle: Text(userSnapshot[snapshot]['Rate']),
                    ),
                  );
                });
          } else if (snapshot.hasError) {
            const Text('No data avaible right now');
          }
          return Center(child: CircularProgressIndicator());
          // if (snapshot.hasData) {
          //   return ListView.builder(
          //       itemCount: userSnapshot.length,
          //       itemBuilder: (context, snapshot) {
          //         if (userSnapshot.length > 0) {
          //           return Card(
          //             child: ListTile(
          //               title: Text(userSnapshot[snapshot]['Name']),
          //               subtitle: Text(userSnapshot[snapshot]['Rate']),
          //             ),
          //           );
          //         } else {
          //           return CircularProgressIndicator();
          //         }
          //       });
          // } else if(){
          //   return CircularProgressIndicator();
          // }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          TextEditingController name = TextEditingController();
          TextEditingController qty = TextEditingController();
          TextEditingController rate = TextEditingController();
          var formkey = GlobalKey<FormState>();
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return Container(
                  height: 500,
                  child: Form(
                      key: formkey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              TextFormField(
                                decoration: InputDecoration(
                                    hintText: 'Enter Name of item'),
                                controller: name,
                              ),
                              TextFormField(
                                decoration:
                                    InputDecoration(hintText: 'Enter Qty'),
                                controller: qty,
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                    hintText: 'Enter Name of item'),
                                controller: rate,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              InkWell(
                                onTap: () {
                                  if (formkey.currentState!.validate()) {
                                    if (name.text.isNotEmpty &&
                                        qty.text.isNotEmpty &&
                                        rate.text.isNotEmpty) {
                                      var response = Firebaseentry.insertData(
                                          name.text, rate.text, qty.text);
                                      setState(() {
                                        name.clear();
                                        rate.clear();
                                        qty.clear();
                                        Navigator.pop(context);
                                      });
                                    } else {
                                      var showsnackbar = SnackBar(
                                          content: Text('Check Above'));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(showsnackbar);
                                    }
                                  }
                                },
                                child: Container(
                                  height: 50,
                                  width: 100,
                                  color: Colors.red,
                                  child: Center(child: Text('Submit')),
                                ),
                              )
                            ],
                          ),
                        ),
                      )),
                );
              });
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class entry {
  String? id, name, qty, rate, status;
  entry(this.id, this.name, this.qty, this.rate, {this.status});
}

final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
final CollectionReference _Collection = _fireStore.collection('EntryScreen');

class Firebaseentry {
  static Stream<QuerySnapshot<Object?>> readEmployee() {
    CollectionReference notesItemCollection = _Collection;
    // print('${notesItemCollection.id}');mm

    return notesItemCollection.snapshots();
  }

  static Future<Response> insertData(
      String? name, String? rate, String? qty) async {
    int i = 1;
    Response response = Response();
    DocumentReference documentReference = _Collection.doc();
    Map<String, dynamic> data = {
      'ID': (i++).toString(),
      'Name': name,
      'Qty': qty,
      'Rate': rate,
      'status': '0'
    };
    var result = await documentReference.set(data).whenComplete(() {
      print('Successfully Data Inserted in Firebase');
      response.code = 200;
    }).catchError((e) {
      response.code = 500;
      response.message = e;
    });
    return response;
  }

  static Future<Response> updatestatus(docId, String? status) async {
    Response response = Response();
    DocumentReference documentReference = _Collection.doc(docId);
    Map<String, dynamic> map = {'status': status};
    await documentReference.update(map).whenComplete(() {
      print('successfully updated');
      response.code = 200;
    }).catchError((e) {
      response.code = 500;
    });
    return response;
  }
}

class Response {
  int? code;
  String? message;
  Response({this.code, this.message});
}
