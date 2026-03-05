// lib/screens/health/ppg_screen.dart
// PPG Heart Rate scanner with dark medical-grade UI
// Uses animated pulse wave and simulated readings for demo

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/app_state.dart';

class PPGScreen extends StatefulWidget {
  const PPGScreen({super.key});

  @override
  State<PPGScreen> createState() => _PPGScreenState();
}

class _PPGScreenState extends State<PPGScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _waveCtrl;
  late AnimationController _ringCtrl;

  bool _scanning = false;
  bool _done = false;
  double _progress = 0;
  double _bpm = 0;
  double _hrv = 0;
  String _quality = 'Waiting...';
  final List<double> _wavePoints = List.filled(60, 0.5);

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _waveCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100))
      ..addListener(_updateWave);
    _ringCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 15));
  }

  void _updateWave() {
    if (!_scanning) return;
    setState(() {
      _wavePoints.removeAt(0);
      final r = Random();
      final isBeat = r.nextDouble() > 0.85;
      _wavePoints.add(isBeat ? 0.05 + r.nextDouble() * 0.15 : 0.4 + r.nextDouble() * 0.2);
    });
  }

  Future<void> _startScan() async {
    setState(() {
      _scanning = true;
      _done = false;
      _progress = 0;
      _quality = 'Detecting...';
      _bpm = 0;
      _hrv = 0;
    });

    _waveCtrl.repeat();
    _ringCtrl.reset();
    _ringCtrl.forward();

    // Simulate 15-second scan
    for (int i = 1; i <= 15; i++) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || !_scanning) break;
      setState(() {
        _progress = i / 15;
        if (i > 3) _quality = 'Good';
        if (i > 5) {
          _bpm = 74 + Random().nextDouble() * 8;
          _hrv = 38 + Random().nextDouble() * 12;
        }
      });
    }

    if (mounted && _scanning) {
      _stopScan(save: false);
      setState(() => _done = true);
    }
  }

  void _stopScan({bool save = false}) {
    setState(() {
      _scanning = false;
      if (_bpm == 0) {
        _bpm = 78;
        _hrv = 42;
        _quality = 'Good';
      }
    });
    _waveCtrl.stop();
    _ringCtrl.stop();
  }

  void _saveReading() {
    context.read<AppState>().updateBiometrics(_bpm, _hrv, _quality);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Reading saved to biometric_readings'),
        backgroundColor: AppColors.primary,
      ),
    );
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _waveCtrl.dispose();
    _ringCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Heart Rate Scanner',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
            child: const Text('Skip',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Instruction card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: AppColors.primary, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Place your fingertip gently on the camera and stay still for accurate measurement.',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Main scanner ring
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, __) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glow
                      if (_scanning)
                        Container(
                          width: 220 + _pulseCtrl.value * 20,
                          height: 220 + _pulseCtrl.value * 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.pulseGlow
                                .withOpacity(0.05 * _pulseCtrl.value),
                          ),
                        ),

                      // Progress ring
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: CircularProgressIndicator(
                          value: _scanning ? _progress : (_done ? 1 : 0),
                          strokeWidth: 6,
                          backgroundColor: Colors.white12,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              _done ? AppColors.primary : AppColors.pulseGlow),
                        ),
                      ),

                      // Camera placeholder
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.darkAccent,
                          border: Border.all(
                            color: _scanning
                                ? AppColors.pulseGlow
                                : Colors.white24,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _scanning
                                  ? Icons.fingerprint
                                  : Icons.camera_alt_outlined,
                              size: 44,
                              color: _scanning
                                  ? AppColors.pulseGlow
                                      .withOpacity(0.5 + _pulseCtrl.value * 0.5)
                                  : Colors.white38,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _bpm > 0
                                  ? '${_bpm.round()} BPM'
                                  : _scanning
                                      ? 'Scanning...'
                                      : 'Camera',
                              style: TextStyle(
                                fontSize: _bpm > 0 ? 22 : 14,
                                fontWeight: FontWeight.w800,
                                color: _bpm > 0
                                    ? AppColors.pulseGlow
                                    : Colors.white38,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Pulse waveform
              Container(
                height: 80,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomPaint(
                  painter: _WavePainter(points: _wavePoints, scanning: _scanning),
                  size: Size.infinite,
                ),
              ),
              const SizedBox(height: 20),

              // Readings row
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: 'Heart Rate',
                      value: _bpm > 0 ? '${_bpm.round()}' : '--',
                      unit: 'BPM',
                      icon: Icons.favorite,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      label: 'HRV',
                      value: _hrv > 0 ? '${_hrv.round()}' : '--',
                      unit: 'ms',
                      icon: Icons.show_chart,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      label: 'Signal',
                      value: _quality,
                      unit: '',
                      icon: Icons.signal_cellular_alt,
                      color: _quality == 'Good'
                          ? AppColors.primary
                          : Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Buttons
              if (!_scanning && !_done)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _startScan,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Scan'),
                  ),
                ),
              if (_scanning)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _stopScan,
                    icon: const Icon(Icons.stop, color: Colors.red),
                    label: const Text('Stop Scan',
                        style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red)),
                  ),
                ),
              if (_done) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveReading,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Reading'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _startScan,
                    child: const Text('Scan Again'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Custom pulse wave painter
class _WavePainter extends CustomPainter {
  final List<double> points;
  final bool scanning;

  _WavePainter({required this.points, required this.scanning});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = scanning ? AppColors.pulseGlow : Colors.white24
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final x = (i / points.length) * size.width;
      final y = points[i] * size.height;
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter old) => true;
}

class _MetricCard extends StatelessWidget {
  final String label, value, unit;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label, required this.value,
    required this.unit, required this.icon, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color)),
          Text(unit.isEmpty ? '' : unit,
              style: const TextStyle(fontSize: 10, color: Colors.white38)),
          Text(label,
              style: const TextStyle(fontSize: 10, color: Colors.white54),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
