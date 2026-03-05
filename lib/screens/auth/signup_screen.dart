// lib/screens/auth/signup_screen.dart
// Sign up screen with name, email, password

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/app_state.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _consent = false;

  void _signup() {
    if (_nameCtrl.text.isEmpty || _emailCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    context.read<AppState>().login(_nameCtrl.text, _emailCtrl.text);
    Navigator.pushReplacementNamed(context, '/profile-basic');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Join NutriSync AI',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            const Text('Start your personalized nutrition journey',
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 32),

            _label('Full Name'),
            TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                    hintText: 'Enter your name',
                    prefixIcon: Icon(Icons.person_outline))),
            const SizedBox(height: 16),

            _label('Email'),
            TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email_outlined))),
            const SizedBox(height: 16),

            _label('Password'),
            TextField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                    hintText: 'Create password',
                    prefixIcon: Icon(Icons.lock_outline))),
            const SizedBox(height: 20),

            Row(
              children: [
                Checkbox(
                    value: _consent,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _consent = v ?? false)),
                const Expanded(
                  child: Text(
                    'I agree to the Privacy Policy and Terms of Service',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: _signup,
                  child: const Text('Create Account')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
    );
  }
}
