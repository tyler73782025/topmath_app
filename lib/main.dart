import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:perfect_freehand/perfect_freehand.dart' as pf;

void main() => runApp(const MaterialApp(home: TopMathAdvanced(), debugShowCheckedModeBanner: false));

class ColoredLine {
  final List<pf.Point> points;
  final Color color;
  final bool isStylus; // 紀錄是否為筆尖書寫
  ColoredLine(this.points, this.color, this.isStylus);
}

class TopMathAdvanced extends StatefulWidget {
  const TopMathAdvanced({super.key});
  @override
  State<TopMathAdvanced> createState() => _TopMathAdvancedState();
}

class _TopMathAdvancedState extends State<TopMathAdvanced> {
  List<ColoredLine> history = [];
  List<pf.Point> currentLine = [];
  Color activeColor = Colors.blue;
  bool palmRejectionEnabled = true; // 🌟 防誤觸開關

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 教材底圖
          Center(child: Image.network('https://picsum.photos/1024/768', fit: BoxFit.contain)),

          // 繪圖層
          Listener(
            onPointerDown: (e) {
              // 如果開啟防誤觸，且不是筆尖，就攔截
              if (palmRejectionEnabled && e.kind != PointerDeviceKind.stylus) return;
              setState(() => currentLine = [pf.Point(e.localPosition.dx, e.localPosition.dy)]);
            },
            onPointerMove: (e) {
              if (palmRejectionEnabled && e.kind != PointerDeviceKind.stylus) return;
              setState(() => currentLine.add(pf.Point(e.localPosition.dx, e.localPosition.dy)));
            },
            onPointerUp: (e) {
              if (currentLine.isEmpty) return;
              setState(() {
                history.add(ColoredLine(List.from(currentLine), activeColor, e.kind == PointerDeviceKind.stylus));
                currentLine = [];
              });
            },
            child: CustomPaint(
              painter: AdvancedPainter(allLines: history, drawingLine: currentLine, drawingColor: activeColor),
              size: Size.infinite,
            ),
          ),

          // 右側工具列
          Positioned(
            top: 50, right: 20,
            child: Column(
              children: [
                // 防誤觸開關按鈕
                _buildToggleButton(),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
                  ),
                  child: Column(
                    children: [
                      _colorBtn(Colors.blue), _colorBtn(Colors.red), _colorBtn(Colors.black),
                      const Divider(),
                      IconButton(icon: const Icon(Icons.undo), onPressed: () => setState(() => history.isNotEmpty ? history.removeLast() : null)),
                      IconButton(icon: const Icon(Icons.delete_forever), onPressed: () => setState(() => history.clear())),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🌟 防誤觸開關組件
  Widget _buildToggleButton() {
    return GestureDetector(
      onTap: () => setState(() => palmRejectionEnabled = !palmRejectionEnabled),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: palmRejectionEnabled ? Colors.green : Colors.grey,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(palmRejectionEnabled ? Icons.edit_note : Icons.touch_app, color: Colors.white, size: 18),
            const SizedBox(width: 5),
            Text(palmRejectionEnabled ? "防手觸: ON" : "手寫: 開放", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _colorBtn(Color col) => IconButton(icon: Icon(Icons.circle, color: col, size: 28), onPressed: () => setState(() => activeColor = col));
}

class AdvancedPainter extends CustomPainter {
  final List<ColoredLine> allLines;
  final List<pf.Point> drawingLine;
  final Color drawingColor;
  AdvancedPainter({required this.allLines, required this.drawingLine, required this.drawingColor});

  @override
  void paint(Canvas canvas, Size size) {
    for (var line in allLines) { _draw(canvas, line.points, line.color); }
    _draw(canvas, drawingLine, drawingColor);
  }

  void _draw(Canvas canvas, List<pf.Point> points, Color color) {
    if (points.isEmpty) return;
    
    final strokePoints = pf.getStroke(
      points,
      options: pf.StrokeOptions(
        size: 4.5,
        thinning: 0.6,
        smoothing: 0.75,   // 🌟 再次調高圓滑度，解決轉彎問題
        streamline: 0.45, // 🌟 強化流暢感
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