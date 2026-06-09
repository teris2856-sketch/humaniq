import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

/// Anatomical mesh — camera orbits horizontally (Y-axis); markers use same angle.
class BodyGlbViewer extends StatefulWidget {
  final double rotationY;

  const BodyGlbViewer({
    super.key,
    required this.rotationY,
  });

  static const modelAsset = 'assets/models/human_body_male.glb';

  /// Horizontal orbit: azimuth (θ) polar (φ) radius (fitted in JS; fallback %).
  static const polarDeg = 77.0;
  static const cameraRadiusFallback = '96%';
  static const fieldOfView = '31deg';
  static const modelScale = 0.92;
  static const cameraTarget = 'auto auto auto';
  /// Uniform scale for meshes in the cranial band only (neck pivot preserved).
  static const headMeshScale = 0.84;
  /// World-space cutoff: meshes whose center lies above this body-height
  /// fraction (from the feet up) are treated as head/brain.
  static const headBandMinY = 0.89;
  /// Extra distance after mesh auto-fit so head/feet stay in frame.
  static const fitPaddingFactor = 1.52;

  /// Azimuth when [rotationY] is zero (front).
  static const baseAzimuthDeg = 0.0;

  static double azimuthDeg(double rotationYRad) =>
      baseAzimuthDeg - rotationYRad * 180 / math.pi;

  static String cameraOrbitFor(double rotationYRad) =>
      '${azimuthDeg(rotationYRad).toStringAsFixed(1)}deg $polarDeg $cameraRadiusFallback';

  static String _orbitJsHelpers() => '''
    const bodyFitRadius = (mv) =>
      mv.dataset.bodyFitRadius || '$cameraRadiusFallback';

    const bodySetOrbit = (mv, azimuthDeg) => {
      mv.cameraOrbit =
        azimuthDeg + 'deg $polarDeg ' + bodyFitRadius(mv);
    };

    const worldMeshBounds = (mesh) => {
      const geo = mesh.geometry;
      if (!geo) return null;
      if (!geo.boundingBox) geo.computeBoundingBox();
      const bb = geo.boundingBox;
      const e = mesh.matrixWorld.elements;
      const corners = [
        [bb.min.x, bb.min.y, bb.min.z],
        [bb.min.x, bb.min.y, bb.max.z],
        [bb.min.x, bb.max.y, bb.min.z],
        [bb.min.x, bb.max.y, bb.max.z],
        [bb.max.x, bb.min.y, bb.min.z],
        [bb.max.x, bb.min.y, bb.max.z],
        [bb.max.x, bb.max.y, bb.min.z],
        [bb.max.x, bb.max.y, bb.max.z],
      ];
      let minY = Infinity;
      let maxY = -Infinity;
      for (const [x, y, z] of corners) {
        const wy = e[1] * x + e[5] * y + e[9] * z + e[13];
        minY = Math.min(minY, wy);
        maxY = Math.max(maxY, wy);
      }
      return { minY, maxY, midY: (minY + maxY) * 0.5 };
    };

    const worldOriginY = (obj) => obj.matrixWorld.elements[13];

    const parentScaleY = (parent) => {
      const e = parent.matrixWorld.elements;
      return Math.hypot(e[1], e[5], e[9]) || 1;
    };

    const shrinkHeadMeshesOnly = (model, headScale, bandMinY) => {
      model.updateMatrixWorld(true);
      const meshes = [];
      let modelMinY = Infinity;
      let modelMaxY = -Infinity;
      model.traverse((o) => {
        if (!o.isMesh) return;
        const n = (o.name || '').toLowerCase();
        if (/head of (humerus|radius|ulna|femur|fibula|rib|talus|malleus|metatarsal|phalanx|metacarpal)/.test(n)) {
          return;
        }
        const b = worldMeshBounds(o);
        if (!b) return;
        meshes.push({ mesh: o, bounds: b });
        modelMinY = Math.min(modelMinY, b.minY);
        modelMaxY = Math.max(modelMaxY, b.maxY);
      });
      const modelH = modelMaxY - modelMinY;
      if (!(modelH > 0)) return;
      const neckY = modelMinY + modelH * bandMinY;
      for (const { mesh, bounds } of meshes) {
        if (bounds.midY < neckY) continue;
        mesh.updateMatrixWorld(true);
        const parent = mesh.parent;
        if (!parent) continue;
        parent.updateMatrixWorld(true);
        const worldY = worldOriginY(mesh);
        const newWorldY = neckY + (worldY - neckY) * headScale;
        mesh.position.y += (newWorldY - worldY) / parentScaleY(parent);
        mesh.scale.multiplyScalar(headScale);
      }
      model.updateMatrixWorld(true);
    };

    const bodyFitCamera = async (mv, azimuthDeg) => {
      await mv.updateComplete;
      if (mv.model) {
        mv.model.scale.set($modelScale, $modelScale, $modelScale);
        mv.model.traverse((o) => {
          if (!o.isMesh || !o.material) return;
          const mats = Array.isArray(o.material) ? o.material : [o.material];
          mats.forEach((m) => {
            if (m.color) m.color.setRGB(0.76, 0.79, 0.82);
            if (m.metalness !== undefined) m.metalness = 0.02;
            if (m.roughness !== undefined) m.roughness = 0.94;
            if (m.map) m.map = null;
            if (m.emissive) m.emissive.setRGB(0, 0, 0);
          });
        });
      }
      mv.orientation = '0deg 0deg 0deg';
      mv.cameraTarget = '$cameraTarget';
      mv.fieldOfView = '$fieldOfView';
      mv.cameraOrbit = azimuthDeg + 'deg $polarDeg auto';
      if (typeof mv.jumpCameraToGoal === 'function') {
        await mv.jumpCameraToGoal();
      } else {
        await mv.updateComplete;
      }
      const orbit = typeof mv.getCameraOrbit === 'function'
        ? mv.getCameraOrbit() : null;
      if (orbit && orbit.radius > 0) {
        const padded = orbit.radius * $fitPaddingFactor;
        mv.dataset.bodyFitRadius = padded + 'm';
      } else {
        mv.dataset.bodyFitRadius = '$cameraRadiusFallback';
      }
      bodySetOrbit(mv, azimuthDeg);
      if (typeof mv.jumpCameraToGoal === 'function') {
        await mv.jumpCameraToGoal();
      }
      if (mv.model) {
        shrinkHeadMeshesOnly(mv.model, $headMeshScale, $headBandMinY);
      }
    };
  ''';

