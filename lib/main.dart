import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart' as pf;

void main() => runApp(const MaterialApp(home: TopMathPro(), debugShowCheckedModeBanner: false));

class ColoredLine {
  final List<pf.Point> points;
  final Color color;
  ColoredLine(this.points, this.color);
}

class TopMathPro extends StatefulWidget {
  const TopMathPro({super.key});
  @override
  State<TopMathPro> createState() => _TopMathProState();
}

class _TopMathProState extends State<TopMathPro> {
  List<ColoredLine> history = [];
  List<pf.Point> currentLine = [];
  Color activeColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(child: Image.network('https://picsum.photos/1024/768', fit: BoxFit.contain)),
          Listener(
            onPointerDown: (e) => setState(() => currentLine = [pf.Point(e.localPosition.dx, e.localPosition.dy)]),
            onPointerMove: (e) => setState(() => currentLine.add(pf.Point(e.localPosition.dx, e.localPosition.dy))),
            onPointerUp: (e) => setState(() {
              history.add(ColoredLine(List.from(currentLine), activeColor));
              currentLine = [];
            }),
            child: CustomPaint(
              painter: ProPainter(allLines: history, drawingLine: currentLine, drawingColor: activeColor),
              size: Size.infinite,
            ),
          ),
          Positioned(
            top: 50, right: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _colorBtn(Colors.blue), _colorBtn(Colors.red), _colorBtn(Colors.black),
                  const Divider(),
                  IconButton(icon: const Icon(Icons.undo), onPressed: () => setState(() => history.isNotEmpty ? history.removeLast() : null)),
                  IconButton(icon: const Icon(Icons.delete_sweep), onPressed: () => setState(() => history.clear())),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _colorBtn(Color col) => IconButton(icon: Icon(Icons.circle, color: col, size: 30), onPressed: () => setState(() => activeColor = col));
}

class ProPainter extends CustomPainter {
  final List<ColoredLine> allLines;
  final List<pf.Point> drawingLine;
  final Color drawingColor;
  ProPainter({required this.allLines, required this.drawingLine, required this.drawingColor});

  @override
  void paint(Canvas canvas, Size size) {
    for (var line in allLines) { _draw(canvas, line.points, line.color); }
    _draw(canvas, drawingLine, drawingColor);
  }

  void _draw(Canvas canvas, List<pf.Point> points, Color color) {
    if (points.isEmpty) return;
    // 🌟 最終修正點：這裡絕對、絕對沒有 const！
    final strokePoints = pf.getStroke(
      points,
      options: pf.StrokeOptions(
        size: 4.5,
        thinning: 0.6,
        smoothing: 0.5,
        streamline: 0.5,
        simulatePressure: true,
      ),
    );
    final paint = Paint()..color = color;
    final path = Path();
    if (strokePoints.isEmpty) return;
    path.moveTo(strokePoints[0].dx, strokePoints[0].dy);
    for (var p in strokePoints) { path.lineTo(p.dx, p.dy); }
    path.close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}