import 'package:flutter/material.dart';

void main() => runApp(const TopMathApp());

class TopMathApp extends StatelessWidget {
  const TopMathApp({super.key});
  @override
  Widget build(BuildContext context) => const MaterialApp(home: HandWritingScreen());
}

class HandWritingScreen extends StatefulWidget {
  const HandWritingScreen({super.key});
  @override
  State<HandWritingScreen> createState() => _HandWritingScreenState();
}

class _HandWritingScreenState extends State<HandWritingScreen> {
  // 🌟 核心：使用原生清單儲存點位，優先權高於網頁
  List<Offset?> points = []; 
  Color selectedColor = Colors.blue;
  double strokeWidth = 4.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 畫布層：直接捕捉硬體訊號
          GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                // 這裡的 details.localPosition 是原生系統直接傳回的座標
                points.add(details.localPosition); 
              });
            },
            onPanEnd: (details) => points.add(null),
            child: CustomPaint(
              painter: MyPainter(points: points, color: selectedColor, width: strokeWidth),
              size: Size.infinite,
            ),
          ),
          // 🌟 37 版圓角懸浮工具列原生化
          Positioned(
            top: 40, right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xEE2C3E50),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  IconButton(onPressed: () => setState(() => points = []), 
                             icon: const Icon(Icons.delete, color: Colors.redAccent)),
                  const VerticalDivider(color: Colors.white24),
                  _colorDot(Colors.blue),
                  _colorDot(Colors.green),
                  _colorDot(Colors.red),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorDot(Color color) {
    return GestureDetector(
      onTap: () => setState(() => selectedColor = color),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        width: 20, height: 20,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final List<Offset?> points;
  final Color color;
  final double width;
  MyPainter({required this.points, required this.color, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = color..strokeCap = StrokeCap.round..strokeWidth = width;
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }
  @override
  bool shouldRepaint(MyPainter oldDelegate) => true;
}