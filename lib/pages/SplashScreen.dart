import 'dart:async';

import 'package:autocalen/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin{

  AnimationController _controller;
  Animation<Offset> _animation1;
  Animation<Offset> _animation2;
  Animation<Offset> _animation3;
  Animation<Offset> _animation4;
  Animation<double> _animation5;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..forward()..addStatusListener((AnimationStatus status) {
      print(status);
      if (status == AnimationStatus.dismissed)
        _controller.forward();
      else if (status == AnimationStatus.completed){
        print("animation 끝남!!!");
        _controller.reverse();
        Navigator.pushNamed(context, '/home');
        //메인 페이지 위젯으로 이동하면서 연결된 모든 위젯을 트리에서 삭제
        //Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    });

    _animation1 = Tween<Offset>(
      begin: const Offset(3, -5),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(
        0.0, 0.2,
        curve: Curves.ease,
      ),
    ));
    _animation2 = Tween<Offset>(
      begin: const Offset(3, 5),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(
        0.4, 0.6,
        curve: Curves.ease,
      ),
    ));
    _animation3 = Tween<Offset>(
      begin: const Offset(-3, 5),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(
        0.2, 0.4,
        curve: Curves.ease,
      ),
    ));
    _animation4 = Tween<Offset>(
      begin: const Offset(-3, -5),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(
        0.6, 0.8,
        curve: Curves.ease,
      ),
    ));
    _animation5 = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(
        0.8, 1.0,
        curve: Curves.ease,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    print('=======================Splash Screen Build==============================');

    return Scaffold(
      body: Builder(
          builder: (context) => Center(
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: SlideTransition(
                        position: _animation1,
                        child: Image.asset('images/logo/logo_right_top.png')//Text('animation2', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: SlideTransition(
                        position: _animation2,
                        child: Image.asset('images/logo/logo_right_bottom.png')//Text('animation3', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: SlideTransition(
                        position: _animation3,
                        child: Image.asset('images/logo/logo_left_bottom.png')//Text('animation3', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: SlideTransition(
                        position: _animation4,
                        child:Image.asset('images/logo/logo_left_top.png') //Text('animation1', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Positioned(
                    left: 100,
                    right: 100,
                    bottom: 150,
                    child: FadeTransition(
                      opacity: _animation5,
                      child: Text('오또칼렌',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                    ),
                  ),

                ],
              )
          )
      ),
    );
  }
}