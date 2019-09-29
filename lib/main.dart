import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter_game/netUnit.dart';
import 'package:toast/toast.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: '游戏',
      debugShowCheckedModeBanner: false,
      home: Second_alarm_page(),
    );
  }
}

class Roule {
  String title;
  bool answer;

  Roule({this.answer, this.title});
}

class Second_alarm_page extends StatefulWidget {
  @override
  _Second_alarm_pageState createState() => _Second_alarm_pageState();
}

class _Second_alarm_pageState extends State<Second_alarm_page>
    with TickerProviderStateMixin {
  AnimationController animationController;
  Animation<Offset> animation;
  List<Roule> list;
  int arwa = 0; //随机数
  int score = 0; // 得分
  bool _switch = false;
  String time = '0';
  Timer timer;
  int test = 0;
  bool show = false;

  int bestscroe;

  void send(String score) async {
    if (bestscroe != null && int.parse(score) > bestscroe) {
      await NetUnit.get(
        url: 'http://192.168.1.1:8080/user/sava/api?data=${score}',
      );
    }
  }

  void get() async{
   await NetUnit.get(
      url: 'http://192.168.1.1:8080/user/get',
    ).then((data) {
      setState(() {
        bestscroe = int.parse(data);
      });
    });
  }

  void bug() {
    int i = 0;
    timer = Timer.periodic(Duration(milliseconds: 500), (_) {
      i++;
      addScore();
      animationController.reset();
      animationController.forward();

      if (i > 519) {
        timer.cancel();
        setState(() {
          show = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[


          SlideTransition(
            position: animation,
            child: Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .height,
              color: Colors.amber,
            ),
          ),
          show ? Image.asset(
            'images/love.jpg', fit: BoxFit.cover, height: MediaQuery
              .of(context)
              .size
              .height, width: MediaQuery
              .of(context)
              .size
              .width,):Container(),
          // Positioned(child:Text(time,style: TextStyle(fontSize: 32,),),right: 50,top: 50, ),
          Positioned(
            child: bestscroe != null
                ? RichText(
                text: TextSpan(
                    text: '最好成绩：',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                    children: [
                      TextSpan(
                        text: '${bestscroe}',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      )
                    ]))
                : Text('同步中..'),
            right: 50,
            top: 50,
          ),

          Positioned(
            top: 120,
            right: 100,
            left: 100,
            child: Center(
                child: GestureDetector(
                  onLongPress: () {
                    if (_switch&&animationController.status==AnimationStatus.forward) {
                      Toast.show('恭喜你找到开挂的方式', context,
                          duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
                      bug();
                    }
                    },
                  child: Text('${score}',
                      style: TextStyle(
                          color: show?Colors.pinkAccent:Colors.black,
                          fontSize: 64,
                          fontWeight: FontWeight.bold)),
                )),
          ),

          show ? Positioned(
              top: 200,
              right: 100,
              left: 100,
              child: Center(
                child: Text('yby',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold)),
              ))
              : Container(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Text(
                    list[arwa].title,
                    style: TextStyle(fontSize: 32),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Container(
                      height: 64,
                      width: 64,
                      child: RaisedButton(
                        color: Colors.yellow,
                        shape: CircleBorder(),
                        onPressed: () {
                          if (animationController.status ==
                              AnimationStatus.forward) {
                            if (list[arwa].answer) {

                              addScore();
                              GameController(isshow: true);
                            } else {
                              //    deletScore();
                              GameController(isshow: false);
                              over();
                            }
                          } else {}

                          ;
                        },
                        child: Text(
                          '对',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24),
                        ),
                      ),
                    ),
                    Container(
                      height: 64,
                      width: 64,
                      child: RaisedButton(
                          color: Colors.green,
                          shape: CircleBorder(),
                          onPressed: () {
                            if (animationController.status ==
                                AnimationStatus
                                    .forward) if (!list[arwa].answer) {

                              addScore();
                              GameController(isshow: true);
                            } else {
                              //     deletScore();
                              GameController(isshow: false);
                              over();
                            }
                            ;
                          },
                          child: Text(
                            '错',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 24),
                          )),
                    )
                  ],
                ),
                Center(
                  child: GestureDetector(
                      onTap: () {
                        if (_switch) {
                          over();

                          setState(() {
                            arwa = Random.secure().nextInt(list.length);
                            score = 0;
                            animationController.reset();
                            timer!=null?timer.cancel():null;
                            _switch = false;
                            show=false;
                            send(score.toString());
                          });

                        } else {
                          setState(() {
                            animationController.forward();
                            _switch = true;
                          });
                        }

                        // Controller();
                      },
                      child: Text(
                        '${_switch ? '重来' : '开始'}',
                        style: TextStyle(fontSize: 24),
                      )),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  GameController({bool isshow}) {
    if (isshow) {
      switch (animationController.status) {
        case AnimationStatus.dismissed:
        // TODO: Handle this case.
          break;
        case AnimationStatus.forward:
          animationController.reset();
          animationController.forward();
          break;
        case AnimationStatus.reverse:
        // TODO: Handle this case.
          break;
        case AnimationStatus.completed:
        //   deletScore();
          animationController.reset();

          break;
      }
    } else {
      switch (animationController.status) {
        case AnimationStatus.dismissed:
        // TODO: Handle this case.
          break;
        case AnimationStatus.forward:
          animationController.reset();
          // deletScore();
          break;
        case AnimationStatus.reverse:
        // TODO: Handle this case.
          break;
        case AnimationStatus.completed:
        //    deletScore();
          animationController.reset();

          break;
      }
    }
  }

  void DeletScore(){
    setState(() {
      score = 0;
    });
  }

  addScore() {
    setState(() {
      arwa = Random.secure().nextInt(list.length);
      score = score + 1;
    });
  }

  over() {
    send(score.toString());
    get();
  }
  @override
  void initState() {
    super.initState();
    get();

    list = [
      Roule(answer: true, title: '1+1=2'),
      Roule(answer: false, title: '1+5=5'),
      Roule(answer: true, title: '1+4=5'),
      Roule(answer: true, title: '1+3=4'),
      Roule(answer: false, title: '1+2=4'),
    ];

    animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    animation = Tween(begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0))
        .animate(animationController);
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        over();
      }
    });
  }
}
