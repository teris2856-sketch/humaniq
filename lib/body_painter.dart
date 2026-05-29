import 'package:flutter/material.dart';

/// Front or back anatomy — translucent hologram-style figure on a dark navy scene.
class BodyFacingPainter extends CustomPainter {
  final bool isBack;

  const BodyFacingPainter({required this.isBack});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    const rim = Color(0xFF6ED4FF);
    const shell = Color(0x3838B0E8);
    const line = Color(0xDD5DB8E8);

    final outerGlowPaint = Paint()
      ..color = rim.withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final glowPaint = Paint()
      ..color = rim.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final bodyPaint = Paint()
      ..color = line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final bodyFillPaint = Paint()
      ..color = shell
      ..style = PaintingStyle.fill;

    final internalPaint = Paint()
      ..color = Color(0xAA7AB8D4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.05
      ..strokeCap = StrokeCap.round;

    final internalGlowPaint = Paint()
      ..color = const Color(0x1269C8E8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

    final jointPaint = Paint()
      ..color = const Color(0xDD8AD4F0)
      ..style = PaintingStyle.fill;

    final jointGlowPaint = Paint()
      ..color = const Color(0x0CFFFFFF)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

    if (isBack) {
      _drawBackBody(
        canvas,
        w,
        h,
        outerGlowPaint,
        glowPaint,
        bodyPaint,
        bodyFillPaint,
        internalPaint,
        internalGlowPaint,
        jointPaint,
        jointGlowPaint,
      );
    } else {
      _drawFrontBody(
        canvas,
        w,
        h,
        outerGlowPaint,
        glowPaint,
        bodyPaint,
        bodyFillPaint,
        internalPaint,
        internalGlowPaint,
        jointPaint,
        jointGlowPaint,
      );
    }
  }

  void _drawFrontBody(
    Canvas canvas,
    double w,
    double h,
    Paint outerGlow,
    Paint glow,
    Paint body,
    Paint fill,
    Paint internal,
    Paint internalGlow,
    Paint joint,
    Paint jointGlow,
  ) {
    final cx = w * 0.5;

    final headPath = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(cx, h * 0.055),
          radius: h * 0.045,
        ),
      );

    final neckPath = Path()
      ..moveTo(cx - w * 0.04, h * 0.06)
      ..lineTo(cx - w * 0.045, h * 0.19)
      ..moveTo(cx + w * 0.04, h * 0.06)
      ..lineTo(cx + w * 0.045, h * 0.19);

    final torsoPath = Path()
      ..moveTo(cx - w * 0.045, h * 0.19)
      ..cubicTo(cx - w * 0.08, h * 0.125, cx - w * 0.22, h * 0.135, cx - w * 0.28,
          h * 0.155)
      ..cubicTo(cx - w * 0.32, h * 0.16, cx - w * 0.32, h * 0.175, cx - w * 0.28,
          h * 0.18)
      ..cubicTo(cx - w * 0.24, h * 0.19, cx - w * 0.20, h * 0.22, cx - w * 0.19,
          h * 0.28)
      ..cubicTo(cx - w * 0.17, h * 0.34, cx - w * 0.17, h * 0.38, cx - w * 0.19,
          h * 0.42)
      ..cubicTo(cx - w * 0.21, h * 0.44, cx - w * 0.20, h * 0.46, cx - w * 0.17,
          h * 0.47)
      ..cubicTo(cx - w * 0.12, h * 0.485, cx - w * 0.04, h * 0.49, cx, h * 0.49)
      ..cubicTo(cx + w * 0.04, h * 0.49, cx + w * 0.12, h * 0.485, cx + w * 0.17,
          h * 0.47)
      ..cubicTo(cx + w * 0.20, h * 0.46, cx + w * 0.21, h * 0.44, cx + w * 0.19,
          h * 0.42)
      ..cubicTo(cx + w * 0.17, h * 0.38, cx + w * 0.17, h * 0.34, cx + w * 0.19,
          h * 0.28)
      ..cubicTo(cx + w * 0.20, h * 0.22, cx + w * 0.24, h * 0.19, cx + w * 0.28,
          h * 0.18)
      ..cubicTo(cx + w * 0.32, h * 0.175, cx + w * 0.32, h * 0.16, cx + w * 0.28,
          h * 0.155)
      ..cubicTo(cx + w * 0.22, h * 0.135, cx + w * 0.08, h * 0.125, cx + w * 0.045,
          h * 0.16);

