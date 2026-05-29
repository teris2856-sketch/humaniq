import 'package:flutter/material.dart';

/// Lateral (sagittal) figure — same translucent x-ray language as [BodyFacingPainter].
/// Anterior (+x) faces right before [mirror] flip. Arm and leg read in profile (side-on).
class BodySideProfilePainter extends CustomPainter {
  final bool mirror;

  const BodySideProfilePainter({this.mirror = false});

  /// Matches [BodyFacingPainter] front head: slightly larger circular head.
  static const double _headCenterY = 0.055;
  static const double _headRadiusY = 0.045;
  static const double _neckBaseY = 0.19;

  /// Circular head (profile).
  static Path _headPath(double w, double h) {
    final cx = 0.48 * w;
    final cy = h * _headCenterY;
    final r = h * _headRadiusY;
    return Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));
  }

  /// Small triangular neck — much narrower than the head.
  static Path _neckPath(double w, double h) {
    final cx = 0.48 * w;
    final headBottom = h * (_headCenterY + _headRadiusY);
    final baseY = h * _neckBaseY;
    final neckHalf = w * 0.022;
    return Path()
      ..moveTo(cx, headBottom)
      ..lineTo(cx - neckHalf, baseY)
      ..lineTo(cx + neckHalf * 1.15, baseY)
      ..close();
  }

  /// Torso, arm, and leg — from shoulder height downward (feet ≈ 96% like front/back).
  static Path _bodyOutline(double w, double h) {
    final p = Path();
    // Posterior shoulder
    p.moveTo(0.24 * w, 0.16 * h);
    p.cubicTo(0.20 * w, 0.18 * h, 0.17 * w, 0.22 * h, 0.18 * w, 0.26 * h);
    // Arm profile
    p.cubicTo(0.22 * w, 0.32 * h, 0.32 * w, 0.34 * h, 0.42 * w, 0.38 * h);
    p.cubicTo(0.46 * w, 0.41 * h, 0.44 * w, 0.44 * h, 0.38 * w, 0.43 * h);
    // Waist (posterior)
    p.cubicTo(0.28 * w, 0.40 * h, 0.24 * w, 0.37 * h, 0.23 * w, 0.33 * h);
    // Glute → posterior thigh
    p.cubicTo(0.21 * w, 0.39 * h, 0.20 * w, 0.47 * h, 0.22 * w, 0.57 * h);
    // Calf (posterior)
    p.cubicTo(0.21 * w, 0.65 * h, 0.22 * w, 0.71 * h, 0.26 * w, 0.75 * h);
    // Heel
    p.cubicTo(0.24 * w, 0.90 * h, 0.28 * w, 0.93 * h, 0.34 * w, 0.92 * h);
    // Toes (anterior foot)
    p.cubicTo(0.50 * w, 0.96 * h, 0.62 * w, 0.94 * h, 0.64 * w, 0.91 * h);
    p.cubicTo(0.66 * w, 0.87 * h, 0.58 * w, 0.85 * h, 0.50 * w, 0.85 * h);
    // Shin + knee (anterior)
    p.cubicTo(0.44 * w, 0.85 * h, 0.40 * w, 0.81 * h, 0.38 * w, 0.77 * h);
    p.cubicTo(0.40 * w, 0.60 * h, 0.44 * w, 0.54 * h, 0.48 * w, 0.48 * h);
    // Anterior hip / abdomen / chest
    p.cubicTo(0.54 * w, 0.42 * h, 0.58 * w, 0.36 * h, 0.56 * w, 0.30 * h);
    p.cubicTo(0.58 * w, 0.24 * h, 0.54 * w, 0.20 * h, 0.50 * w, 0.18 * h);
    // Anterior neck base
    p.lineTo(0.50 * w, 0.19 * h);
    p.cubicTo(0.46 * w, 0.13 * h, 0.30 * w, 0.14 * h, 0.24 * w, 0.16 * h);
    p.close();
    return p;
  }

  static Path _fullSilhouette(double w, double h) {
    return Path()
      ..addPath(_headPath(w, h), Offset.zero)
      ..addPath(_neckPath(w, h), Offset.zero)
      ..addPath(_bodyOutline(w, h), Offset.zero);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.save();
    if (mirror) {
      canvas.translate(w, 0);
      canvas.scale(-1, 1);
    }

    const rim = Color(0xFF6ED4FF);
    const shell = Color(0x3838B0E8);
    const line = Color(0xDD5DB8E8);

    final outerGlowPaint = Paint()
      ..color = rim.withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final glowPaint = Paint()
      ..color = rim.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final bodyPaint = Paint()
      ..color = line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = shell
      ..style = PaintingStyle.fill;

    final internalPaint = Paint()
      ..color = const Color(0xAA7AB8D4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    final internalGlowPaint = Paint()
      ..color = const Color(0x1269C8E8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

    final limbPaint = Paint()
      ..color = const Color(0xDD5DB8E8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final jointPaint = Paint()
      ..color = const Color(0xDD8AD4F0)
      ..style = PaintingStyle.fill;

    final jointGlowPaint = Paint()
      ..color = const Color(0x0CFFFFFF)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

    final head = _headPath(w, h);
    final neck = _neckPath(w, h);
    final silhouette = _fullSilhouette(w, h);

    canvas.drawPath(silhouette, outerGlowPaint);
    canvas.drawPath(silhouette, glowPaint);
    canvas.drawPath(silhouette, fillPaint);
    canvas.drawPath(silhouette, bodyPaint);

    // Head + neck outlines (clear circle and triangle)
    canvas.drawPath(head, bodyPaint);
    canvas.drawPath(neck, bodyPaint);

    // Nose / chin hint on head (profile)
    final faceHint = Path()
      ..moveTo(0.54 * w, h * 0.042)
      ..quadraticBezierTo(0.62 * w, h * 0.048, 0.66 * w, h * 0.062);
    canvas.drawPath(faceHint, internalGlowPaint);
    canvas.drawPath(faceHint, internalPaint);

    // Sagittal spine (posterior)
    final spine = Path()
      ..moveTo(0.22 * w, 0.20 * h)
      ..cubicTo(0.205 * w, 0.30 * h, 0.20 * w, 0.42 * h, 0.22 * w, 0.54 * h);
    for (var y = 0.24; y <= 0.50; y += 0.04) {
      spine
        ..moveTo(0.208 * w, h * y)
        ..lineTo(0.228 * w, h * y);
    }
    canvas.drawPath(spine, internalGlowPaint);
    canvas.drawPath(spine, internalPaint);

    // Sternum — anterior vertical
    final sternum = Path()
      ..moveTo(0.54 * w, 0.32 * h)
      ..lineTo(0.52 * w, 0.48 * h);
    canvas.drawPath(sternum, internalGlowPaint);
    canvas.drawPath(sternum, internalPaint);

    // Arm profile
    final armProfile = Path()
      ..moveTo(0.24 * w, 0.34 * h)
      ..cubicTo(0.20 * w, 0.38 * h, 0.18 * w, 0.42 * h, 0.20 * w, 0.46 * h)
      ..cubicTo(0.24 * w, 0.50 * h, 0.32 * w, 0.50 * h, 0.40 * w, 0.52 * h)
      ..cubicTo(0.44 * w, 0.54 * h, 0.46 * w, 0.57 * h, 0.44 * w, 0.59 * h);
    canvas.drawPath(armProfile, internalGlowPaint);
    canvas.drawPath(armProfile, limbPaint);

    // Leg profile
    final legProfile = Path()
      ..moveTo(0.24 * w, 0.60 * h)
      ..cubicTo(0.22 * w, 0.68 * h, 0.24 * w, 0.76 * h, 0.32 * w, 0.80 * h)
      ..cubicTo(0.38 * w, 0.82 * h, 0.40 * w, 0.86 * h, 0.38 * w, 0.90 * h)
      ..cubicTo(0.50 * w, 0.94 * h, 0.58 * w, 0.94 * h, 0.60 * w, 0.92 * h);
    canvas.drawPath(legProfile, internalGlowPaint);
    canvas.drawPath(legProfile, limbPaint);

    // Patella
    final patella = Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(0.36 * w, 0.808 * h),
          width: w * 0.07,
          height: h * 0.032,
        ),
      );
    canvas.drawPath(patella, internalGlowPaint);
    canvas.drawPath(patella, internalPaint);

    // Ribs
    final ribs = Path()
      ..moveTo(0.52 * w, 0.34 * h)
      ..quadraticBezierTo(0.44 * w, 0.36 * h, 0.36 * w, 0.38 * h)
      ..moveTo(0.52 * w, 0.38 * h)
      ..quadraticBezierTo(0.44 * w, 0.40 * h, 0.36 * w, 0.42 * h);
    canvas.drawPath(ribs, internalGlowPaint);
    canvas.drawPath(ribs, internalPaint);

    final headCx = 0.48 * w;
    final headCy = h * _headCenterY;
    final joints = [
      Offset(headCx, headCy - h * _headRadiusY),
      Offset(headCx, headCy),
      Offset(0.48 * w, h * _neckBaseY),
      Offset(0.24 * w, 0.34 * h),
      Offset(0.20 * w, 0.44 * h),
      Offset(0.44 * w, 0.56 * h),
      Offset(0.36 * w, 0.808 * h),
      Offset(0.38 * w, 0.90 * h),
      Offset(0.58 * w, 0.92 * h),
    ];
    for (final j in joints) {
      canvas.drawCircle(j, 5, jointGlowPaint);
      canvas.drawCircle(j, 3, jointPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BodySideProfilePainter oldDelegate) {
    return oldDelegate.mirror != mirror;
  }
}
