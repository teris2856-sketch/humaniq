import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:swiftspeak/body_rotate_3d.dart';

/// A body-region anchor in normalized 3D space (Y: 0 = top, 1 = feet).
class BodyAnchor3D {
  final String id;
  final double x;
  final double y;
  final double z;

  const BodyAnchor3D(this.id, this.x, this.y, this.z);
}

/// Orientation-specific marker sets projected as the camera orbits.
class BodyAnatomyProjection {
  BodyAnatomyProjection._();

  static const double depthThreshold = 0.045;
  static const double horizScale = 0.56;

  /// Full front layout — head/feet visible; arms outward on limbs.
  static const List<BodyAnchor3D> frontAnchors = [
    BodyAnchor3D('Head', 0, 0.048, 0.12),
    BodyAnchor3D('Neck', 0, 0.112, 0.11),
    BodyAnchor3D('LeftShoulder', -0.26, 0.168, 0.10),
    BodyAnchor3D('Right Shoulder', 0.26, 0.168, 0.10),
    BodyAnchor3D('Chest', 0, 0.235, 0.11),
    // Upper arm / forearm — well outside torso (chest x = 0).
    BodyAnchor3D('LeftElbow', -0.34, 0.300, 0.11),
    BodyAnchor3D('RightElbow', 0.34, 0.300, 0.11),
    BodyAnchor3D('LeftHand', -0.36, 0.412, 0.10),
    BodyAnchor3D('RightHand', 0.36, 0.412, 0.10),
    BodyAnchor3D('LeftPalm', -0.41, 0.532, 0.10),
    BodyAnchor3D('RightPalm', 0.41, 0.532, 0.10),
    BodyAnchor3D('Stomach', 0, 0.385, 0.10),
    BodyAnchor3D('spot9', 0, 0.475, 0.09),
    BodyAnchor3D('LeftHip', -0.17, 0.505, 0.08),
    BodyAnchor3D('RightHip', 0.17, 0.505, 0.08),
    BodyAnchor3D('LeftThigh', -0.13, 0.595, 0.07),
    BodyAnchor3D('RightThigh', 0.13, 0.595, 0.07),
    BodyAnchor3D('LeftKnee', -0.12, 0.715, 0.06),
    BodyAnchor3D('RightKnee', 0.12, 0.715, 0.06),
    BodyAnchor3D('LeftShin', -0.11, 0.835, 0.05),
    BodyAnchor3D('RightShin', 0.11, 0.835, 0.05),
    BodyAnchor3D('LeftFoot', -0.11, 0.942, 0.05),
    BodyAnchor3D('RightFoot', 0.11, 0.942, 0.05),
  ];

  /// Full back layout.
  static const List<BodyAnchor3D> backAnchors = [
    BodyAnchor3D('BackHead', 0, 0.048, -0.12),
    BodyAnchor3D('BackNeck', 0, 0.112, -0.11),
    BodyAnchor3D('BackLeftShoulder', -0.26, 0.168, -0.10),
    BodyAnchor3D('BackRightShoulder', 0.26, 0.168, -0.10),
    BodyAnchor3D('UpperBack', 0, 0.235, -0.11),
    BodyAnchor3D('BackLeftElbow', -0.34, 0.300, -0.11),
    BodyAnchor3D('BackRightElbow', 0.34, 0.300, -0.11),
    BodyAnchor3D('BackLeftHand', -0.36, 0.412, -0.10),
    BodyAnchor3D('BackRightHand', 0.36, 0.412, -0.10),
    BodyAnchor3D('BackLeftPalm', -0.41, 0.532, -0.10),
    BodyAnchor3D('BackRightPalm', 0.41, 0.532, -0.10),
    BodyAnchor3D('MidBack', 0, 0.345, -0.10),
    BodyAnchor3D('LowerBack', 0, 0.435, -0.09),
    BodyAnchor3D('BackLeftThigh', -0.13, 0.595, -0.07),
    BodyAnchor3D('BackRightThigh', 0.13, 0.595, -0.07),
    BodyAnchor3D('BackLeftKnee', -0.12, 0.715, -0.06),
    BodyAnchor3D('BackRightKnee', 0.12, 0.715, -0.06),
    BodyAnchor3D('BackLeftShin', -0.11, 0.835, -0.05),
    BodyAnchor3D('BackRightShin', 0.11, 0.835, -0.05),
    BodyAnchor3D('BackLeftFoot', -0.11, 0.942, -0.05),
    BodyAnchor3D('BackRightFoot', 0.11, 0.942, -0.05),
  ];

  /// Simplified left-profile layout (person's left side = −X).
  static const List<BodyAnchor3D> leftSideAnchors = [
    BodyAnchor3D('SideLeftHead', -0.13, 0.06, 0.03),
    BodyAnchor3D('SideLeftNeck', -0.14, 0.14, 0.02),
    BodyAnchor3D('SideLeftChest', -0.14, 0.25, 0.015),
    BodyAnchor3D('SideLeftAbdomen', -0.14, 0.38, 0.0),
    BodyAnchor3D('SideLeftHip', -0.13, 0.50, -0.005),
    BodyAnchor3D('SideLeftThigh', -0.12, 0.60, -0.01),
    BodyAnchor3D('SideLeftKnee', -0.11, 0.73, -0.02),
    BodyAnchor3D('SideLeftFoot', -0.10, 0.93, -0.03),
  ];

  /// Simplified right-profile layout (person's right side = +X).
  static const List<BodyAnchor3D> rightSideAnchors = [
    BodyAnchor3D('SideRightHead', 0.13, 0.06, 0.03),
    BodyAnchor3D('SideRightNeck', 0.14, 0.14, 0.02),
    BodyAnchor3D('SideRightChest', 0.14, 0.25, 0.015),
    BodyAnchor3D('SideRightAbdomen', 0.14, 0.38, 0.0),
    BodyAnchor3D('SideRightHip', 0.13, 0.50, -0.005),
    BodyAnchor3D('SideRightThigh', 0.12, 0.60, -0.01),
    BodyAnchor3D('SideRightKnee', 0.11, 0.73, -0.02),
    BodyAnchor3D('SideRightFoot', 0.10, 0.93, -0.03),
  ];

  /// Marker set for the view currently facing the camera.
  static List<BodyAnchor3D> anchorsForRotation(double rotationY) {
    switch (BodyRotate3D.dominantFaceTowardCamera(rotationY)) {
      case BodyBoxFace.front:
        return frontAnchors;
      case BodyBoxFace.back:
        return backAnchors;
      case BodyBoxFace.sideLeft:
        return leftSideAnchors;
      case BodyBoxFace.sideRight:
        return rightSideAnchors;
    }
  }

  /// Projects anchors for horizontal camera orbit (same axis as [BodyGlbViewer]).
  static Offset? project(BodyAnchor3D anchor, double rotationY) {
    final c = math.cos(rotationY);
    final s = math.sin(rotationY);
    final viewX = anchor.x * c + anchor.z * s;
    final viewZ = anchor.z * c - anchor.x * s;

    if (viewZ < depthThreshold) return null;

    final screenX = 0.5 + viewX * horizScale;
    if (screenX < 0.04 || screenX > 0.96) return null;

    return Offset(
      screenX.clamp(0.04, 0.96),
      anchor.y.clamp(0.04, 0.96),
    );
  }

  static bool isBackId(String id) => id.startsWith('Back');
  static bool isSideId(String id) => id.startsWith('Side');
}
