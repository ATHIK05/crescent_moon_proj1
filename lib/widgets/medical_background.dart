import 'dart:math';
import 'package:flutter/material.dart';

class MedicalBackground extends StatefulWidget {
  const MedicalBackground({super.key});

  @override
  State<MedicalBackground> createState() => _MedicalBackgroundState();
}

class _MedicalBackgroundState extends State<MedicalBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_FloatingIcon> _icons = [];

  @override
  void initState() {
    super.initState();
    final random = Random();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 20))
      ..repeat();

    for (int i = 0; i < 15; i++) {
      _icons.add(
        _FloatingIcon(
          icon: _getRandomIcon(random),
          size: 24 + random.nextInt(20).toDouble(),
          startX: random.nextDouble(),
          startY: random.nextDouble(),
          dx: (random.nextDouble() - 0.5) * 0.002,
          dy: (random.nextDouble() - 0.5) * 0.002,
          opacity: 0.04 + random.nextDouble() * 0.06,
        ),
      );
    }
  }

  IconData _getRandomIcon(Random random) {
    const icons = [
      Icons.medical_services,
      Icons.healing,
      Icons.local_hospital,
      Icons.vaccines,
      Icons.health_and_safety,
    ];
    return icons[random.nextInt(icons.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return CustomPaint(
          painter: _MedicalParticlePainter(_icons, _controller.value),
          size: MediaQuery.of(context).size,
        );
      },
    );
  }
}

class _FloatingIcon {
  final IconData icon;
  final double size;
  final double startX;
  final double startY;
  final double dx;
  final double dy;
  final double opacity;

  _FloatingIcon({
    required this.icon,
    required this.size,
    required this.startX,
    required this.startY,
    required this.dx,
    required this.dy,
    required this.opacity,
  });
}

class _MedicalParticlePainter extends CustomPainter {
  final List<_FloatingIcon> icons;
  final double animationValue;

  _MedicalParticlePainter(this.icons, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var iconData in icons) {
      final x = (iconData.startX + iconData.dx * animationValue * 1000) * size.width;
      final y = (iconData.startY + iconData.dy * animationValue * 1000) * size.height;

      final icon = TextSpan(
        text: String.fromCharCode(iconData.icon.codePoint),
        style: TextStyle(
          fontSize: iconData.size,
          fontFamily: iconData.icon.fontFamily,
          package: iconData.icon.fontPackage,
          color: Colors.blue.withOpacity(iconData.opacity),
        ),
      );

      textPainter.text = icon;
      textPainter.layout();
      textPainter.paint(canvas, Offset(x % size.width, y % size.height));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
