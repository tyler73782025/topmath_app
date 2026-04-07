import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:perfect_freehand/perfect_freehand.dart' as pf;

void main() => runApp(const MaterialApp(home: TopMathToolPro(), debugShowCheckedModeBanner: false));

// 1. 線段數據結構，加入「工具類型」
enum ToolType { pen, highlighter, eraser }

class TopLine {
  final List<pf.Point> points;
  final Color color;
  final double size;
  final ToolType tool;
  TopLine(this.points, this.color, this.size, this.tool);
}

class TopMathToolPro extends StatefulWidget {
  const TopMathToolPro({super.key});
  @override
  State<TopMathToolPro> createState() => _TopMathToolProState();
}

class _TopMathToolProState extends State<TopMathToolPro> {
  // 核心數據
  List<TopLine> history = [];
  List<pf.Point> currentPoints = [];
  
  // 當前狀態 (預設)
  ToolType activeTool = ToolType.pen;
  Color activeColor = Colors.blue;
  double activeSize = 4.5; // 筆頭稍微加粗一點，增加飽滿度
  bool palmRejection = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 教材底圖 (之後可換成本地文件載入)
          Center(child: Image.network('https://picsum.photos/1024/768', fit: BoxFit.contain)),

          // 繪圖層 (整合防誤觸邏輯)
          Listener(
            onPointerDown: (e) {
              if (palmRejection && e.kind != PointerDeviceKind.stylus) return;
              setState(() => currentPoints = [pf.Point(e.localPosition.dx, e.localPosition.dy)]);
            },
            onPointerMove: (e) {
              if (palmRejection && e.kind != PointerDeviceKind.stylus) return;
              setState(() => currentPoints.add(pf.Point(e.localPosition.dx, e.localPosition.dy)));
            },
            onPointerUp: (e) {
              if (currentPoints.isEmpty) return;
              setState(() {
                if (activeTool == ToolType.eraser) {
                  _performEraser(e.localPosition);
                } else {
                  history.add(TopLine(List.from(currentPoints), activeColor, activeSize, activeTool));
                }
                currentPoints = [];
              });
            },
            child: CustomPaint(
              painter: ToolPainter(allLines: history, drawingPoints: currentPoints, drawingColor: activeColor, drawingSize: activeSize, drawingTool: activeTool),
              size: Size.infinite,
            ),
          ),

          // 🌟 移植版工具列 (半透明懸浮窗)
          Positioned(
            top: 50, right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildPalmBtn(), // 防誤觸按鈕單獨放上面
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [BoxShadow(blurRadius: 15, color: Colors.black.withOpacity(0.15))],
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 工具區
                        _toolBtn(ToolType.pen, Icons.edit),
                        _toolBtn(ToolType.highlighter, Icons.border_color),
                        _toolBtn(ToolType.eraser, Icons.phonelink_erase),
                        const VerticalDivider(width: 1),
                        
                        // 顏色區 (整合三個顏色)
                        _colorBtn(Colors.blue), _colorBtn(Colors.red), _colorBtn(Colors.black),
                        const VerticalDivider(width: 1),
                        
                        // 粗細區 (兩個預設值)
                        _sizeBtn(4.5, Icons.lens, 14),
                        _sizeBtn(8.0, Icons.lens, 20),
                        const VerticalDivider(width: 1),
                        
                        // 功能區
                        IconButton(icon: const Icon(Icons.undo, color: Colors.grey, size: 20), onPressed: () => setState(() => history.isNotEmpty ? history.removeLast() : null)),
                        IconButton(icon: const Icon(Icons.delete_sweep, color: Colors.redAccent, size: 20), onPressed: () => setState(() => history.clear())),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 橡皮擦邏輯 ---
  void _performEraser(Offset localPos) {
    history.removeWhere((line) {
      // 簡單的點碰撞檢測，距離小於 20 則擦除
      for (var p in line.points) {
        if ((Offset(p.dx, p.dy) - localPos).distance < 20.0) return true;
      }
      return false;
    });
  }

  // --- UI 構建小元件 ---
  Widget _buildPalmBtn() => GestureDetector(
    onTap: () => setState(() => palmRejection = !palmRejection),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: palmRejection ? Colors.green : Colors.grey, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.security, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(palmRejection ? "防誤觸 ON" : "開放 touch", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );

  Widget _toolBtn(ToolType tool, IconData icon) {
    bool isSel = activeTool == tool;
    return IconButton(
      icon: Icon(icon, color: isSel ? Colors.blue : Colors.grey[700], size: 20),
      onPressed: () => setState(() { activeTool = tool; if (tool == ToolType.highlighter) activeColor = activeColor.withOpacity(0.3); else activeColor = activeColor.withOpacity(1.0); }),
    );
  }

  Widget _colorBtn(Color col) => GestureDetector(
    onTap: () => setState(() => activeColor = (activeTool == ToolType.highlighter) ? col.withOpacity(0.3) : col),
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 24, height: 24,
      decoration: BoxDecoration(
        color: col,
        shape: BoxShape.circle,
        border: Border.all(color: (activeColor.withOpacity(1.0) == col) ? Colors.orangeAccent : Colors.transparent, width: 2.5),
      ),
    ),
  );

  Widget _sizeBtn(double size, IconData icon, double iconSize) {
    bool isSel = activeSize == size;
    return IconButton(
      icon: Icon(icon, color: isSel ? Colors.blue : Colors.grey[700], size: iconSize),
      onPressed: () => setState(() => activeSize = size),
    );
  }
}

class ToolPainter extends CustomPainter {
  final List<TopLine> allLines;
  final List<pf.Point> drawingPoints;
  final Color drawingColor;
  final double drawingSize;
  final ToolType drawingTool;

  ToolPainter({required this.allLines, required this.drawingPoints, required this.drawingColor, required this.drawingSize, required this.drawingTool});

  @override
  void paint(Canvas canvas, Size size) {
    for (var line in allLines) { _drawStroke(canvas, line.points, line.color, line.size, line.tool); }
    _drawStroke(canvas, drawingPoints, drawingColor, drawingSize, drawingTool);
  }

  void _drawStroke(Canvas canvas, List<pf.Point> points, Color color, double size, ToolType tool) {
    if (points.isEmpty) return;

    // 🌟 質感優化核心：調整完美筆觸參數
    final options = (tool == ToolType.highlighter)
      // 螢光筆：不需要鋒芒，筆觸要圓潤飽滿
      ? const pf.StrokeOptions(size: 15, thinning: 0.0, smoothing: 0.8, streamline: 0.6, simulatePressure: false)
      // 鋼筆 (優化版)：降低 thinning，增加飽滿度，解決鋸齒感
      : pf.StrokeOptions(
          size: size, 
          thinning: 0.35,      // 🌟 從 0.6 大幅調低至 0.35，墨水流量更穩定
          smoothing: 0.7,      // 高平滑度
          streamline: 0.5,     // 高流暢度
          simulatePressure: true, // 保持壓感
        );

    final outlinePoints = pf.getStroke(points, options: options);
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