    final leftArmPath = Path()
      ..moveTo(cx - w * 0.28, h * 0.18)
      ..cubicTo(cx - w * 0.30, h * 0.22, cx - w * 0.32, h * 0.28, cx - w * 0.33,
          h * 0.32)
      ..cubicTo(cx - w * 0.34, h * 0.36, cx - w * 0.35, h * 0.38, cx - w * 0.36,
          h * 0.40)
      ..cubicTo(cx - w * 0.37, h * 0.42, cx - w * 0.38, h * 0.44, cx - w * 0.39,
          h * 0.46)
      ..cubicTo(cx - w * 0.40, h * 0.475, cx - w * 0.41, h * 0.49, cx - w * 0.40,
          h * 0.50)
      ..cubicTo(cx - w * 0.39, h * 0.51, cx - w * 0.37, h * 0.50, cx - w * 0.36,
          h * 0.49);

    final leftArmInnerPath = Path()
      ..moveTo(cx - w * 0.24, h * 0.19)
      ..cubicTo(cx - w * 0.26, h * 0.24, cx - w * 0.28, h * 0.30, cx - w * 0.29,
          h * 0.34)
      ..cubicTo(cx - w * 0.30, h * 0.38, cx - w * 0.31, h * 0.40, cx - w * 0.32,
          h * 0.42)
      ..cubicTo(cx - w * 0.33, h * 0.44, cx - w * 0.34, h * 0.46, cx - w * 0.35,
          h * 0.48)
      ..cubicTo(cx - w * 0.36, h * 0.49, cx - w * 0.37, h * 0.50, cx - w * 0.36,
          h * 0.49);

    final rightArmPath = Path()
      ..moveTo(cx + w * 0.28, h * 0.18)
      ..cubicTo(cx + w * 0.30, h * 0.22, cx + w * 0.32, h * 0.28, cx + w * 0.33,
          h * 0.32)
      ..cubicTo(cx + w * 0.34, h * 0.36, cx + w * 0.35, h * 0.38, cx + w * 0.36,
          h * 0.40)
      ..cubicTo(cx + w * 0.37, h * 0.42, cx + w * 0.38, h * 0.44, cx + w * 0.39,
          h * 0.46)
      ..cubicTo(cx + w * 0.40, h * 0.475, cx + w * 0.41, h * 0.49, cx + w * 0.40,
          h * 0.50)
      ..cubicTo(cx + w * 0.39, h * 0.51, cx + w * 0.37, h * 0.50, cx + w * 0.36,
          h * 0.49);

    final rightArmInnerPath = Path()
      ..moveTo(cx + w * 0.24, h * 0.19)
      ..cubicTo(cx + w * 0.26, h * 0.24, cx + w * 0.28, h * 0.30, cx + w * 0.29,
          h * 0.34)
      ..cubicTo(cx + w * 0.30, h * 0.38, cx + w * 0.31, h * 0.40, cx + w * 0.32,
          h * 0.42)
      ..cubicTo(cx + w * 0.33, h * 0.44, cx + w * 0.34, h * 0.46, cx + w * 0.35,
          h * 0.48);

    final leftLegOuterPath = Path()
      ..moveTo(cx - w * 0.17, h * 0.47)
      ..cubicTo(cx - w * 0.18, h * 0.52, cx - w * 0.17, h * 0.58, cx - w * 0.16,
          h * 0.64)
      ..cubicTo(cx - w * 0.15, h * 0.70, cx - w * 0.14, h * 0.74, cx - w * 0.14,
          h * 0.78)
      ..cubicTo(cx - w * 0.13, h * 0.84, cx - w * 0.13, h * 0.88, cx - w * 0.14,
          h * 0.92)
      ..cubicTo(cx - w * 0.15, h * 0.95, cx - w * 0.16, h * 0.965, cx - w * 0.18,
          h * 0.97);

