import 'dart:math';
import 'package:flutter/material.dart';

class ShakeWidget extends StatefulWidget {
  final Widget child;
  final Duration shakeDuration;
  final double shakeOffset;
  final int shakeCount;
  final ValueNotifier<bool>? shakeTrigger;

  const ShakeWidget({
    super.key,
    required this.child,
    this.shakeDuration = const Duration(milliseconds: 500),
    this.shakeOffset = 10,
    this.shakeCount = 3,
    this.shakeTrigger,
  });

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
       vsync: this, duration: widget.shakeDuration);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: _ShakeCurve(count: widget.shakeCount),
      ),
    );

    widget.shakeTrigger?.addListener(_onShakeRequested);
  }

  void _onShakeRequested() {
    if (widget.shakeTrigger?.value == true) {
      _animationController.forward(from: 0.0);
      // Reset trigger automatically after playing so it can fire again
      Future.delayed(widget.shakeDuration, () {
        if(mounted && widget.shakeTrigger != null) {
           widget.shakeTrigger!.value = false;
        }
      });
    }
  }

  @override
  void dispose() {
    widget.shakeTrigger?.removeListener(_onShakeRequested);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(sin(_animation.value * pi) * widget.shakeOffset, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _ShakeCurve extends Curve {
  final int count;
  const _ShakeCurve({this.count = 3});

  @override
  double transformInternal(double t) {
    // Oscillation based on count
    return sin(count * 2 * pi * t);
  }
}
