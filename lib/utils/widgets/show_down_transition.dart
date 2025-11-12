import 'dart:async';
import 'package:flutter/material.dart';

class ShowDownTransition extends StatefulWidget {
  final Widget child;
  final int delay;

  const ShowDownTransition({Key? key, required this.child, required this.delay}) : super(key: key);

  @override
  _ShowDownTransitionState createState() => _ShowDownTransitionState();
}

class _ShowDownTransitionState extends State<ShowDownTransition> with TickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _animOffset;

  @override
  void initState() {
    super.initState();

    _animController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    final curve =
    CurvedAnimation(curve: Curves.decelerate, parent: _animController);
    _animOffset =
        Tween<Offset>(begin: Offset.zero, end:const Offset(0.0, 0.25))
            .animate(curve);

    if (widget.delay == null) {
      _animController.forward();
    } else {
      Timer(Duration(milliseconds: widget.delay), () {
        if(mounted){
        _animController.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      child: SlideTransition(
        position: _animOffset,
        child: widget.child,
      ),
      opacity: _animController,
    );

  }
}