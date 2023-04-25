import 'package:flutter/material.dart';

class GraphData {
  final Color color;
  final List<double> values;

  GraphData({
    required this.color,
    required this.values,
  });
}

class Activity {
  final Color color;
  final int start, end;

  Activity({
    required this.color,
    required int start,
    required int end,
  })  : start = --start,
        end = --end;
}

class Graphica extends StatelessWidget {
  final List<GraphData> graphs;
  final int indicatorsPadding;
  final List<String>? dxIndicators;
  final List<String>? dyIndicators;
  final Color? dxIndicatorsColor;
  final Color? dyIndicatorsColor;
  final Color backgroundColor;
  final Color dxLineColor;
  final Color dyLineColor;
  final double lineWidth;
  final double graphsWidth;
  final double minScale;
  final double maxScale;
  final List<Activity>? activities;

  const Graphica({
    super.key,
    this.backgroundColor = Colors.white,
    this.dxLineColor = Colors.black,
    this.dyLineColor = Colors.black,
    this.lineWidth = 1.0,
    required this.graphs,
    this.indicatorsPadding = 8,
    this.dxIndicators,
    this.dyIndicators,
    this.dyIndicatorsColor,
    this.dxIndicatorsColor,
    this.graphsWidth = 2,
    this.minScale = 0.1,
    this.maxScale = 3.0,
    this.activities,
  });

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: minScale,
      maxScale: maxScale,
      child: CustomPaint(
        painter: GraphicaPainter(
          backgroundColor: backgroundColor,
          dyIndicators: dyIndicators,
          graphs: graphs,
          activities: activities,
          indicatorsPadding: indicatorsPadding,
          dxIndicators: dxIndicators,
          dyIndicatorsColor: dyIndicatorsColor,
          dxIndicatorsColor: dxIndicatorsColor,
          dxLineColor: dxLineColor,
          dyLineColor: dyLineColor,
          graphsWidth: graphsWidth,
          lineWidth: lineWidth,
        ),
      ),
    );
  }
}

class GraphicaPainter extends CustomPainter {
  final List<GraphData> graphs;
  final int indicatorsPadding;
  final List<String>? dxIndicators;
  final List<String>? dyIndicators;
  final Color? dxIndicatorsColor;
  final Color? dyIndicatorsColor;
  final Color backgroundColor;
  final Color dxLineColor;
  final Color dyLineColor;
  final double lineWidth;
  final double graphsWidth;
  final List<Activity>? activities;

  GraphicaPainter({
    this.backgroundColor = Colors.white,
    this.dxLineColor = Colors.black,
    this.dyLineColor = Colors.black,
    this.lineWidth = 1.0,
    required this.graphs,
    this.indicatorsPadding = 8,
    this.dxIndicators,
    this.dyIndicators,
    this.dyIndicatorsColor,
    this.dxIndicatorsColor,
    this.graphsWidth = 2,
    this.activities,
  })  : _dxMaxValue = _calculateDxMaxValue(graphs),
        _dyMaxValue = _calculateYxMaxValue(graphs) {
    if (dxIndicators != null) {
      _setupDxPaintersAndCalculateSize(dxIndicators!);
      _dyPadding = _dxIndicatorSize.height + indicatorsPadding;
    }
    if (dyIndicators != null) {
      _setupDyPaintersAndCalculateSize(dyIndicators!);
      _dxPadding = _dyIndicatorSize.width + indicatorsPadding;
    }
  }

  final int _dxMaxValue;
  final double _dyMaxValue;
  late var _dxIndicatorSize = Size.zero;
  late var _dyIndicatorSize = Size.zero;
  late var _dxPadding = 0.0;
  late var _dyPadding = 0.0;
  final List<TextPainter> _dxTextPainters = [];
  final List<TextPainter> _dyTextPainters = [];

  static int _calculateDxMaxValue(List<GraphData> graphs) {
    return graphs.map((g) => g.values.length).reduce((a, b) => a > b ? a : b);
  }

  static double _calculateYxMaxValue(List<GraphData> graphs) {
    return graphs
        .map((g) => g.values.reduce((a, b) => a > b ? a : b))
        .reduce((a, b) => a > b ? a : b);
  }

