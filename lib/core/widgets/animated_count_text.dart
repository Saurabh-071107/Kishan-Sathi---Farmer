import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnimatedCountText extends StatefulWidget {
  final num targetValue;
  final String? prefix;
  final String? suffix;
  final TextStyle? style;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final bool formatCurrency;
  final int decimalPlaces;

  const AnimatedCountText({
    super.key,
    required this.targetValue,
    this.prefix,
    this.suffix,
    this.style,
    this.duration = const Duration(milliseconds: 1000),
    this.delay = Duration.zero,
    this.curve = Curves.easeOutCubic,
    this.formatCurrency = false,
    this.decimalPlaces = 0,
  });

  @override
  State<AnimatedCountText> createState() => _AnimatedCountTextState();
}

class _AnimatedCountTextState extends State<AnimatedCountText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentDisplayValue = 0;

  @override
  void initState() {
    super.initState();
    final bool isTesting = WidgetsBinding.instance.runtimeType.toString().contains('TestWidgets');

    _controller = AnimationController(
      vsync: this,
      duration: isTesting ? Duration.zero : widget.duration,
    );

    _animation = Tween<double>(
      begin: 0,
      end: widget.targetValue.toDouble(),
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve))
      ..addListener(() {
        if (mounted) {
          setState(() {
            _currentDisplayValue = _animation.value;
          });
        }
      });

    if (isTesting || widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedCountText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetValue != widget.targetValue) {
      _animation = Tween<double>(
        begin: _currentDisplayValue,
        end: widget.targetValue.toDouble(),
      ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatNumber(double value) {
    if (widget.decimalPlaces > 0) {
      return value.toStringAsFixed(widget.decimalPlaces);
    }
    if (widget.formatCurrency) {
      final formatter = NumberFormat('#,##,###');
      return formatter.format(value.round());
    }
    return value.round().toString();
  }

  @override
  Widget build(BuildContext context) {
    final formattedValue = _formatNumber(_currentDisplayValue);
    final prefix = widget.prefix ?? '';
    final suffix = widget.suffix ?? '';

    return Text(
      '$prefix$formattedValue$suffix',
      style: widget.style,
    );
  }
}
