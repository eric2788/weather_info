import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weather/weather.dart';

class TodayWeatherCard extends StatelessWidget{

  final Weather weather;
  final IconData weatherIcon;

  const TodayWeatherCard({Key? key, required this.weather, required this.weatherIcon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Colors.transparent,
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomRight,
                  colors: [Colors.purple, Colors.blue])),
          width: 80,
          padding: const EdgeInsets.all(5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Icon(weatherIcon,
                  size: 30.0, color: Colors.white),
              const SizedBox(height: 9),
              Text(
                ' ${weather.temperature?.celsius?.floor() ?? 0}°',
                style: const TextStyle(color: Colors.white, fontSize: 30),
              ),
              const SizedBox(height: 15),
              Center(
                child: Text(
                    weather.date?.toString().substring(11, 16) ?? 'UNKNOWN',
                    style:
                    const TextStyle(color: Colors.white, fontSize: 20)),
              )
            ],
          ),
        )
    );
  }
}

class FiveDayWeatherCard extends StatelessWidget{

  final Weather weather;
  final IconData weatherIcon;

  const FiveDayWeatherCard({Key? key, required this.weather, required this.weatherIcon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Colors.transparent,
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomRight,
                  colors: [Colors.purple, Colors.blue])),
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Text(
                '${weather.date?.day}',
                style: const TextStyle(color: Colors.white, fontSize: 40),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ' ${weather.temperature?.celsius?.floor() ?? 0}°',
                    style:
                    const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(width: 5),
                  Icon(weatherIcon,
                      size: 20.0, color: Colors.white),
                ],
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(weather.weatherMain ?? 'UNKNOWN',
                    style:
                    const TextStyle(color: Colors.white, fontSize: 20)),
              )
            ],
          ),
        )
    );
  }

}