  void _setupDxPaintersAndCalculateSize(List<String> dxIndicators) {
    late TextPainter painter;
    for (final indicator in dxIndicators) {
      painter = TextPainter(
        text: TextSpan(
          text: indicator,
          style: TextStyle(color: dxIndicatorsColor),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      _dxTextPainters.add(painter);
    }
    _dxIndicatorSize = Size(painter.width, painter.height);
  }

  void _setupDyPaintersAndCalculateSize(List<String> dyIndicators) {
    late TextPainter painter;
    for (final indicator in dyIndicators) {
      painter = TextPainter(
        text: TextSpan(
          text: indicator,
          style: TextStyle(color: dyIndicatorsColor),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      _dyTextPainters.add(painter);
    }
    _dyIndicatorSize = Size(painter.width, painter.height);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final dyPoint = size.height - _dyPadding;
    final dxEnd = size.width - _dxIndicatorSize.width;

    final dxStep = (size.width - _dxPadding - _dxIndicatorSize.width) / (_dxMaxValue - 1);
    final dyStep = dyPoint / _dyMaxValue;

    _paintBackground(canvas, dyPoint, dxEnd);

    if (dyIndicators != null) {
      _paintYIndicators(canvas, dyStep);
    }

    if (dxIndicators != null) {
      _paintXIndicators(canvas, dxStep, size.height - _dxIndicatorSize.height);
    }

    if (activities != null) {
      _paintActivities(canvas, dyPoint, dxStep);
    }

    _paintXLines(canvas, dxStep, dyPoint);
    _paintYLines(canvas, dyStep, dxEnd, dyPoint);

    for (final g in graphs) {
      final values = g.values;
      if (values.length < 2) continue;

      final path = Path();
      path.moveTo(dxStep * 0 + _dxPadding,
          dyPoint - (dyPoint / _dyMaxValue * values[0]));

      for (int i = 0; i < values.length - 1; i++) {
        final p1 = Offset(dxStep * i + _dxPadding,
            dyPoint - (dyPoint / _dyMaxValue * values[i]));
        final p2 = Offset(dxStep * (i + 1) + _dxPadding,
            dyPoint - (dyPoint / _dyMaxValue * values[i + 1]));

        final t = i / (values.length - 1);
        final control1 = Offset.lerp(p1, p2, t)!;
        final control2 = Offset.lerp(p1, p2, t + 1 / (values.length - 1))!;

        path.cubicTo(
          control1.dx,
          control1.dy,
          control2.dx,
          control2.dy,
          p2.dx,
          p2.dy,
        );
      }

      canvas.drawPath(
        path,
        Paint()
          ..color = g.color
          ..strokeWidth = graphsWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  void _paintActivities(Canvas canvas, double dyPoint, double dxStep) {
    for (final activity in activities!) {
      canvas.drawRect(
        Rect.fromPoints(
          Offset(dxStep * activity.start + _dxPadding, 0),
          Offset(dxStep * activity.end + _dxPadding, dyPoint),
        ),
        Paint()
          ..style = PaintingStyle.fill
          ..color = activity.color,
      );
    }
  }

  void _paintBackground(Canvas canvas, double dyPoint, double dxPoint) {
    canvas.drawRect(
      Rect.fromPoints(
        Offset(_dxPadding, 0),
        Offset(dxPoint, dyPoint),
      ),
      Paint()
        ..style = PaintingStyle.fill
        ..color = backgroundColor,
    );
  }

  void _paintXLines(Canvas canvas, double dxStep, dyPoint) {
    for (var x = 0; x < _dxMaxValue; x++) {
      final xOffset = dxStep * x + _dxPadding;
      canvas.drawLine(
        Offset(xOffset, 0),
        Offset(xOffset, dyPoint),
        Paint()
          ..color = dxLineColor
          ..strokeWidth = lineWidth,
      );
    }
  }

  void _paintYLines(
      Canvas canvas, double dyStep, double dxPoint, double dyPoint) {
    for (var y = 0; y < _dyMaxValue; y++) {
      final yOffset = dyPoint - dyStep * y;
      canvas.drawLine(
        Offset(_dxPadding, yOffset),
        Offset(dxPoint, yOffset),
        Paint()
          ..color = dyLineColor
          ..strokeWidth = lineWidth,
      );
    }
  }

  void _paintXIndicators(Canvas canvas, double dxStep, double dyPosition) {
    for (var x = 0; x < _dxMaxValue; x++) {
      final dxPosition = x * dxStep + _dxPadding;
      _dxTextPainters[x].paint(
        canvas,
        Offset(dxPosition, dyPosition),
      );
    }
  }

  void _paintYIndicators(Canvas canvas, double dyStep) {
    final length = dyIndicators!.length;

    for (var y = 0; y < length; y++) {
      _dyTextPainters[length - y - 1].paint(
        canvas,
        Offset(0, y * dyStep),
      );
    }
  }

  @override
  bool shouldRepaint(covariant GraphicaPainter oldDelegate) {
    return oldDelegate.graphs != graphs ||
        oldDelegate.dxIndicators != dxIndicators ||
        oldDelegate.dyIndicators != dyIndicators ||
        oldDelegate.dxIndicatorsColor != dxIndicatorsColor ||
        oldDelegate.dyIndicatorsColor != dyIndicatorsColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.dxLineColor != dxLineColor ||
        oldDelegate.dyLineColor != dyLineColor ||
        oldDelegate.lineWidth != lineWidth ||
        oldDelegate.graphsWidth != graphsWidth;
  }
}

extension SizeToOffsetConverter on Size {
  Offset get asOffset => Offset(width, height);
}
