import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart' as pf;

void main() => runApp(const MaterialApp(home: TopMathPro(), debugShowCheckedModeBanner: false));

// 1. 定義「有記憶的線段」類別
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
  // 核心數據：儲存所有畫過的線
  List<ColoredLine> history = [];
  List<pf.Point> currentLine = [];
  Color activeColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 底層教材 (建議之後可以換成載入本地文件)
          Center(child: Image.network('https://picsum.photos/1024/768', fit: BoxFit.contain)),

          // 中層：零漏筆手寫引擎
          Listener(
            onPointerDown: (e) {
              setState(() {
                currentLine = [pf.Point(e.localPosition.dx, e.localPosition.dy)];
              });
            },
            onPointerMove: (e) {
              setState(() {
                currentLine.add(pf.Point(e.localPosition.dx, e.localPosition.dy));
              });
            },
            onPointerUp: (e) {
              setState(() {
                history.add(ColoredLine(List.from(currentLine), activeColor));
                currentLine = [];
              });
            },
            child: CustomPaint(
              painter: ProPainter(allLines: history, drawingLine: currentLine, drawingColor: activeColor),
              size: Size.infinite,
            ),
          ),

          // 上層：原生質感工具列
          Positioned(
            top: 50, right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(blurRadius: 15, color: Colors.black.withOpacity(0.1))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _colorBtn(Colors.blue),
                  _colorBtn(Colors.red),
                  _colorBtn(Colors.black),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1)),
                  // 上一步按鈕
                  IconButton(
                    icon: const Icon(Icons.undo, color: Colors.blueGrey),
                    onPressed: () => setState(() => history.isNotEmpty ? history.removeLast() : null),
                  ),
                  // 清除按鈕
                  IconButton(
                    icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                    onPressed: () => setState(() => history.clear()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorBtn(Color col) {
    bool isSelected = activeColor == col;
    return GestureDetector(
      onTap: () => setState(() => activeColor = col),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: col,
          shape: BoxShape.circle,
          border: Border.all(color: isSelected ? Colors.orange : Colors.transparent, width: 3),
          boxShadow: isSelected ? [BoxShadow(color: col.withOpacity(0.4), blurRadius: 8)] : [],
        ),
      ),
    );
  }
}

class ProPainter extends CustomPainter {
  final List<ColoredLine> allLines;
  final List<pf.Point> drawingLine;
  final Color drawingColor;

  ProPainter({required this.allLines, required this.drawingLine, required this.drawingColor});

  @override
  void paint(Canvas canvas, Size size) {
    // 繪製歷史線段
    for (var line in allLines) {
      _drawStroke(canvas, line.points, line.color);
    }
    // 繪製正在畫的線段
    _drawStroke(canvas, drawingLine, drawingColor);
  }

  void _drawStroke(Canvas canvas, List<pf.Point> points, Color color) {
    if (points.isEmpty) return;

    final outlinePoints = pf.getStroke(
      points,
      options: const pf.StrokeOptions(
        size: 4.5,          // 稍微加粗一點，教學更清晰
        thinning: 0.6,      // 增加筆鋒感
        smoothing: 0.5,     // 保持圓滑
        streamline: 0.5,    // 讓筆跡跟手感更緊貼
        simulatePressure: true,
      ),
    );

    final paint = Paint()..color = color;
    final path = Path();
    if (outlinePoints.isEmpty) return;

    path.moveTo(outlinePoints[0].dx, outlinePoints[0].dy);
    for (var i = 1; i < outlinePoints.length; i++) {
      path.lineTo(outlinePoints[i].dx, outlinePoints[i].dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}