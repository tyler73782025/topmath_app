import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart' as pf;

void main() => runApp(const MaterialApp(home: TopMathNative()));

class TopMathNative extends StatefulWidget {
  const TopMathNative({super.key});
  @override
  State<TopMathNative> createState() => _TopMathNativeState();
}

class _TopMathNativeState extends State<TopMathNative> {
  List<List<pf.Point>> lines = [[]];
  Color selectedColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(child: Image.network('https://picsum.photos/1024/768', fit: BoxFit.contain)),
          Listener(
            onPointerDown: (e) => setState(() => lines.add([pf.Point(e.localPosition.dx, e.localPosition.dy)])),
            onPointerMove: (e) => setState(() => lines.last.add(pf.Point(e.localPosition.dx, e.localPosition.dy))),
            child: CustomPaint(
              painter: MyPainter(lines: lines, color: selectedColor),
              size: Size.infinite,
            ),
          ),
          Positioned(
            top: 50, right: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black12)]),
              child: Column(
                children: [
                  IconButton(icon: const Icon(Icons.circle, color: Colors.blue), onPressed: () => setState(() => selectedColor = Colors.blue)),
                  IconButton(icon: const Icon(Icons.circle, color: Colors.red), onPressed: () => setState(() => selectedColor = Colors.red)),
                  IconButton(icon: const Icon(Icons.circle, color: Colors.black), onPressed: () => setState(() => selectedColor = Colors.black)),
                  const Divider(),
                  IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => setState(() => lines = [[]])),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
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
      
      // 🌟 這裡已經拿掉了 const，絕對不會再報錯！
      final strokePoints = pf.getStroke(
        line,
        options: pf.StrokeOptions(
          size: 4,
          thinning: 0.5,
          smoothing: 0.5,
          streamline: 0.5,
          simulatePressure: true,
        ),
      );
      
      final path = Path();
      if (strokePoints.isEmpty) continue;
      path.moveTo(strokePoints[0].dx, strokePoints[0].dy);
      for (final p in strokePoints) { path.lineTo(p.dx, p.dy); }
      path.close();
      canvas.drawPath(path, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}