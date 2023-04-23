import 'package:flutter/material.dart';

class GraphData {
  final Color color;
  final List<int> values;

  GraphData({
    required this.color,
    required this.values,
  });
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
  final int xCap;
  final int yCap;
  final List<TextPainter> _dxTextPainters = [];
  final List<TextPainter> _dyTextPainters = [];

  GraphicaPainter({
    this.backgroundColor = Colors.white,
    this.dxLineColor = Colors.black,
    this.dyLineColor = Colors.black,
    this.lineWidth = 1.0,
    required this.graphs,
    this.indicatorsPadding = 8,
    this.dxIndicators,
    List<String>? dyIndicators,
    this.dyIndicatorsColor,
    this.dxIndicatorsColor,
    this.graphsWidth = 2,
  })  : xCap =
            graphs.map((g) => g.values.length).reduce((a, b) => a > b ? a : b),
        yCap = graphs
            .map((g) => g.values.reduce((a, b) => a > b ? a : b))
            .reduce((a, b) => a > b ? a : b),
        dyIndicators = dyIndicators?.reversed.toList() {
    _initTextPainters();
  }

  var _yOffstage = 0.0;
  var _xOffstage = 0.0;
  var _xIndicatorsWidth = 0.0;
  var _xIndicatorsHeight = 0.0;

  @override
  void paint(Canvas canvas, Size size) {
    var h = size.height;
    var w = size.width;

    _paintBackground(canvas, h, w);

    final xCap =
        graphs.map((g) => g.values.length - 1).reduce((a, b) => a > b ? a : b);

    final yCap = graphs
        .map((g) => g.values.reduce((a, b) => a > b ? a : b))
        .reduce((a, b) => a > b ? a : b);

    final dyStep = (h - _yOffstage) / yCap;

    if (dyIndicators != null) {
      _paintYIndicators(canvas, dyStep);
    }

    final dxStep = (w - _xIndicatorsWidth - _xOffstage) / xCap;

    if (dxIndicators != null) {
      _paintXIndicators(canvas, dxStep, h);
    }

    _paintXLines(canvas, dxStep, h);
    _paintYLines(canvas, dyStep, w, h);
    h = h - _yOffstage;

    for (final g in graphs) {
      final values = g.values;
      if (values.length < 2) continue;

      final path = Path();
      path.moveTo(dxStep * 0 + _xOffstage, h - (h / yCap * values[0]));

      for (int i = 0; i < values.length - 1; i++) {
        final p1 = Offset(dxStep * i + _xOffstage, h - (h / yCap * values[i]));
        final p2 = Offset(dxStep * (i + 1) + _xOffstage, h - (h / yCap * values[i + 1]));

        final t = i / (values.length - 1);
        final control1 = Offset.lerp(p1, p2, t)!;
        final control2 = Offset.lerp(p1, p2, t + 1 / (values.length - 1))!;

        path.cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, p2.dx, p2.dy);
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

  void _initTextPainters() {
    if (dxIndicators != null) {
      late TextPainter painter;
      for (final indicator in dxIndicators!) {
        painter = TextPainter(
          text: TextSpan(
            text: indicator,
            style: TextStyle(color: dxIndicatorsColor),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        _xIndicatorsHeight = painter.height;
        _xIndicatorsWidth = painter.width;
        _yOffstage = _xIndicatorsHeight + indicatorsPadding;
        _dxTextPainters.add(painter);
      }
    }

    if (dyIndicators != null) {
      late TextPainter painter;
      for (final indicator in dyIndicators!) {
        painter = TextPainter(
          text: TextSpan(
            text: indicator,
            style: TextStyle(color: dyIndicatorsColor),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        _xOffstage = painter.width + indicatorsPadding;
        _dyTextPainters.add(painter);
      }
    }
  }

  void _paintBackground(Canvas canvas, double h, double w) {
    canvas.drawRect(
      Rect.fromPoints(
        Offset(_xOffstage, 0),
        Offset(w - _xIndicatorsWidth, h - _yOffstage),
      ),
      Paint()
        ..style = PaintingStyle.fill
        ..color = backgroundColor,
    );
  }

  void _paintXLines(Canvas canvas, double dxStep, double h) {
    for (var x = 0; x < xCap; x++) {
      final xOffset = dxStep * x + _xOffstage;
      canvas.drawLine(
        Offset(xOffset, 0),
        Offset(xOffset, h - _yOffstage),
        Paint()
          ..color = dxLineColor
          ..strokeWidth = lineWidth,
      );
    }
  }

  void _paintYLines(Canvas canvas, double dyStep, double w, double h) {
    for (var y = 0; y < yCap; y++) {
      final yOffset = h - dyStep * y - _yOffstage;
      canvas.drawLine(
        Offset(_xOffstage, yOffset),
        Offset(w - _xIndicatorsWidth, yOffset),
        Paint()
          ..color = dyLineColor
          ..strokeWidth = lineWidth,
      );
    }
  }

  void _paintXIndicators(Canvas canvas, double dxStep, double h) {
    for (var x = 0; x < xCap; x++) {
      _dxTextPainters[x].paint(
        canvas,
        Offset(x * dxStep + _xOffstage, h - _xIndicatorsHeight),
      );
    }
  }

  void _paintYIndicators(Canvas canvas, double dyStep) {
    for (var y = 0; y < yCap + 1; y++) {
      _dyTextPainters[y].paint(
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
