import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: TopMathNative()));

class TopMathNative extends StatefulWidget {
  const TopMathNative({super.key});
  @override
  State<TopMathNative> createState() => _TopMathNativeState();
}

class _TopMathNativeState extends State<TopMathNative> {
  List<Offset?> points = []; // 儲存筆跡點位
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. 底層：JPG 背景圖 (先用一張範例圖，老師之後可以改路徑)
          Center(
            child: Image.network(
              'https://picsum.photos/1024/768', 
              fit: BoxFit.contain,
            ),
          ),
          
          // 2. 中層：原生手寫層 (這是消滅漏筆的核心)
          Listener(
            onPointerMove: (event) {
              setState(() {
                // 🌟 直接捕捉硬體座標，不經過瀏覽器的手勢過濾
                points.add(event.localPosition);
              });
            },
            onPointerUp: (event) => points.add(null), // 斷筆
            child: CustomPaint(
              painter: MyPainter(points: points),
              size: Size.infinite,
            ),
          ),
          
          // 3. 上層：清除按鈕
          Positioned(
            bottom: 30, right: 30,
            child: FloatingActionButton(
              onPressed: () => setState(() => points = []),
              child: const Icon(Icons.refresh),
            ),
          ),
        ],
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final List<Offset?> points;
  MyPainter({required this.points});
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blue 
      ..strokeCap = StrokeCap.round 
      ..strokeWidth = 4.0;
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }
  @override
  bool shouldRepaint(MyPainter oldDelegate) => true;
}