import 'dart:async';

import 'package:flutter/material.dart';
import 'music.dart';
import 'package:audioplayer/audioplayer.dart';

void main() => runApp(MyApp());
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Codda Music',
      theme: ThemeData(
      primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Coda Music'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Music> maListDeMusic = [
    new Music("Mon confident", "Abdoul Kas.", "assets/un.jpg", "http://codabee.com/wp-content/uploads/2018/06/un.mp3"),
    new Music("My Brother", "Djuma Heri", "assets/deux.jpg", "http://codabee.com/wp-content/uploads/2018/06/deux.mp3"),
    new Music("My mom", "Alima Ass.", "assets/trois.jpg", "http://codabee.com/wp-content/uploads/2018/06/un.mp3"),
    new Music("Mon ami", "Guillain", "assets/quatre.jpg", "http://codabee.com/wp-content/uploads/2018/06/deux.mp3"),
    //  new Music("Mon coeur", "harmonie Mwanza", "assets/cinq.jpg", "assets/5.mp3")
  ];

  AudioPlayer audioPlayer;
  Music maMusicActuelle;
  StreamSubscription positionSub;
  StreamSubscription stateSubscription;
  Duration position = new Duration(seconds: 0);
  Duration duree = new Duration(seconds: 0);
  PlayerState status = PlayerState.stopped;
  int index = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    maMusicActuelle = maListDeMusic[index];
    configurationAudioPlayer();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey[900],
        title: Text(widget.title),
      ),
      backgroundColor: Colors.grey[800],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Card(
              elevation: 9.0,
              child: new Container(
                width: MediaQuery.of(context).size.height/2.4,
                child: new Image.asset(maMusicActuelle.imagePath, fit: BoxFit.fitHeight,),
              ),
            ),
            textWithStyle(maMusicActuelle.titre, 1.5),
            textWithStyle(maMusicActuelle.artiste, 1.0),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                bouton(Icons.fast_rewind, 30.0, ActionMusic.rewind),
                bouton((status == PlayerState.playing)?Icons.pause:Icons.play_arrow, 45.0,(status == PlayerState.playing)?ActionMusic.pause: ActionMusic.play),
                bouton(Icons.fast_forward, 30.0, ActionMusic.forward),
            ],),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                textWithStyle(fromDuration(position), 0.8),
                textWithStyle(fromDuration(duree), 0.8),
              ],
            ),
            new Slider(
              value: position.inSeconds.toDouble(),
              min: 0.0,
              max: maxIntervalle(duree),
              inactiveColor: Colors.white,
              activeColor: Colors.red,
              onChanged: (double d) {
                setState(() {
                  //  Duration nouvelleDuration = new Duration(seconds: d.toInt());
                  //  position = nouvelleDuration;
                  audioPlayer.seek(d);
                });
              },
            )
          ],
        ),
      ),
    );
  }

  IconButton bouton(IconData icone, double taille, ActionMusic action) {
      return IconButton(icon: new Icon(icone),
      iconSize: taille,
      color: Colors.white,
      onPressed: () {
        switch(action) {
          case ActionMusic.play:
            play();
            break;
          case ActionMusic.pause:
            pause();
            break;
          case ActionMusic.forward:
           forward();
            break;
          case ActionMusic.rewind:
            rewind();
            break;
        }
      },
      );
  }


  Text textWithStyle(String data, double scale) {
    return new Text(data,
    textScaleFactor: scale,
    textAlign: TextAlign.center,
    style: new TextStyle(
      color: Colors.white,
      fontSize: 20.0,
    ),
    );
  }
 
 void test(Duration post) {
     position = post;
     if (position.inSeconds == duree.inSeconds) {
       clean();
     }
 }
  void configurationAudioPlayer() {
    audioPlayer = new AudioPlayer();
    positionSub = audioPlayer.onAudioPositionChanged.listen(
      (post) => setState(() => test(post))
    );
    stateSubscription = audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == AudioPlayerState.PLAYING) {
        setState(() {
          duree = audioPlayer.duration;
        });
      } else if (state == AudioPlayerState.PAUSED) {
        setState(() {
          status = PlayerState.stopped;
        });
      }
    }, onError: (message) {
      print('Erreur : $message');
      setState(() {
        status = PlayerState.stopped;
        duree = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    });
  }

  Future play() async{
    await audioPlayer.play(maMusicActuelle.urlSong);
    setState(() {
      status = PlayerState.playing;
    });
  }

  Future pause() async{
    await audioPlayer.pause();
    setState(() {
      status = PlayerState.paused;
    });
  }

  void forward() {
    if (index == maListDeMusic.length - 1) {
      index = 0;
    } else {
      index++;
    }
    maMusicActuelle = maListDeMusic[index];
    audioPlayer.stop();
    configurationAudioPlayer();
    play();
  }

  void rewind() {
    /* if (position > Duration(seconds:  3)) {
      audioPlayer.seek(0);
    } else { */
      if (index == 0) {
        index = maListDeMusic.length -1;
      } else {
        index--;
      }
      maMusicActuelle = maListDeMusic[index];
      audioPlayer.stop();
      configurationAudioPlayer();
      play();
    //}
  }

  String fromDuration(Duration _duree) {
    //  print(_duree.toString().split('.').first);
    return _duree.toString().split('.').first;
  }

  double maxIntervalle(Duration _duree) {
    if (_duree.inSeconds == 0){
      return 1.0;
    } else {
      print(_duree.inSeconds.toString());
      return _duree.inSeconds.toDouble();
    }
  }

  void clean() {
    position = new Duration(seconds: 0);
    pause();
    /* setState(() {
      status = PlayerState.paused;
    }); */
  }
}


 enum ActionMusic {
    play,
    pause,
    rewind,
    forward
  }
  enum PlayerState {
    playing,
    stopped,
    paused
  }