    final leftLegInnerPath = Path()
      ..moveTo(cx - w * 0.04, h * 0.49)
      ..cubicTo(cx - w * 0.06, h * 0.52, cx - w * 0.08, h * 0.58, cx - w * 0.09,
          h * 0.64)
      ..cubicTo(cx - w * 0.10, h * 0.70, cx - w * 0.10, h * 0.74, cx - w * 0.09,
          h * 0.78)
      ..cubicTo(cx - w * 0.09, h * 0.84, cx - w * 0.09, h * 0.88, cx - w * 0.10,
          h * 0.92)
      ..cubicTo(cx - w * 0.10, h * 0.95, cx - w * 0.10, h * 0.965, cx - w * 0.10,
          h * 0.97);

    final leftFootPath = Path()
      ..moveTo(cx - w * 0.18, h * 0.97)
      ..lineTo(cx - w * 0.10, h * 0.97);

    final rightLegOuterPath = Path()
      ..moveTo(cx + w * 0.17, h * 0.47)
      ..cubicTo(cx + w * 0.18, h * 0.52, cx + w * 0.17, h * 0.58, cx + w * 0.16,
          h * 0.64)
      ..cubicTo(cx + w * 0.15, h * 0.70, cx + w * 0.14, h * 0.74, cx + w * 0.14,
          h * 0.78)
      ..cubicTo(cx + w * 0.13, h * 0.84, cx + w * 0.13, h * 0.88, cx + w * 0.14,
          h * 0.92)
      ..cubicTo(cx + w * 0.15, h * 0.95, cx + w * 0.16, h * 0.965, cx + w * 0.18,
          h * 0.97);

    final rightLegInnerPath = Path()
      ..moveTo(cx + w * 0.04, h * 0.49)
      ..cubicTo(cx + w * 0.06, h * 0.52, cx + w * 0.08, h * 0.58, cx + w * 0.09,
          h * 0.64)
      ..cubicTo(cx + w * 0.10, h * 0.70, cx + w * 0.10, h * 0.74, cx + w * 0.09,
          h * 0.78)
      ..cubicTo(cx + w * 0.09, h * 0.84, cx + w * 0.09, h * 0.88, cx + w * 0.10,
          h * 0.92)
      ..cubicTo(cx + w * 0.10, h * 0.95, cx + w * 0.10, h * 0.965, cx + w * 0.10,
          h * 0.97);

    final rightFootPath = Path()
      ..moveTo(cx + w * 0.18, h * 0.97)
      ..lineTo(cx + w * 0.10, h * 0.97);

    final ribPath = Path()
      ..moveTo(cx - w * 0.04, h * 0.13)
      ..cubicTo(cx - w * 0.10, h * 0.135, cx - w * 0.18, h * 0.14, cx - w * 0.22,
          h * 0.155)
      ..moveTo(cx + w * 0.04, h * 0.13)
      ..cubicTo(cx + w * 0.10, h * 0.135, cx + w * 0.18, h * 0.14, cx + w * 0.22,
          h * 0.155)
      ..moveTo(cx, h * 0.14)
      ..lineTo(cx, h * 0.30);

    for (double i = 0.17; i <= 0.28; i += 0.028) {
      ribPath
        ..moveTo(cx - w * 0.01, h * i)
        ..cubicTo(cx - w * 0.06, h * (i + 0.005), cx - w * 0.10, h * (i + 0.015),
            cx - w * 0.14, h * (i + 0.02))
        ..moveTo(cx + w * 0.01, h * i)
        ..cubicTo(cx + w * 0.06, h * (i + 0.005), cx + w * 0.10, h * (i + 0.015),
            cx + w * 0.14, h * (i + 0.02));
    }

    final absPath = Path()
      ..moveTo(cx, h * 0.30)
      ..lineTo(cx, h * 0.44)
      ..moveTo(cx - w * 0.06, h * 0.32)
      ..lineTo(cx + w * 0.06, h * 0.32)
      ..moveTo(cx - w * 0.06, h * 0.35)
      ..lineTo(cx + w * 0.06, h * 0.35)
      ..moveTo(cx - w * 0.05, h * 0.38)
      ..lineTo(cx + w * 0.05, h * 0.38)
      ..moveTo(cx - w * 0.04, h * 0.41)
      ..lineTo(cx + w * 0.04, h * 0.41);

    final pelvisPath = Path()
      ..moveTo(cx - w * 0.16, h * 0.42)
      ..cubicTo(
          cx - w * 0.10, h * 0.45, cx - w * 0.04, h * 0.46, cx, h * 0.46)
      ..cubicTo(
          cx + w * 0.04, h * 0.46, cx + w * 0.10, h * 0.45, cx + w * 0.16, h * 0.42);

