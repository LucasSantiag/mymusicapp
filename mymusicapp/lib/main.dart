import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mymusicapp/bottom_controls.dart';
import 'package:mymusicapp/songs.dart';
import 'package:mymusicapp/theme.dart';
import 'package:mymusicapp/radial_drag_gesture_detector.dart';
import 'package:fluttery_audio/fluttery_audio.dart';

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
    return new AudioPlaylist(
      playlist: demoPlaylist.songs.map((DemoSong song) {
        return song.audioUrl;
    }).toList(growable: false),
      playbackState: PlaybackState.playing,
      child: new Scaffold(
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

              //Seek Bar ------------------------------------------------------------
              new Expanded(
                child: AudioPlaylistComponent(
                  playlistBuilder: (BuildContext context, Playlist playlist, Widget child){
                    return AudioRadialSeekBar();
                  }
                ),
              ),

              //Visualizer ----------------------------------------------------------
              new Container(
                width: double.infinity,
                height: 125.0,
              ),

              //Song name, artist and controls --------------------------------------
              new ButtonControls()
            ],
          )),
    );
  }
}


class AudioRadialSeekBar extends StatefulWidget {
  @override
  _AudioRadialSeekBarState createState() => _AudioRadialSeekBarState();
}

class _AudioRadialSeekBarState extends State<AudioRadialSeekBar> {
  double _seekPercent;

  @override
  Widget build(BuildContext context) {
    return AudioComponent(
      updateMe: [
        WatchableAudioProperties.audioPlayhead,
        WatchableAudioProperties.audioSeeking,
      ],
      playerBuilder: (BuildContext context, AudioPlayer player, Widget child){
        double playbackProgress = 0.0;
        if (player.audioLength != null && player.position != null) {
          playbackProgress = player.position.inMilliseconds / player.audioLength.inMilliseconds;
        }

        _seekPercent = player.isSeeking ? _seekPercent : null;

        return  new RadialSeekBar(
          progress: playbackProgress,
          seekPercent: _seekPercent,
          onSeekRequested: (double seekPercent) {
            setState(() => _seekPercent = seekPercent);
            final seekMilis = (player.audioLength.inMilliseconds * seekPercent).round();
            player.seek(new Duration(milliseconds: seekMilis));
          },
        );
      },
    );
  }
}






class RadialSeekBar extends StatefulWidget {

  final double progress;
  final double seekPercent;
  final Function(double) onSeekRequested;

  RadialSeekBar({
    this.progress = 0.0,
    this.seekPercent = 0.0,
    this.onSeekRequested,
  });

  @override
  RadialSeekBarState createState() {
    return new RadialSeekBarState();
  }
}

class RadialSeekBarState extends State<RadialSeekBar> {

  double _progress = 0.0;
  PolarCoord _startDragCoord;
  double _startDragPercent;
  double _currentDragPercent;

  @override
  void initState() {
    super.initState();
    _progress = widget.progress;
  }

  @override
  void didUpdateWidget(RadialSeekBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _progress = widget.progress;
  }

  void _onDragStart(PolarCoord coord) {
    _startDragCoord = coord;
    _startDragPercent = _progress;
  }

  void _onDragEnd() {
    if(widget.onSeekRequested != null) {
      widget.onSeekRequested(_currentDragPercent);
    }


    setState(() {
      _currentDragPercent = null;
      _startDragCoord = null;
      _startDragPercent = 0.0;
    });
  }

  void _onDragUpdate(PolarCoord coord)  {
    final dragAngle = coord.angle - _startDragCoord.angle;
    final dragPercent = dragAngle / ( 2*pi );

    setState(() => _currentDragPercent = (_startDragPercent + dragPercent) % 1.0);
  }

  @override
    Widget build(BuildContext context) {
      double thumbPosition = _progress;
      if (_currentDragPercent != null) {
        thumbPosition = _currentDragPercent;
      } else if (widget.seekPercent != null) {
        thumbPosition = widget.seekPercent;
      }

      return new RadialDragGestureDetector(
        onRadialDragStart: _onDragStart,
        onRadialDragUpdate: _onDragUpdate,
        onRadialDragEnd: _onDragEnd,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.transparent,
          child: new Center(
            child: new Container(
              width: 140.0,
              height: 140.0,
              child: new RadialProgressBar(
                trackColor: Color(0xFFDDDDDD),
                progressPercent: _progress,
                progressColor: accentColor,
                thumbPosition: thumbPosition,
                thumbColor: lightAccentColor,
                innerPadding: const EdgeInsets.all(10.0),
                child: new ClipOval(
                  clipper: new CircleClipper(),
                  child: new Image.network(
                    demoPlaylist.songs[0].albumArtUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }






class RadialProgressBar extends StatefulWidget {

  final double trackWidth;
  final Color trackColor;
  final double progressWidth;
  final Color progressColor;
  final double progressPercent;
  final double thumbSize;
  final Color thumbColor;
  final double thumbPosition;
  final EdgeInsets outerPadding;
  final EdgeInsets innerPadding;
  final Widget child;

  RadialProgressBar({
    this.trackWidth = 3.0,
    this.trackColor = Colors.grey,
    this.progressWidth = 5.0,
    this.progressColor = Colors.black,
    this.thumbSize = 10.0,
    this.thumbColor = Colors.black,
    this.progressPercent = 0.0,
    this.thumbPosition = 0.0,
    this.outerPadding = const EdgeInsets.all(0.0),
    this.innerPadding = const EdgeInsets.all(0.0),
    this.child
  });

  @override
  _RadialProgressBarState createState() => _RadialProgressBarState();
}

class _RadialProgressBarState extends State<RadialProgressBar> {

  EdgeInsets _insetsForPainter() {
    final outerThickness = max(
      widget.trackWidth,
      max(
        widget.progressWidth,
        widget.thumbSize
      )
    ) / 2.0;
    return EdgeInsets.all(outerThickness);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.outerPadding,
      child: new CustomPaint(
        foregroundPainter :  new RadialProgressBarPainter(
          trackWidth: widget.trackWidth,
          trackColor: widget.trackColor,
          progressWidth: widget.progressWidth,
          progressColor: widget.progressColor,
          progressPercent: widget.progressPercent,
          thumbSize: widget.thumbSize,
          thumbColor: widget.thumbColor,
          thumbPosition: widget.thumbPosition
        ),
        child: new Padding(
          padding: _insetsForPainter() + widget.innerPadding,
          child: widget.child,
        ),
      ),
    );
  }
}

class RadialProgressBarPainter extends CustomPainter {

  final double trackWidth;
  final Paint trackPaint;
  final double progressWidth;
  final double progressPercent;
  final Paint progressPaint;
  final double thumbSize;
  final double thumbPosition;
  final Paint thumbPaint;

  RadialProgressBarPainter({
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

    final outerThickness = max(trackWidth, max(progressWidth, thumbSize));
    Size constraintedSize = new Size(
      size.width - outerThickness,
      size.height - outerThickness
    );

    final center = new Offset(size.width / 2, size.height / 2);
    final radius = min(constraintedSize.width, constraintedSize.height) / 2;

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