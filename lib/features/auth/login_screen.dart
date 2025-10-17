import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alphagrit/core/constants/env.dart';
import 'package:alphagrit/app/theme/theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  String? error;
  bool isSignUp = false;

  @override
  void initState() {
    super.initState();
    if (Env.supabaseUrl.isNotEmpty && Env.supabaseAnonKey.isNotEmpty) {
      Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);
    }
  }

  Future<void> _login() async {
    setState(() => error = null);
    try {
      await Supabase.instance.client.auth.signInWithPassword(email: emailCtrl.text, password: passCtrl.text);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  Future<void> _signUp() async {
    setState(() => error = null);
    try {
      await Supabase.instance.client.auth.signUp(email: emailCtrl.text, password: passCtrl.text);
      if (mounted) {
        setState(() => error = 'Check your email to confirm your account!');
      }
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text((isSignUp ? 'SIGN UP' : t.login).toUpperCase())),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (error != null) GritCard(child: Text(error!, style: TextStyle(color: error!.contains('Check your email') ? GritColors.white : Colors.red))),
          const SizedBox(height: 8),
          TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 8),
          TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Password (min 6 chars)'), obscureText: true),
          const SizedBox(height: 16),
          GritButton(label: isSignUp ? 'SIGN UP' : t.login, onPressed: isSignUp ? _signUp : _login),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => setState(() => isSignUp = !isSignUp),
            child: Text(
              isSignUp ? 'Already have an account? Login' : 'Need an account? Sign up',
              style: TextStyle(color: GritColors.grey),
            ),
          ),
        ]),
      ),
    );
  }
}