    final kneeCapPath = Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(cx - w * 0.12, h * 0.71),
          width: w * 0.05,
          height: h * 0.025,
        ),
      )
      ..addOval(
        Rect.fromCenter(
          center: Offset(cx + w * 0.12, h * 0.71),
          width: w * 0.05,
          height: h * 0.025,
        ),
      );

    final allPaths = [
      headPath,
      neckPath,
      torsoPath,
      leftArmPath,
      leftArmInnerPath,
      rightArmPath,
      rightArmInnerPath,
      leftLegOuterPath,
      leftLegInnerPath,
      leftFootPath,
      rightLegOuterPath,
      rightLegInnerPath,
      rightFootPath,
    ];

    for (final path in allPaths) {
      canvas.drawPath(path, outerGlow);
      canvas.drawPath(path, glow);
    }
    canvas.drawPath(torsoPath, fill);
    canvas.drawPath(headPath, fill);
    for (final path in allPaths) {
      canvas.drawPath(path, body);
    }

    final internalPaths = [ribPath, absPath, pelvisPath, kneeCapPath];
    for (final path in internalPaths) {
      canvas.drawPath(path, internalGlow);
      canvas.drawPath(path, internal);
    }

    // X-ray style: nerves (yellow–green) and vessels (artery red / vein blue)
    final nervePaint = Paint()
      ..color = const Color(0xAA9AE6B0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.85
      ..strokeCap = StrokeCap.round;
    final arteryPaint = Paint()
      ..color = const Color(0xCCFF6B6B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..strokeCap = StrokeCap.round;
    final veinPaint = Paint()
      ..color = const Color(0xCC6BA3FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.05
      ..strokeCap = StrokeCap.round;
    final skullPaint = Paint()
      ..color = const Color(0x55E0F2FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawPath(
      Path()
        ..addOval(
          Rect.fromCenter(
            center: Offset(cx, h * 0.048),
            width: w * 0.11,
            height: h * 0.055,
          ),
        ),
      skullPaint,
    );

    final nerves = Path()
      ..moveTo(cx, h * 0.095)
      ..quadraticBezierTo(cx - w * 0.06, h * 0.14, cx - w * 0.18, h * 0.18)
      ..moveTo(cx, h * 0.095)
      ..quadraticBezierTo(cx + w * 0.06, h * 0.14, cx + w * 0.18, h * 0.18)
      ..moveTo(cx, h * 0.10)
      ..lineTo(cx, h * 0.22)
      ..moveTo(cx - w * 0.02, h * 0.12)
      ..quadraticBezierTo(cx - w * 0.12, h * 0.20, cx - w * 0.22, h * 0.26)
      ..moveTo(cx + w * 0.02, h * 0.12)
      ..quadraticBezierTo(cx + w * 0.12, h * 0.20, cx + w * 0.22, h * 0.26);
    canvas.drawPath(nerves, nervePaint);

    final heart = Offset(cx, h * 0.248);
    final vessels = Path()
      ..moveTo(heart.dx, heart.dy)
      ..quadraticBezierTo(cx - w * 0.06, h * 0.21, cx - w * 0.24, h * 0.165)
      ..moveTo(heart.dx, heart.dy)
      ..quadraticBezierTo(cx + w * 0.06, h * 0.21, cx + w * 0.24, h * 0.165)
      ..moveTo(heart.dx, heart.dy + 2)
      ..lineTo(cx, h * 0.34)
      ..cubicTo(
        cx - w * 0.02,
        h * 0.42,
        cx - w * 0.06,
        h * 0.48,
        cx - w * 0.10,
        h * 0.52,
      )
      ..moveTo(heart.dx, heart.dy + 2)
      ..lineTo(cx, h * 0.34)
      ..cubicTo(
        cx + w * 0.02,
        h * 0.42,
        cx + w * 0.06,
        h * 0.48,
        cx + w * 0.10,
        h * 0.52,
      );
    canvas.drawPath(vessels, arteryPaint);
    final veinsDeep = Path()
      ..moveTo(cx + w * 0.03, h * 0.30)
      ..quadraticBezierTo(cx + w * 0.14, h * 0.36, cx + w * 0.20, h * 0.44)
      ..moveTo(cx - w * 0.03, h * 0.30)
      ..quadraticBezierTo(cx - w * 0.14, h * 0.36, cx - w * 0.20, h * 0.44);
    canvas.drawPath(veinsDeep, veinPaint);

    final joints = [
      Offset(cx - w * 0.28, h * 0.155),
      Offset(cx + w * 0.28, h * 0.155),
      Offset(cx - w * 0.33, h * 0.32),
      Offset(cx + w * 0.33, h * 0.32),
      Offset(cx - w * 0.39, h * 0.46),
      Offset(cx + w * 0.39, h * 0.46),
      Offset(cx - w * 0.19, h * 0.42),
      Offset(cx + w * 0.19, h * 0.42),
      Offset(cx - w * 0.12, h * 0.71),
      Offset(cx + w * 0.12, h * 0.71),
      Offset(cx - w * 0.13, h * 0.92),
      Offset(cx + w * 0.13, h * 0.92),
    ];

    for (final j in joints) {
      canvas.drawCircle(j, 5, jointGlow);
      canvas.drawCircle(j, 3, joint);
    }
  }

  void _drawBackBody(
    Canvas canvas,
    double w,
    double h,
    Paint outerGlow,
    Paint glow,
    Paint body,
    Paint fill,
    Paint internal,
    Paint internalGlow,
    Paint joint,
    Paint jointGlow,
  ) {
    _drawFrontBody(
      canvas,
      w,
      h,
      outerGlow,
      glow,
      body,
      fill,
      internal,
      internalGlow,
      joint,
      jointGlow,
    );

    final cx = w * 0.5;
    final spinePath = Path()
      ..moveTo(cx, h * 0.09)
      ..lineTo(cx, h * 0.44);
    for (double i = 0.10; i <= 0.43; i += 0.02) {
      spinePath
        ..moveTo(cx - w * 0.015, h * i)
        ..lineTo(cx + w * 0.015, h * i);
    }

    final scapulaPath = Path()
      ..moveTo(cx - w * 0.06, h * 0.16)
      ..cubicTo(cx - w * 0.10, h * 0.17, cx - w * 0.14, h * 0.20, cx - w * 0.15,
          h * 0.24)
      ..cubicTo(cx - w * 0.14, h * 0.27, cx - w * 0.10, h * 0.28, cx - w * 0.06,
          h * 0.27)
      ..cubicTo(cx - w * 0.04, h * 0.24, cx - w * 0.04, h * 0.20, cx - w * 0.06,
          h * 0.16)
      ..moveTo(cx + w * 0.06, h * 0.16)
      ..cubicTo(cx + w * 0.10, h * 0.17, cx + w * 0.14, h * 0.20, cx + w * 0.15,
          h * 0.24)
      ..cubicTo(cx + w * 0.14, h * 0.27, cx + w * 0.10, h * 0.28, cx + w * 0.06,
          h * 0.27)
      ..cubicTo(cx + w * 0.04, h * 0.24, cx + w * 0.04, h * 0.20, cx + w * 0.06,
          h * 0.16);

    final sacralPath = Path()
      ..moveTo(cx - w * 0.12, h * 0.40)
      ..cubicTo(
          cx - w * 0.06, h * 0.43, cx, h * 0.445, cx, h * 0.445)
      ..cubicTo(cx, h * 0.445, cx + w * 0.06, h * 0.43, cx + w * 0.12, h * 0.40);

    final kneeBackPath = Path()
      ..moveTo(cx - w * 0.15, h * 0.70)
      ..cubicTo(
          cx - w * 0.13, h * 0.71, cx - w * 0.10, h * 0.71, cx - w * 0.09, h * 0.70)
      ..moveTo(cx + w * 0.15, h * 0.70)
      ..cubicTo(
          cx + w * 0.13, h * 0.71, cx + w * 0.10, h * 0.71, cx + w * 0.09, h * 0.70);

    for (final path in [spinePath, scapulaPath, sacralPath, kneeBackPath]) {
      canvas.drawPath(path, internalGlow);
      canvas.drawPath(path, internal);
    }
  }

  @override
  bool shouldRepaint(covariant BodyFacingPainter oldDelegate) {
    return oldDelegate.isBack != isBack;
  }
}
