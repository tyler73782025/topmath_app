import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:perfect_freehand/perfect_freehand.dart' as pf;

void main() => runApp(const MaterialApp(home: TopMathUltra(), debugShowCheckedModeBanner: false));

class ColoredLine {
  final List<pf.Point> points;
  final Color color;
  ColoredLine(this.points, this.color);
}

class TopMathUltra extends StatefulWidget {
  const TopMathUltra({super.key});
  @override
  State<TopMathUltra> createState() => _TopMathUltraState();
}

class _TopMathUltraState extends State<TopMathUltra> {
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
            onPointerDown: (e) {
              if (e.kind != PointerDeviceKind.stylus) return; 
              setState(() => currentLine = [pf.Point(e.localPosition.dx, e.localPosition.dy)]);
            },
            onPointerMove: (e) {
              if (e.kind != PointerDeviceKind.stylus) return;
              setState(() => currentLine.add(pf.Point(e.localPosition.dx, e.localPosition.dy)));
            },
            onPointerUp: (e) {
              if (e.kind != PointerDeviceKind.stylus) return;
              setState(() {
                history.add(ColoredLine(List.from(currentLine), activeColor));
                currentLine = [];
              });
            },
            child: CustomPaint(
              painter: UltraPainter(allLines: history, drawingLine: currentLine, drawingColor: activeColor),
              size: Size.infinite,
            ),
          ),
          Positioned(
            top: 50, right: 20,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black12)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _colorBtn(Colors.blue), _colorBtn(Colors.red), _colorBtn(Colors.black),
                  const Divider(),
                  IconButton(icon: const Icon(Icons.undo), onPressed: () => setState(() => history.isNotEmpty ? history.removeLast() : null)),
                  IconButton(icon: const Icon(Icons.delete_forever), onPressed: () => setState(() => history.clear())),
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

class UltraPainter extends CustomPainter {
  final List<ColoredLine> allLines;
  final List<pf.Point> drawingLine;
  final Color drawingColor;
  UltraPainter({required this.allLines, required this.drawingLine, required this.drawingColor});

  @override
  void paint(Canvas canvas, Size size) {
    for (var line in allLines) { _draw(canvas, line.points, line.color); }
    _draw(canvas, drawingLine, drawingColor);
  }

  void _draw(Canvas canvas, List<pf.Point> points, Color color) {
    if (points.isEmpty) return;
    
    // 🌟 最終檢查點：這裡絕對、絕對、絕對沒有 const！
    final strokePoints = pf.getStroke(
      points,
      options: pf.StrokeOptions(
        size: 4.8,
        thinning: 0.7,
        smoothing: 0.65,
        streamline: 0.4,
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