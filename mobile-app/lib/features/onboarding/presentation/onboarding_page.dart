import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qishloq_ai_mobile/shared/widgets/app_button.dart';
import 'package:qishloq_ai_mobile/shared/widgets/app_card.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QISHLOQ AI'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Platformamiz afzalliklari',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: const [
                    AppCard(
                      title: 'E’lonlar',
                      subtitle: 'Qishloq xo‘jaligi mahsulotlari, texnika va xizmatlarni soting yoki ijaraga oling.',
                      icon: Icons.campaign,
                    ),
                    SizedBox(height: 12),
                    AppCard(
                      title: 'AI maslahat',
                      subtitle: 'Sun’iy intellekt yordamida agronomik va veterinariya savollaringizga tezkor javob oling.',
                      icon: Icons.psychology,
                    ),
                    SizedBox(height: 12),
                    AppCard(
                      title: 'Fermerlar uchun qulay platforma',
                      subtitle: 'Barcha agrobiznes ehtiyojlaringizni bitta ilovada jamlang va boshqaring.',
                      icon: Icons.spa,
                    ),
                  ],
                ),
              ),
              AppButton(
                label: 'Davom etish',
                fullWidth: true,
                onPressed: () {
                  context.go('/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
