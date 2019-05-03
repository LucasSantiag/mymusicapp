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
                  child: new ClipOval(
                    clipper: new CircleClipper(),
                    child: new Image.network(
                      demoPlaylist.songs[0].albumArtUrl,
                      fit: BoxFit.cover,
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
