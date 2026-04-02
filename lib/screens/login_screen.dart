// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/firebase_service.dart';
import '../theme.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController(text: 'admin@gcloud.com');
  final _passCtrl = TextEditingController(text: '');
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  Future<void> _signIn() async {
    setState(() { _loading = true; _error = null; });
    try {
      await FirebaseService.signIn(_emailCtrl.text.trim(), _passCtrl.text);
      if (mounted) {
        Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } catch (e) {
      setState(() => _error = 'Invalid credentials. Please try again.');
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),

              // Google Cloud Logo area
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.blueBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.blue.withOpacity(0.3)),
                      ),
                      child: const Center(
                        child: _GoogleCloudIcon(),
                      ),
                    ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                    const SizedBox(height: 20),
                    Text('Swag Distribution',
                        style: Theme.of(context).textTheme.displayLarge),
                    const SizedBox(height: 6),
                    Text('Admin Portal — Google Cloud',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ).animate().fadeIn(duration: 500.ms),
              ),

              const SizedBox(height: 48),

              // Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Sign In',
                          style: TextStyle(
                              color: AppColors.text,
                              fontSize: 18,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 20),

                      // Email
                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: AppColors.text),
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined, color: AppColors.textMuted),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        style: const TextStyle(color: AppColors.text),
                        onSubmitted: (_) => _signIn(),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textMuted),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.textMuted,
                            ),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                      ),

                      // Error
                      if (_error != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.redBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.red.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: AppColors.red, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(_error!,
                                    style: const TextStyle(color: AppColors.red, fontSize: 13)),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _signIn,
                          child: _loading
                              ? const SizedBox(
                                  height: 20, width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text('Sign In'),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().slideY(begin: 0.2, duration: 400.ms, curve: Curves.easeOut)
               .fadeIn(duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleCloudIcon extends StatelessWidget {
  const _GoogleCloudIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(36, 36),
      painter: _GCPainter(),
    );
  }
}

class _GCPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paints = [
      Paint()..color = const Color(0xFF4285F4),
      Paint()..color = const Color(0xFF34A853),
      Paint()..color = const Color(0xFFFBBC04),
      Paint()..color = const Color(0xFFEA4335),
    ];

    // Simplified G logo segments
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      -1.2, 1.8, false, paints[0]..style = PaintingStyle.stroke..strokeWidth = 5,
    );
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      0.6, 1.6, false, paints[1]..style = PaintingStyle.stroke..strokeWidth = 5,
    );
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      2.2, 1.5, false, paints[2]..style = PaintingStyle.stroke..strokeWidth = 5,
    );
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      3.7, 1.8, false, paints[3]..style = PaintingStyle.stroke..strokeWidth = 5,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
