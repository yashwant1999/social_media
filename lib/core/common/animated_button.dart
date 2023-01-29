// import 'package:flutter/material.dart';

// class AnimatedButton extends StatefulWidget {
//   final Widget child;
//   final VoidCallback onTap;
//   const AnimatedButton({Key? key, required this.child, required this.onTap})
//       : super(key: key);

//   @override
//   // ignore: library_private_types_in_public_api
//   _AnimatedButtonState createState() => _AnimatedButtonState();
// }

// class _AnimatedButtonState extends State<AnimatedButton>
//     with SingleTickerProviderStateMixin {
//   /// Track the scaling.
//   late double _scale;

//   late AnimationController _animationController;

//   /// Intilize the animation controller in init State
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 100),
//       lowerBound: 0.0,
//       upperBound: 0.1,
//     )..addListener(() {
//         setState(() {});
//       });
//   }

//   void _tapDown(TapDownDetails details) {
//     _animationController.forward();
//   }

//   void _tapUp(TapUpDetails details) {
//     _animationController.reverse();
//   }

//   /// Dispose the animaton Controller.
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     _scale = 1 - _animationController.value;
//     return GestureDetector(
//       onTap: widget.onTap,
//       onTapDown: _tapDown,
//       onTapUp: _tapUp,
//       child: Transform.scale(
//         scale: _scale,
//         child: widget.child,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class Bounceable2 extends StatefulWidget {
  /// Set it to `null` to disable `onTap`.
  final VoidCallback? onTap;
  final void Function(TapUpDetails)? onTapUp;
  final void Function(TapDownDetails)? onTapDown;
  final VoidCallback? onTapCancel;

  /// The reverse duration of the scaling animation when `onTapUp`.
  final Duration? duration;

  /// The duration of the scaling animation when `onTapDown`.
  final Duration? reverseDuration;

  /// The reverse curve of the scaling animation when `onTapUp`.
  final Curve curve;

  /// The curve of the scaling animation when `onTapDown`..
  final Curve? reverseCurve;

  /// The scale factor of the child widget. The valid range of `scaleFactor` is from `0.0` to `1.0`.
  final double scaleFactor;

  /// How the internal gesture detector should behave during hit testing.
  final HitTestBehavior? hitTestBehavior;

  final Widget child;

  const Bounceable2({
    Key? key,
    required this.onTap,
    required this.child,
    this.onTapUp,
    this.onTapDown,
    this.onTapCancel,
    this.duration = const Duration(milliseconds: 200),
    this.reverseDuration = const Duration(milliseconds: 100),
    this.curve = Curves.decelerate,
    this.reverseCurve = Curves.decelerate,
    this.scaleFactor = 0.8,
    this.hitTestBehavior,
  })  : assert(
          scaleFactor >= 0.0 && scaleFactor <= 1.0,
          "The valid range of scaleFactor is from 0.0 to 1.0.",
        ),
        super(key: key);

  @override
  Bounceable2State createState() => Bounceable2State();
}

class Bounceable2State extends State<Bounceable2>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: widget.reverseDuration,
      value: 1.0,
      upperBound: 1.0,
      lowerBound: widget.scaleFactor,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
      reverseCurve: widget.reverseCurve,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
  }

  /// modification done by me. So when user tap the forward animation show and then if onTap has any function
  /// then it get triggered if not then show the reverse aniamtion.
  /// The other workaround i can think of is -->
  ///
  /// ```
  /// void _onTap() {
  ///   _controller.reverse().then((_){
  ///   if(widget.onTap!= null) widget.onTap!();
  ///   _controller.forward();
  ///   });
  /// }
  void _onTap() async {
    // _controller.reverse().then((_) {
    //   _controller.forward();
    //   if (widget.onTap != null) widget.onTap!();
    // });

    await _controller.reverse();
    await _controller.forward();
    if (widget.onTap != null) widget.onTap!();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTapUp != null) widget.onTapUp!(details);
    _controller.forward();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTapDown != null) widget.onTapDown!(details);
    _controller.reverse();
  }

  void _onTapCancel() {
    if (widget.onTapCancel != null) widget.onTapCancel!();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: widget.hitTestBehavior,
        onTapCancel: widget.onTap != null ? _onTapCancel : null,
        onTapDown: widget.onTap != null ? _onTapDown : null,
        onTapUp: widget.onTap != null ? _onTapUp : null,
        onTap: widget.onTap != null ? _onTap : null,
        child: ScaleTransition(
          scale: _animation,
          child: widget.child,
        ),
      ),
    );
  }
}
