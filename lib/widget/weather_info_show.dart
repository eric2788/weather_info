import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import 'package:weather/weather.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:weather_info/extension.dart';
import 'package:weather_info/model/weather.dart';
import 'package:weather_info/widget/search_bar.dart';
import 'package:weather_info/widget/weather_cards.dart';

class WeatherInfoShow extends StatelessWidget {
  WeatherInfoShow(
      {Key? key, required WeatherInfo weatherInfo, required this.onSearch})
      : weather = weatherInfo.todayWeather,
        fiveDaysWeathers = weatherInfo.fiveDaysWeather,
        super(key: key);

  final OnSearch onSearch;
  final Weather weather;
  final List<Weather> fiveDaysWeathers;

  final Map<String, IconData> weatherIcons = {
    "Clear": Icons.wb_sunny,
    "Clouds": Icons.wb_cloudy,
    "Atmosphere": MdiIcons.weatherFog,
    "Snow": MdiIcons.weatherSnowy,
    "Rain": MdiIcons.weatherRainy,
    "Drizzle": MdiIcons.weatherPartlyRainy,
    "Thunderstorm": MdiIcons.bolt
  };

  IconData _getIconFromWeather(Weather weather) {
    return weatherIcons[weather.weatherMain] ?? Icons.error;
  }

  void beforeSearch(String city) {
    if (city == weather.areaName) return;
    onSearch(city);
  }

  List<Widget> _getFiveDayCards() {
    return fiveDaysWeathers
        .distinct((w) => w.date?.day ?? w) // distinct day
        .map((weather) => FiveDayWeatherCard(
            weather: weather, weatherIcon: _getIconFromWeather(weather)))
        .take(5)
        .toList();
  }

  List<Widget> _getTodayCards() {
    return fiveDaysWeathers
        .where((w) => w.date?.isToday() ?? false)
        .map((weather) => TodayWeatherCard(
            weather: weather, weatherIcon: _getIconFromWeather(weather)))
        .toList(); // only today
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 10),
          child:
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const SizedBox(height: 10),
            SearchBar(label: 'Search city/country', onSearch: beforeSearch),
            const SizedBox(height: 40),
            Icon(_getIconFromWeather(weather), size: 75.0, color: Colors.white),
            const SizedBox(height: 15),
            Center(
              child: Text(
                ' ${weather.temperature?.celsius?.floor() ?? 0}°',
                style: const TextStyle(
                    color: Colors.white, fontSize: 80, letterSpacing: -5),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                weather.areaName ?? 'UNKNOWN',
                style: const TextStyle(color: Colors.white, fontSize: 40),
              ),
            ),
            const SizedBox(height: 30),
            Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 15.0),
                alignment: Alignment.topLeft,
                child: ListBody(
                  children: const [
                    Text("Today",
                        style: TextStyle(color: Colors.white, fontSize: 20)),
                    SizedBox(height: 10),
                    Text("now -> 23:59",
                        style: TextStyle(color: Colors.white, fontSize: 17)),
                  ],
                )),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              height: 200,
              child: Card(
                color: Colors.white.withOpacity(0.5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(5.0),
                    children: _getTodayCards(),
                  ),
                ),
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              alignment: Alignment.topLeft,
              child: const Text(
                'Recent 5 days',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              height: 200,
              child: Card(
                  color: Colors.white.withOpacity(0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: _getFiveDayCards(),
                    ),
                  )),
            )
          ]),
        )
      ],
    );
  }
}
