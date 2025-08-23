import 'package:flutter/material.dart';

class FeatureCard extends StatelessWidget {
  final String title;
  final String caption;
  final IconData icon;
  final VoidCallback onTap;
  final bool accentBlend;

  const FeatureCard({
    super.key,
    required this.title,
    required this.caption,
    required this.icon,
    required this.onTap,
    this.accentBlend = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final deco = BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: LinearGradient(
        colors: accentBlend
            ? [cs.primary.withOpacity(.13), cs.secondary.withOpacity(.13)]
            : [cs.primary.withOpacity(.10), cs.primary.withOpacity(.05)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(color: cs.primary.withOpacity(.10)),
    );

    return Semantics(
      button: true,
      label: title,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          decoration: deco,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 34, color: cs.primary),
              const Spacer(),
              Text(title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(caption, style: TextStyle(color: Colors.black.withOpacity(.6))),
            ],
          ),
        ),
      ),
    );
  }
}
