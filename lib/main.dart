import 'dart:async';
import 'dart:developer';
import 'dart:io';

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

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  static const String _apiKey = "a66a0b1366de7b889f754c217598362a";
  final WeatherFactory wf = WeatherFactory(_apiKey);
  WeatherInfo? _lastData;
  late Tween<Offset> _tween;
  late AnimationController _animationController;
  late Future<WeatherInfo> _weatherInfo;
  late CurvedAnimation _curvedAnimation;

  @override
  void initState() {
    super.initState();
    _weatherInfo = _getWeatherInfo();
    _tween = Tween<Offset>(begin: const Offset(0.0, 0.4), end: Offset.zero);
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _curvedAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeOut);
    //Timer(const Duration(milliseconds: 200), () => _animationController.forward());
  }

  static final cityErrorBar =
      _buildErrorBar('We cannot find the city/country you have typed.');

  static SnackBar _buildErrorBar(String errMessage) {
    return SnackBar(
      padding: const EdgeInsets.all(5.0),
      content: Container(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            errMessage,
            style:
                const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          )),
      action: SnackBarAction(
        label: 'DISMISS',
        onPressed: () {},
      ),
    );
  }


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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

  Widget _buildSlideWidget(Widget widget) {
    return SlideTransition(
        position: _tween.animate(_curvedAnimation),
        child: FadeTransition(
          opacity: _animationController
            ..forward(),
          child: widget
        )
    );
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
                  return _buildSlideWidget(WeatherInfoShow(
                      weatherInfo: snapshot.data!, onSearch: onSearch));
                } else if (snapshot.hasError) {
                  log('has error: ${snapshot.error}');
                  if (_lastData != null) {
                    WidgetsBinding.instance?.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(context).showSnackBar(cityErrorBar);
                    });
                    return _buildSlideWidget(WeatherInfoShow(
                        weatherInfo: _lastData!, onSearch: onSearch));
                  } else {
                    return AlertDialog(
                      title: const Text('Something Went Wrong'),
                      content: ListBody(
                        children: [
                          const Text('OPPS, there is an error.'),
                          Text('${snapshot.error}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          const Text('you must open your GPS to make the app work.'),
                          const Text('please open the GPS first and click RETRY.')
                        ],
                      ),
                      actions: [
                        TextButton(
                            onPressed: () => onSearch(''),
                            child: const Text('RETRY'))
                      ],
                    );
                  }
                }
              }
              return const CircularProgressIndicator(color: Colors.white);
            },
          ))),
    ));
  }
}
