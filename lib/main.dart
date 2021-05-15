import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';

import 'model/weather.dart';
import 'widget/weather_info_show.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'WeatherApp',
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
        home: const MyHomePage());
  }
}

Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

class MyHomePage extends StatefulWidget {

  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const String _apiKey = "a66a0b1366de7b889f754c217598362a";
  final WeatherFactory wf = WeatherFactory(_apiKey);

  late Future<WeatherInfo> _weatherInfo;

  @override
  void initState() {
    super.initState();
    _weatherInfo = _getWeatherInfo();
  }

  static final errorBar = SnackBar(
    padding: const EdgeInsets.all(5.0),
    content: Container(
      padding: const EdgeInsets.only(left: 20),
        child: const Text('We cannot find the city/country you have typed.',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        )
    ),
    action: SnackBarAction(
      label: 'DISMISS',
      onPressed: () {},
    ),
  );

  Future<WeatherInfo> _getWeatherInfo([String city = '']) async {
    try {
      if (city.isEmpty) {
        var pos = await determinePosition();
        var weather =
            await wf.currentWeatherByLocation(pos.latitude, pos.longitude);
        var fiveWeathers =
            await wf.fiveDayForecastByLocation(pos.latitude, pos.longitude);
        return WeatherInfo(
            todayWeather: weather, fiveDaysWeather: fiveWeathers);
      } else {
        var weather = await wf.currentWeatherByCityName(city);
        var fiveWeathers = await wf.fiveDayForecastByCityName(city);
        return WeatherInfo(
            todayWeather: weather, fiveDaysWeather: fiveWeathers);
      }
    } on OpenWeatherAPIException catch (e) {
      return Future.error(e);
    }
  }

  void onSearch(String city) {
    log('searching weather with city: $city');
    setState(() {
      _weatherInfo = _getWeatherInfo(city);
    });
  }

  late WeatherInfo _lastData;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        body: Center(
      child: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [Colors.deepPurple, Colors.blue])),
          child: Center(
              child: FutureBuilder<WeatherInfo>(
            future: _weatherInfo,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  log('has data: ${snapshot.data != null}');
                  _lastData = snapshot.data!;
                  return WeatherInfoShow(
                      weatherInfo: snapshot.data!, onSearch: onSearch);
                } else if (snapshot.hasError) {
                  log('has error: ${snapshot.error}');
                  WidgetsBinding.instance?.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(errorBar);
                  });
                  return WeatherInfoShow(
                      weatherInfo: _lastData, onSearch: onSearch);
                }
              }
              return const CircularProgressIndicator(color: Colors.white);
            },
          ))),
    ));
  }
}
