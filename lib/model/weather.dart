import 'package:weather/weather.dart';

class WeatherInfo {
  final Weather todayWeather;
  final List<Weather> fiveDaysWeather;

  const WeatherInfo(
      {required this.todayWeather, required this.fiveDaysWeather});
}