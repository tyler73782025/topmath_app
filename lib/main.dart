import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart' as pf;

void main() => runApp(const MaterialApp(home: TopMathNative()));

class TopMathNative extends StatefulWidget {
  const TopMathNative({super.key});
  @override
  State<TopMathNative> createState() => _TopMathNativeState();
}

class _TopMathNativeState extends State<TopMathNative> {
  // 儲存所有筆劃數據，使用 pf.Point 確保美化演算法能讀取
  List<List<pf.Point>> lines = [[]];
  Color selectedColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. 底層：您的 JPG 教材 (目前先用範例圖，之後可改)
          Center(
            child: Image.network(
              'https://picsum.photos/1024/768', 
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Text('教材讀取中...'),
            ),
          ),
          
          // 2. 中層：【零漏筆】原生監聽層
          // 透過 Listener 直接跟 iPad 核心拿座標，繞過瀏覽器的誤觸過濾
          Listener(
            onPointerDown: (e) => setState(() => lines.add([pf.Point(e.localPosition.dx, e.localPosition.dy)])),
            onPointerMove: (e) => setState(() => lines.last.add(pf.Point(e.localPosition.dx, e.localPosition.dy))),
            child: CustomPaint(
              painter: MyPainter(lines: lines, color: selectedColor),
              size: Size.infinite,
            ),
          ),
          
          // 3. 上層：37 版風格圓角工具列
          Positioned(
            top: 50, right: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9), 
                borderRadius: BorderRadius.circular(20), 
                boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black12)]
              ),
              child: Column(
                children: [
                  _colorIcon(Colors.blue),
                  _colorIcon(Colors.red),
                  _colorIcon(Colors.black),
                  const Divider(),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
                    onPressed: () => setState(() => lines = [[]]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorIcon(Color col) => IconButton(
    icon: Icon(Icons.circle, color: col),
    onPressed: () => setState(() => selectedColor = col),
  );
}

class MyPainter extends CustomPainter {
  final List<List<pf.Point>> lines;
  final Color color;
  MyPainter({required this.lines, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (final line in lines) {
      if (line.isEmpty) continue;
      
      // 🌟 使用最新版 getStroke 演算法，將點位轉換成絲滑的輪廓
      final strokePoints = pf.getStroke(
        line,
        options: const pf.StrokeOptions(
          size: 4,
          thinning: 0.5,
          smoothing: 0.5,
          streamline: 0.5,
        ),
      );
      
      final path = Path();
      if (strokePoints.isEmpty) continue;
      path.moveTo(strokePoints[0].dx, strokePoints[0].dy);
      for (final p in strokePoints) {
        path.lineTo(p.dx, p.dy);
      }
      path.close(); // 封閉路徑讓筆跡更飽滿
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}