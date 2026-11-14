import 'package:flutter/material.dart';

import 'divine_theme.dart';

class DivineBrandMark extends StatelessWidget {
  const DivineBrandMark({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 38 : 44,
          height: compact ? 38 : 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [DivineColors.saffron, DivineColors.maroon],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          alignment: Alignment.center,
          child: Text(
            'ॐ',
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 23 : 27,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (!compact) ...[
          const SizedBox(width: 11),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'DIVINE INDIA',
                style: TextStyle(
                  color: DivineColors.maroon,
                  letterSpacing: 1.2,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'Journeys of the soul',
                style: TextStyle(
                  color: DivineColors.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class DivineSectionHeading extends StatelessWidget {
  const DivineSectionHeading({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: DivineColors.ink,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    color: DivineColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel!,
              style: const TextStyle(
                color: DivineColors.saffronDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}

class DivineFeatureCard extends StatelessWidget {
  const DivineFeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.accent = DivineColors.saffron,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: DivineColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: DivineColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: accent, size: 22),
            ),
            const SizedBox(height: 13),
            Text(
              title,
              style: const TextStyle(
                color: DivineColors.ink,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(
                color: DivineColors.muted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DivineMetricCard extends StatelessWidget {
  const DivineMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.footnote,
  });

  final String label;
  final String value;
  final IconData icon;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DivineColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DivineColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: DivineColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(icon, color: DivineColors.templeGold, size: 19),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: DivineColors.maroon,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (footnote != null) ...[
            const SizedBox(height: 3),
            Text(
              footnote!,
              style: const TextStyle(
                color: DivineColors.muted,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class DivineStatusPill extends StatelessWidget {
  const DivineStatusPill({
    super.key,
    required this.label,
    this.color = DivineColors.success,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class DivineEmptyState extends StatelessWidget {
  const DivineEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: DivineColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: DivineColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 38, color: DivineColors.templeGold),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: DivineColors.ink,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: DivineColors.muted,
              height: 1.4,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