  static String setupModelJs(double rotationYRad) {
    final az = azimuthDeg(rotationYRad).toStringAsFixed(1);
    return '''
    (async () => {
      const mv = document.querySelector('model-viewer');
      if (!mv) return;
      ${_orbitJsHelpers()}
      await bodyFitCamera(mv, $az);
    })();
    ''';
  }

  static String applyOrbitJs(double rotationYRad) {
    final az = azimuthDeg(rotationYRad).toStringAsFixed(1);
    return '''
    (() => {
      const mv = document.querySelector('model-viewer');
      if (!mv) return;
      ${_orbitJsHelpers()}
      bodySetOrbit(mv, $az);
    })();
    ''';
  }

  @override
  State<BodyGlbViewer> createState() => _BodyGlbViewerState();
}

class _BodyGlbViewerState extends State<BodyGlbViewer> {
  dynamic _controller;

  String get _cameraOrbit =>
      BodyGlbViewer.cameraOrbitFor(widget.rotationY);

  @override
  void didUpdateWidget(covariant BodyGlbViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rotationY != widget.rotationY) {
      _syncCameraOrbit();
    }
  }

  Future<void> _syncCameraOrbit() async {
    final controller = _controller;
    if (controller == null) return;
    await controller.runJavaScript(
      BodyGlbViewer.applyOrbitJs(widget.rotationY),
    );
  }

  Future<void> _onModelReady() async {
    final controller = _controller;
    if (controller == null) return;
    await controller.runJavaScript(
      BodyGlbViewer.setupModelJs(widget.rotationY),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ModelViewer(
        key: const ValueKey('body_glb_anatomy'),
        src: BodyGlbViewer.modelAsset,
        alt: 'Anatomical human body',
        ar: false,
        autoRotate: false,
        cameraControls: false,
        disableZoom: true,
        disablePan: true,
        disableTap: true,
        touchAction: TouchAction.none,
        interactionPrompt: InteractionPrompt.none,
        debugLogging: false,
        backgroundColor: Colors.transparent,
        cameraOrbit: _cameraOrbit,
        cameraTarget: BodyGlbViewer.cameraTarget,
        fieldOfView: BodyGlbViewer.fieldOfView,
        exposure: 0.95,
        shadowIntensity: 0.55,
        shadowSoftness: 0.75,
        interpolationDecay: 100,
        orientation: '0deg 0deg 0deg',
        relatedJs: '''
          (() => {
            const mv = document.querySelector('model-viewer');
            if (!mv) return;
            mv.addEventListener('load', () => {
              ${BodyGlbViewer.setupModelJs(0)}.then(() => ModelReady.postMessage('ok'));
            });
          })();
        ''',
        javascriptChannels: {
          JavascriptChannel(
            'ModelReady',
            onMessageReceived: (_) => _onModelReady(),
          ),
        },
        onWebViewCreated: (controller) => _controller = controller,
      ),
    );
  }
}
