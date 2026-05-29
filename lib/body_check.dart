import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:swiftspeak/body_check_history.dart';
import 'package:swiftspeak/body_check_results.dart';
import 'package:swiftspeak/body_check_service.dart';
import 'package:swiftspeak/body_rotate_3d.dart';

enum PainLevel {
  none,
  low,
  moderate,
  high,
}

class BodyCheck extends StatefulWidget {
  const BodyCheck({super.key});

  @override
  State<BodyCheck> createState() => _BodyCheckState();
}

class _BodyCheckState extends State<BodyCheck> {
  final Map<String, PainLevel> _frontPainLevels = {};
  final Map<String, PainLevel> _backPainLevels = {};
  final Map<String, PainLevel> _sidePainLevels = {};
  final BodyCheckService _service = BodyCheckService();

  /// Yaw (radians) around vertical axis — horizontal drag only.
  double _rotationY = 0;

  final Map<String, Offset> _frontPainPointPositions = const {
    'Head': Offset(0.50, 0.04),
    'Neck': Offset(0.50, 0.13),
    'LeftShoulder': Offset(0.22, 0.16),
    'Right Shoulder': Offset(0.78, 0.16),
    'Chest': Offset(0.50, 0.24),
    'LeftElbow': Offset(0.17, 0.32),
    'RightElbow': Offset(0.83, 0.32),
    'LeftHand': Offset(0.11, 0.46),
    'RightHand': Offset(0.89, 0.46),
    'Stomach': Offset(0.50, 0.37),
    'spot9': Offset(0.50, 0.46),
    'LeftThigh': Offset(0.41, 0.58),
    'RightThigh': Offset(0.59, 0.58),
    'LeftKnee': Offset(0.38, 0.71),
    'RightKnee': Offset(0.62, 0.71),
    'LeftShin': Offset(0.36, 0.82),
    'RightShin': Offset(0.64, 0.82),
    'LeftFoot': Offset(0.33, 0.96),
    'RightFoot': Offset(0.67, 0.96),
  };
  final Map<String, Offset> _backPainPointPositions = const {
    'BackHead': Offset(0.50, 0.04),
    'BackNeck': Offset(0.50, 0.13),
    'BackLeftShoulder': Offset(0.22, 0.16),
    'BackRightShoulder': Offset(0.78, 0.16),
    'UpperBack': Offset(0.50, 0.24),
    'BackLeftElbow': Offset(0.17, 0.32),
    'BackRightElbow': Offset(0.83, 0.32),
    'BackLeftHand': Offset(0.11, 0.46),
    'BackRightHand': Offset(0.89, 0.46),
    'MidBack': Offset(0.50, 0.34),
    'LowerBack': Offset(0.50, 0.43),
    'BackLeftThigh': Offset(0.41, 0.58),
    'BackRightThigh': Offset(0.59, 0.58),
    'BackLeftKnee': Offset(0.38, 0.71),
    'BackRightKnee': Offset(0.62, 0.71),
    'BackLeftShin': Offset(0.36, 0.82),
    'BackRightShin': Offset(0.64, 0.82),
    'BackLeftFoot': Offset(0.33, 0.96),
    'BackRightFoot': Offset(0.67, 0.96),
  };

