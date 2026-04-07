import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // 🌟 引入手勢判斷
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
          // 底層教材
          Center(child: Image.network('https://picsum.photos/1024/768', fit: BoxFit.contain)),

          // 核心繪圖層：加上 DeviceKind 過濾
          Listener(
            onPointerDown: (e) {
              // 🌟 物理防誤觸：只准許「筆」進入，手指或手掌直接無視
              if (e.kind != PointerDeviceKind.stylus) return; 
              setState(() {
                currentLine = [pf.Point(e.localPosition.dx, e.localPosition.dy)];
              });
            },
            onPointerMove: (e) {
              if (e.kind != PointerDeviceKind.stylus) return;
              setState(() {
                currentLine.add(pf.Point(e.localPosition.dx, e.localPosition.dy));
              });
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

          // 右側浮動工具列
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
                  const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
                  IconButton(icon: const Icon(Icons.undo, color: Colors.blueGrey), onPressed: () => setState(() => history.isNotEmpty ? history.removeLast() : null)),
                  IconButton(icon: const Icon(Icons.delete_forever, color: Colors.redAccent), onPressed: () => setState(() => history.clear())),
                ],
              ),
            ),
          ),
          
          // 左下角狀態提示
          const Positioned(
            bottom: 20, left: 20,
            child: Text("物理防誤觸：已啟動 (僅限筆尖)", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _colorBtn(Color col) => GestureDetector(
    onTap: () => setState(() => activeColor = col),
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: 32, height: 32,
      decoration: BoxDecoration(
        color: col,
        shape: BoxShape.circle,
        border: Border.all(color: activeColor == col ? Colors.orange : Colors.transparent, width: 3),
      ),
    ),
  );
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
    
    final strokePoints = pf.getStroke(
      points,
      options: const pf.StrokeOptions(
        size: 4.8,          // 增加一點點粗度，讓視覺更穩定
        thinning: 0.7,      // 增加筆鋒的動態感
        smoothing: 0.65,    // 🌟 提升平滑度，解決轉彎鋸齒感
        streamline: 0.4,    // 🌟 增加流暢補償
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