import 'dart:async';
//import 'dart:html';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum _Element {
  background,
  text,
  shadow,
}

final _lightTheme = {
  _Element.background: Color(0xFF81B3FE),
  _Element.text: Colors.white,
  _Element.shadow: Colors.black,
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.white,
  _Element.shadow: Color(0xFF174EA6),
};

class CustomClock extends StatefulWidget {
  final ClockModel model;
  String currentTimePeriod;

  CustomClock(this.model);

  @override
  _CustomClockState createState() => _CustomClockState();
}

class _CustomClockState extends State<CustomClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(CustomClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  String displayTimePeriod(String hour) {
    if (int.parse(hour) >= 12) {
      return 'PM';
    } else if (int.parse(hour) <= 12) {
      return 'AM';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final fontSize = MediaQuery.of(context).size.width / 14.5;
    final temprature = widget.model.temperatureString;
    final weather = widget.model.weatherString;
    final location = widget.model.location;
    final second = DateFormat('ss').format(_dateTime);
    final offset = -fontSize / 7;
    final timerPeriod = displayTimePeriod(hour) == null
        ? widget.currentTimePeriod
        : displayTimePeriod(hour);
    widget.currentTimePeriod = timerPeriod;
    final defaultStyle = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'ConcertOne',
      fontSize: fontSize,
      shadows: [
        Shadow(
          blurRadius: 0,
          color: colors[_Element.shadow],
          offset: Offset(2, 0),
        ),
      ],
    );
    return AspectRatio(
      aspectRatio: 5 / 3,
      child: Container(
        color: colors[_Element.background],
        child: Stack(
          children: <Widget>[
            weatherAndDateInfo(
              colors[_Element.text],
              temprature,
              location,
              weather,
            ),
            displayDate(
              defaultStyle,
              hour,
              minute,
              second,
              timerPeriod,
            )
          ],
        ),
      ),
    );
  }

  Widget displayDate(TextStyle textStyle, String hour, String minute,
      String second, String timePeriod) {
    return Center(
      child: DefaultTextStyle(
        style: textStyle,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Flexible(
                  child: Text(hour),
                ),
              ],
            ),
            Flexible(
              child: Text(':'),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Flexible(
                  child: Text(minute),
                ),
              ],
            ),
            Flexible(
              child: Text(
                second,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width / 19.0,
                ),
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    timePeriod,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width / 14.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget weatherAndDateInfo(
      Color textColor, String temprature, String location, String weather) {
    return Positioned(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '$temprature $location',
                style: TextStyle(
                  color: textColor,
                  fontFamily: 'ConcertOne',
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                weather,
                style: TextStyle(
                  color: textColor,
                  fontFamily: 'ConcertOne',
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                DateFormat.yMMMd().format(_dateTime),
                style: TextStyle(
                  color: textColor,
                  fontFamily: 'ConcertOne',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        ],
      ),
      top: 5,
      right: 5,
    );
  }
}