  static String _spotLabel(String id) {
    if (id == 'spot9') return 'Lower abdomen';
    var s = id;
    if (s.startsWith('Side')) s = s.substring(4);
    if (s.startsWith('Back')) s = s.substring(4);
    return s.replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}');
  }

  void _cyclePainLevel(String id, Map<String, PainLevel> levels) {
    final current = levels[id] ?? PainLevel.none;
    switch (current) {
      case PainLevel.none:
        levels[id] = PainLevel.low;
        break;
      case PainLevel.low:
        levels[id] = PainLevel.moderate;
        break;
      case PainLevel.moderate:
        levels[id] = PainLevel.high;
        break;
      case PainLevel.high:
        levels[id] = PainLevel.none;
        break;
    }
  }

  // Convert enum to int (0-3) for Firebase-friendly storage
  int _toInt(PainLevel level) {
    switch (level) {
      case PainLevel.none:
        return 0;
      case PainLevel.low:
        return 1;
      case PainLevel.moderate:
        return 2;
      case PainLevel.high:
        return 3;
    }
  }

  Map<String, int> _painToPayload(Map<String, PainLevel> source) {
    final out = <String, int>{};
    source.forEach((key, value) {
      final v = _toInt(value);
      if (v > 0) out[key] = v;
    });
    return out;
  }

  // Get color for a given pain level
  Color _colorForPain(PainLevel level) {
    switch (level) {
      case PainLevel.low:
        return Colors.green;
      case PainLevel.moderate:
        return Colors.yellow;
      case PainLevel.high:
        return Colors.red;
      case PainLevel.none:
        return const Color(0xFF4A5F70);
    }
  }

  Widget _buildFacePainButton(
    String id,
    Offset normalizedPosition,
    double w,
    double h,
    Map<String, PainLevel> levels, {
    double halfExtent = 17,
    bool showTooltip = false,
  }) {
    final level = levels[id] ?? PainLevel.none;
    final d = halfExtent * 2;
    final iconSize = (halfExtent * 0.94).clamp(12.0, 16.0);
    Widget markerVisual = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: d,
      height: d,
      decoration: BoxDecoration(
        color: _colorForPain(level).withValues(alpha: 0.9),
        shape: BoxShape.circle,
        border: Border.all(
          color: level == PainLevel.none ? Colors.white70 : Colors.white,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _colorForPain(level).withValues(alpha: 0.35),
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Icon(
        level == PainLevel.none ? Icons.add : Icons.check,
        size: iconSize,
        color: Colors.white,
      ),
    );
    if (showTooltip) {
      markerVisual = Tooltip(
        message: _spotLabel(id),
        waitDuration: const Duration(milliseconds: 400),
        child: markerVisual,
      );
    }
    return Positioned(
      left: normalizedPosition.dx * w - halfExtent,
      top: normalizedPosition.dy * h - halfExtent,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _cyclePainLevel(id, levels);
          });
        },
        child: Semantics(
          label: '${_spotLabel(id)} pain marker',
          button: true,
          child: markerVisual,
        ),
      ),
    );
  }

  Widget _painMarkersLayer({
    required Map<String, Offset> positions,
    required Map<String, PainLevel> levels,
    bool mirrorX = false,
    double markerHalfExtent = 17,
    bool showTooltips = false,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        return Stack(
          clipBehavior: Clip.none,
          fit: StackFit.expand,
          children: [
            for (final e in positions.entries)
              _buildFacePainButton(
                e.key,
                mirrorX ? Offset(1.0 - e.value.dx, e.value.dy) : e.value,
                w,
                h,
                levels,
                halfExtent: markerHalfExtent,
                showTooltip: showTooltips,
              ),
          ],
        );
      },
    );
  }

  Future<void> _submit() async {
    final frontPayload = _painToPayload(_frontPainLevels);
    final backPayload = _painToPayload(_backPainLevels);
    final sidePayload = _painToPayload(_sidePainLevels);
    try {
      final entryId = await _service.createEntry(
        frontPain: frontPayload,
        backPain: backPayload,
        sidePain: sidePayload,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => BodyCheckResults(entryId: entryId),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit body check: $e")),
      );
    }
  }

  static const _cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(24)),
    boxShadow: [
      BoxShadow(
        color: Color(0x0F000000),
        blurRadius: 18,
        offset: Offset(0, 8),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlue[100],
          title: const Text("Body Check"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BodyCheckHistory()),
                );
              },
              child: const Text(
                "History",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 21,
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Drag horizontally to rotate. Release to snap to front (0°), left or right side (±90°), or back (180°). Pain dots are on the front and back only.",
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Container(
                      width: 360,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                      decoration: _cardDecoration,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          const aspect = 0.86;
                          const fill = 0.97;
                          final maxW = constraints.maxWidth;
                          final maxH = constraints.maxHeight;

                          double figW = maxW * fill;
                          double figH = figW / aspect;
                          if (figH > maxH * fill) {
                            figH = maxH * fill;
                            figW = figH * aspect;
                          }

                          var scale = 1.0;
                          if (figH < maxH * fill) {
                            scale = math.min(
                              (maxH * fill) / figH,
                              1.14,
                            );
                          }

                          final face =
                              BodyRotate3D.dominantFaceTowardCamera(
                            _rotationY,
                          );
                          final viewLabel =
                              BodyRotate3D.viewLabelForFace(face);

                          return ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              fit: StackFit.expand,
                              clipBehavior: Clip.none,
                              children: [
                                Positioned.fill(
                                  child: Listener(
                                    behavior: HitTestBehavior.opaque,
                                    onPointerMove: (e) {
                                      if (!e.down) return;
                                      setState(() {
                                        _rotationY += e.delta.dx * 0.0065;
                                      });
                                    },
                                    onPointerUp: (_) {
                                      setState(() {
                                        _rotationY =
                                            BodyRotate3D.snapRotationY(
                                          _rotationY,
                                        );
                                      });
                                    },
                                    onPointerCancel: (_) {
                                      setState(() {
                                        _rotationY =
                                            BodyRotate3D.snapRotationY(
                                          _rotationY,
                                        );
                                      });
                                    },
                                    child: const DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: Color(0xFF121E36),
                                      ),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Transform.scale(
                                    scale: scale,
                                    child: SizedBox(
                                      width: figW,
                                      height: figH,
                                      child: Stack(
                                        fit: StackFit.expand,
                                        clipBehavior: Clip.none,
                                        children: [
                                          BodyRotate3D(
                                            rotationY: _rotationY,
                                            width: figW,
                                            height: figH,
                                            frontOverlay:
                                                face == BodyBoxFace.front
                                                    ? _painMarkersLayer(
                                                        positions:
                                                            _frontPainPointPositions,
                                                        levels:
                                                            _frontPainLevels,
                                                        showTooltips: true,
                                                      )
                                                    : null,
                                            backOverlay:
                                                face == BodyBoxFace.back
                                                    ? _painMarkersLayer(
                                                        positions:
                                                            _backPainPointPositions,
                                                        levels:
                                                            _backPainLevels,
                                                        showTooltips: true,
                                                      )
                                                    : null,
                                            sideLeftOverlay: null,
                                            sideRightOverlay: null,
                                          ),
                                          Positioned(
                                            top: -22,
                                            left: 0,
                                            right: 0,
                                            child: Text(
                                              viewLabel,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Color(0xFFE8FDFF),
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 6,
                                  child: Text(
                                    'Drag left or right to rotate',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(1.0),
                            child: Text(
                              "Pain Level",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              CircleAvatar(
                                radius: 10,
                                backgroundImage: NetworkImage(
                                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRISgUY1LYyDbI6iMh6s2JuDGdewgUgYSs9Ag&s",
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("Low"),
                              ),
                              CircleAvatar(
                                radius: 10,
                                backgroundImage: NetworkImage(
                                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQNpQQIlRMWZLe4IuUKjstO0pVXmvCLP8A3lg&s",
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("Moderate"),
                              ),
                              CircleAvatar(
                                radius: 10,
                                backgroundImage: NetworkImage(
                                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRZwznd8328FB3mHv3HorzAnwKy6w0KxXjREg&s",
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("High"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: ElevatedButton(
                        onPressed: _submit,
                        child: const Text(
                          "Submit",
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }