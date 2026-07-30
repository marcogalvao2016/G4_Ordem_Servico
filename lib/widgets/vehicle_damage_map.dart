import 'package:flutter/material.dart';

class VehicleDamageMap extends StatelessWidget {
  const VehicleDamageMap({
    super.key,
    required this.danos,
    required this.onRegionTap,
  });

  final List<Map<String, String>> danos;
  final ValueChanged<String> onRegionTap;

  static const List<_VehicleRegion> _regions = [
    _VehicleRegion('Frente', 0.34, 0.02, 0.32, 0.15),
    _VehicleRegion('Capô', 0.30, 0.16, 0.40, 0.17),
    _VehicleRegion('Para-brisa', 0.31, 0.33, 0.38, 0.12),
    _VehicleRegion('Teto', 0.32, 0.45, 0.36, 0.20),
    _VehicleRegion('Traseira', 0.34, 0.83, 0.32, 0.15),
    _VehicleRegion('Porta dianteira esquerda', 0.05, 0.35, 0.25, 0.22),
    _VehicleRegion('Porta traseira esquerda', 0.05, 0.58, 0.25, 0.22),
    _VehicleRegion('Porta dianteira direita', 0.70, 0.35, 0.25, 0.22),
    _VehicleRegion('Porta traseira direita', 0.70, 0.58, 0.25, 0.22),
  ];

  int _damageCount(String region) => danos.where((d) => d['area'] == region).length;

  Color _regionColor(BuildContext context, String region) {
    final matching = danos.where((d) => d['area'] == region).toList();
    if (matching.isEmpty) return Theme.of(context).colorScheme.surfaceContainerHighest;

    final severe = matching.any((d) {
      final tipo = (d['tipo'] ?? '').toLowerCase();
      return tipo.contains('quebrado') ||
          tipo.contains('trincado') ||
          tipo.contains('ausente') ||
          tipo.contains('amassado');
    });

    return severe ? Colors.red.shade200 : Colors.amber.shade200;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.72,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _VehicleSilhouettePainter(
                    bodyColor: Theme.of(context).colorScheme.surface,
                    lineColor: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
              for (final region in _regions)
                Positioned(
                  left: constraints.maxWidth * region.left,
                  top: constraints.maxHeight * region.top,
                  width: constraints.maxWidth * region.width,
                  height: constraints.maxHeight * region.height,
                  child: Semantics(
                    button: true,
                    label: '${region.name}. ${_damageCount(region.name)} avarias registradas.',
                    child: Material(
                      color: _regionColor(context, region.name).withValues(alpha: 0.82),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => onRegionTap(region.name),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.55),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _shortName(region.name),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                              if (_damageCount(region.name) > 0)
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${_damageCount(region.name)}',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: 8,
                top: 8,
                child: Chip(
                  avatar: const Icon(Icons.arrow_upward, size: 16),
                  label: const Text('Frente'),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _shortName(String value) {
    return value
        .replaceAll('Porta dianteira ', 'Porta diant. ')
        .replaceAll('Porta traseira ', 'Porta tras. ');
  }
}

class _VehicleRegion {
  const _VehicleRegion(this.name, this.left, this.top, this.width, this.height);

  final String name;
  final double left;
  final double top;
  final double width;
  final double height;
}

class _VehicleSilhouettePainter extends CustomPainter {
  const _VehicleSilhouettePainter({required this.bodyColor, required this.lineColor});

  final Color bodyColor;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.18, size.height * 0.03, size.width * 0.64, size.height * 0.94),
      Radius.circular(size.width * 0.18),
    );

    final fill = Paint()..color = bodyColor;
    final stroke = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(body, fill);
    canvas.drawRRect(body, stroke);

    final wheelPaint = Paint()..color = lineColor;
    final wheelWidth = size.width * 0.07;
    final wheelHeight = size.height * 0.16;
    for (final y in [size.height * 0.22, size.height * 0.64]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.11, y, wheelWidth, wheelHeight),
          const Radius.circular(8),
        ),
        wheelPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.82, y, wheelWidth, wheelHeight),
          const Radius.circular(8),
        ),
        wheelPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VehicleSilhouettePainter oldDelegate) =>
      oldDelegate.bodyColor != bodyColor || oldDelegate.lineColor != lineColor;
}
