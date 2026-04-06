import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart'; // 導入專業 PDF 引擎

void main() => runApp(const MaterialApp(home: TopMathNative()));

class TopMathNative extends StatefulWidget {
  const TopMathNative({super.key});
  @override
  State<TopMathNative> createState() => _TopMathNativeState();
}

class _TopMathNativeState extends State<TopMathNative> {
  List<Offset?> points = [];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. 底層：PDF 教材 (這裡先放一個範例路徑，之後可以改選檔)
          SfPdfViewer.network('https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf'),
          
          // 2. 中層：原生手寫畫布 (Raw Listener 模式)
          Listener(
            onPointerMove: (event) {
              setState(() {
                // 🌟 這就是不漏筆的核心：捕捉 Raw 訊號，無視瀏覽器手勢判定
                points.add(event.localPosition);
              });
            },
            onPointerUp: (event) => points.add(null),
            child: CustomPaint(
              painter: MyPainter(points: points),
              size: Size.infinite,
            ),
          ),
          
          // 3. 上層：37 版經典圓角工具列
          Positioned(
            top: 50, right: 20,
            child: FloatingActionButton(
              onPressed: () => setState(() => points = []),
              child: const Icon(Icons.delete),
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
    Paint paint = Paint()..color = Colors.blue..strokeCap = StrokeCap.round..strokeWidth = 4.0;
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }
  @override
  bool shouldRepaint(MyPainter oldDelegate) => true;
}