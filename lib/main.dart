import 'package:flutter/material.dart';
import 'package:adj/initializer.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) async {});
  var initializationSettings =
      InitializationSettings(iOS: initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
  });

  await _configureLocalTimeZone();

  runApp(MaterialApp(
      title: 'Average Daily Juggle',
      theme: ThemeData(primaryColor: Colors.lightGreen[50]),
      home: ADJ()));
}

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}

class ADJ extends StatefulWidget {
  @override
  _ADJState createState() => _ADJState();
}

class _ADJState extends State<ADJ> {
  String label = "Average Daily Juggle";
  final _formKey = GlobalKey<FormState>();
  var msgController = TextEditingController();
  List juggleList = [];
  int adj;
  bool averageBool = true;
  JSONReader initializer = JSONReader();

  setupFunction() async {
    Map holder = await initializer.readJSON();

    holder['juggles'] == [] ? juggleList = [0] : juggleList = holder['juggles'];
    setState(() {
      average();
    });
  }

  average() {
    if (juggleList != []) {
      adj = (juggleList.reduce((value, element) => value + element) /
              juggleList.length)
          .round();
    } else {
      adj = 0;
      juggleList.add(0);
    }
  }

  switchData() {
    if (averageBool == true) {
      label = 'Juggle High Score';
      adj = (juggleList.reduce((curr, next) => curr > next ? curr : next));
      averageBool = false;
    } else {
      label = "Average Daily Juggle";
      average();
      averageBool = true;
    }
  }

  @override
  void initState() {
    super.initState();
    _scheduleDailyTenAMNotification();
    setupFunction();
  }

  @override
  Widget build(BuildContext context) {
    return juggleList.isEmpty
        ? Container(
            child: Scaffold(
                body: (Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: SpinKitDoubleBounce(
                  color: Colors.white,
                  size: 50.0,
                ),
              ),
            ],
          ))))
        : Scaffold(
            body: Stack(
              children: [
                Container(
                    decoration: new BoxDecoration(
                  image: new DecorationImage(
                      image: AssetImage('backgrounds/bg1.jpg'),
                      fit: BoxFit.cover),
                )),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 60.0, horizontal: 30),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Card(
                        color: Colors.lightGreen[50].withOpacity(0.5),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Row(
                            children: [
                              Text('Today:',
                                  style: TextStyle(
                                      color: Colors.grey[100], fontSize: 20)),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Form(
                                  key: _formKey,
                                  child: Container(
                                    height: 50,
                                    width: 100,
                                    child: TextFormField(
                                        decoration: InputDecoration(
                                            hintText: 'Juggles',
                                            hintStyle: TextStyle(
                                              color: Colors.grey[100],
                                              fontSize: 20.0,
                                              letterSpacing: 1.5,
                                              fontWeight: FontWeight.bold,
                                            )),
                                        controller: msgController,
                                        validator: (number) {
                                          if (number == null ||
                                              isNumeric(number) == false) {
                                            return 'Enter a number';
                                          }
                                          return null;
                                        },
                                        keyboardType: TextInputType.text,
                                        onFieldSubmitted: (value) {
                                          if (_formKey.currentState
                                              .validate()) {
                                            setState(() {
                                              if (juggleList[0] == 0) {
                                                juggleList[0] =
                                                    int.parse(value);
                                              } else {
                                                juggleList
                                                    .add(int.parse(value));
                                              }
                                              initializer.writeJSON(
                                                  {'juggles': juggleList});
                                              average();
                                              msgController.clear();
                                            });
                                          }
                                        }),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          label,
                          style: TextStyle(
                              color: Colors.grey[100],
                              fontSize: 50,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.black.withOpacity(0.5),
                                  offset: Offset(5.0, 5.0),
                                )
                              ]),
                          softWrap: true,
                          textAlign: TextAlign.center,
                        )),
                  ),
                ),
                Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onDoubleTap: () {
                        setState(() {
                          switchData();
                        });
                      },
                      child: Text('$adj',
                          style: TextStyle(
                              fontSize: 80,
                              color: Colors.grey[100],
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.black.withOpacity(0.5),
                                  offset: Offset(5.0, 5.0),
                                )
                              ])),
                    ))
              ],
            ),
          );
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    // ignore: deprecated_member_use
    return double.parse(s, (e) => null) != null;
  }

  Future<void> _scheduleDailyTenAMNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Average Daily Juggle',
        'Remember to get your touches in!',
        _nextInstanceOfTenAM(),
        const NotificationDetails(
          android: AndroidNotificationDetails(
              'daily notification channel id',
              'daily notification channel name',
              'daily notification description'),
          iOS: IOSNotificationDetails(sound: 'sound'),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  tz.TZDateTime _nextInstanceOfTenAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 16);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
