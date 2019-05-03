import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mymusicapp/bottom_controls.dart';
import 'package:mymusicapp/songs.dart';
import 'package:mymusicapp/theme.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          leading: new IconButton(
            icon: new Icon(
              Icons.arrow_back_ios,
            ),
            color: const Color(0xFFDDDDDD),
            onPressed: () {},
          ),
          title: new Text(' '),
          actions: <Widget>[
            new IconButton(
              icon: new Icon(
                Icons.menu,
              ),
              color: const Color(0xFFDDDDDD),
              onPressed: () {},
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            //Seek Bar ------------------------
            new Expanded(
              child: new Center(
                child: new Container(
                  width: 125.0,
                  height: 125.0,
                  child: new RadialSeekBar(
                    progressPercent: 0.2,
                    thumbPosition: 0.2,
                    child: new ClipOval(
                      clipper: new CircleClipper(),
                      child: new Image.network(
                        demoPlaylist.songs[0].albumArtUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              )
            ),

            //Visualizer ------------------------
            new Container(
              width: double.infinity,
              height: 125.0,
            ),

            //Song name, artist and controls ------------------------
            new ButtonControls()
          ],
        ));
  }
}

class RadialSeekBar extends StatefulWidget {

  final double trackWidth;
  final Color trackColor;
  final double progressWidth;
  final Color progressColor;
  final double progressPercent;
  final double thumbSize;
  final Color thumbColor;
  final double thumbPosition;
  final Widget child;

  RadialSeekBar({
    this.trackWidth = 3.0,
    this.trackColor = Colors.grey,
    this.progressWidth = 5.0,
    this.progressColor = Colors.black,
    this.thumbSize = 10.0,
    this.thumbColor = Colors.black,
    this.progressPercent = 0.0,
    this.thumbPosition = 0.0,
    this.child
  });

  @override
  _RadialSeekBarState createState() => _RadialSeekBarState();
}

class _RadialSeekBarState extends State<RadialSeekBar> {
  @override
  Widget build(BuildContext context) {
    return new CustomPaint(
      painter:  new RadialSeekBarPainter(
        trackWidth: widget.trackWidth,
        trackColor: widget.trackColor,
        progressWidth: widget.progressWidth,
        progressColor: widget.progressColor,
        progressPercent: widget.progressPercent,
        thumbSize: widget.thumbSize,
        thumbColor: widget.thumbColor,
        thumbPosition: widget.thumbPosition
      ),
      child: widget.child,
    );
  }
}

class RadialSeekBarPainter extends CustomPainter {

  final double trackWidth;
  final Paint trackPaint;
  final double progressWidth;
  final double progressPercent;
  final Paint progressPaint;
  final double thumbSize;
  final double thumbPosition;
  final Paint thumbPaint;

  RadialSeekBarPainter({
    @required this.trackWidth,
    @required trackColor,
    @required this.progressWidth,
    @required progressColor,
    @required this.thumbSize,
    @required thumbColor,
    @required this.progressPercent,
    @required this.thumbPosition
  }) : trackPaint = new Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = trackWidth,
      progressPaint = new Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = progressWidth
        ..strokeCap = StrokeCap.round,
      thumbPaint = new Paint()
        ..color = thumbColor
        ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {

    final center = new Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    //Paint Track
    canvas.drawCircle(
        center,
        radius,
        trackPaint
    );
    
    //Paint Progress
    final progressAngle = 2* pi * progressPercent;
    canvas.drawArc(
        new Rect.fromCircle(
          center: center,
          radius: radius
        ),
        -pi / 2,
        progressAngle,
        false,
        progressPaint
    );

    //Paint Thumb
    final thumbAngle = 2 * pi * thumbPosition - (pi / 2);
    final thumbX = cos(thumbAngle) * radius;
    final thumbY = sin(thumbAngle) * radius;
    final thumbCenter = new Offset(thumbX , thumbY) + center;
    final thumbRadius = thumbSize  / 2.0;
    canvas.drawCircle(
        thumbCenter,
        thumbRadius,
        thumbPaint
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}