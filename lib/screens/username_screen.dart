import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/storage_service.dart';
import 'home_screen.dart';


class UsernameScreen extends StatefulWidget {
  final bool isFirstTime;

  const UsernameScreen({super.key, this.isFirstTime = true});

  @override
  State<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUsername();
  }

  Future<void> _loadCurrentUsername() async {
    if (!widget.isFirstTime) {
      final storage = await StorageService.getInstance();
      final current = storage.getUsername();
      if (current != null && mounted) _controller.text = current;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveUsername() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final storage = await StorageService.getInstance();
    await storage.saveUsername(_controller.text.trim());

    if (!mounted) return;
    if (widget.isFirstTime) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Stack(
            children: [
              const _CandyBackgroundDecor(),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: size.height * 0.03),
                        _buildLogo(),
                        const SizedBox(height: 26),
                        _buildTitle(),
                        SizedBox(height: size.height * 0.055),
                        _buildNameCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(34),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.30), blurRadius: 22, offset: const Offset(0, 10))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          _LogoTile(letter: 'W', color: AppColors.primary),
          SizedBox(width: 6),
          _LogoTile(letter: 'O', color: AppColors.accent),
          SizedBox(width: 6),
          _LogoTile(letter: 'R', color: AppColors.success),
          SizedBox(width: 6),
          _LogoTile(letter: 'D', color: AppColors.warning),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        const Text(
          'WORD CRUSH',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 4,
            shadows: [Shadow(color: AppColors.primaryDark, offset: Offset(2, 3), blurRadius: 5)],
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Kelime Bulmaca Oyunu',
          style: TextStyle(fontSize: 15, color: Colors.white.withValues(alpha: 0.92), fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildNameCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, AppColors.primary.withValues(alpha: 0.08)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.5),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.23), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Text(
            widget.isFirstTime ? 'Hoş geldin!' : 'Kullanıcı adını değiştir',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            widget.isFirstTime ? 'Oyuna başlamak için adını yaz' : 'Yeni kullanıcı adını yaz',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _controller,
            maxLength: 16,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Kullanıcı adın',
              hintStyle: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w600),
              filled: true,
              fillColor: AppColors.surfaceLight.withValues(alpha: 0.85),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppColors.primary, width: 2.3),
              ),
              prefixIcon: const Icon(Icons.person_rounded, color: AppColors.primary),
              counterText: '',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Kullanıcı adı boş olamaz';
              if (value.trim().length < 2) return 'En az 2 karakter olmalı';
              return null;
            },
            onFieldSubmitted: (_) => _saveUsername(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveUsername,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 9,
                shadowColor: AppColors.primaryDark.withValues(alpha: 0.45),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: _isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.isFirstTime ? 'BAŞLA' : 'KAYDET',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 23),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoTile extends StatelessWidget {
  final String letter;
  final Color color;
  const _LogoTile({required this.letter, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFFF1BD), Color(0xFFFFD27D)]),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color, width: 2),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.20), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Center(
        child: Text(letter, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w900)),
      ),
    );
  }
}

class _CandyBackgroundDecor extends StatelessWidget {
  const _CandyBackgroundDecor();
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(top: 90, right: -32, child: _blob(AppColors.secondary, 115)),
            Positioned(top: 300, left: -42, child: _blob(AppColors.accent, 132)),
            Positioned(bottom: 80, right: -55, child: _blob(AppColors.success, 145)),
          ],
        ),
      ),
    );
  }
  Widget _blob(Color color, double size) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.15)));
}



