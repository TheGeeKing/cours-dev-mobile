import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todos/controllers/font_settings_controller.dart';

// ── Constants ─────────────────────────────────────────────────────────────────

const _fontFamilies = [
  'Roboto',
  'Inter',
  'Lato',
  'Montserrat',
  'Poppins',
  'Merriweather',
  'Nunito',
  'Source Code Pro',
];

const _fontWeights = [
  (label: 'Léger', value: FontWeight.w300),
  (label: 'Normal', value: FontWeight.w400),
  (label: 'Moyen', value: FontWeight.w500),
  (label: 'Semi-gras', value: FontWeight.w600),
  (label: 'Gras', value: FontWeight.w700),
];

const _fontSizes = [
  (label: 'P', value: 0.875),
  (label: 'M', value: 1.0),
  (label: 'G', value: 1.125),
  (label: 'TG', value: 1.25),
];

// ── Page ──────────────────────────────────────────────────────────────────────

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = FontSettingsScope.of(context);
    final settings = controller.settings;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres d\'affichage')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        children: [
          // ── Font Family ────────────────────────────────────────────────
          _SectionHeader(title: 'Police', icon: Icons.font_download_outlined),
          const SizedBox(height: 12),
          SizedBox(
            height: 84,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _fontFamilies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final family = _fontFamilies[i];
                return _FontFamilyCard(
                  family: family,
                  isSelected: settings.fontFamily == family,
                  onTap: () => controller.updateFontFamily(family),
                );
              },
            ),
          ),

          // ── Font Weight ────────────────────────────────────────────────
          const SizedBox(height: 28),
          _SectionHeader(title: 'Graisse', icon: Icons.format_bold_rounded),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _fontWeights.map((w) {
                final isSelected = settings.fontWeight == w.value;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(w.label),
                    selected: isSelected,
                    onSelected: (_) => controller.updateFontWeight(w.value),
                  ),
                );
              }).toList(),
            ),
          ),

          // ── Font Size ──────────────────────────────────────────────────
          const SizedBox(height: 28),
          _SectionHeader(title: 'Taille', icon: Icons.format_size_rounded),
          const SizedBox(height: 12),
          SegmentedButton<double>(
            segments: _fontSizes
                .map(
                  (s) => ButtonSegment<double>(
                    value: s.value,
                    label: Text(s.label),
                  ),
                )
                .toList(),
            selected: {settings.fontSizeScale},
            onSelectionChanged: (val) =>
                controller.updateFontSizeScale(val.first),
          ),

          // ── Live Preview ───────────────────────────────────────────────
          const SizedBox(height: 36),
          _SectionHeader(title: 'Aperçu', icon: Icons.preview_outlined),
          const SizedBox(height: 12),
          _PreviewCard(theme: theme),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _FontFamilyCard extends StatelessWidget {
  const _FontFamilyCard({
    required this.family,
    required this.isSelected,
    required this.onTap,
  });

  final String family;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 112,
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surface,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Aa',
              style: GoogleFonts.getFont(
                family,
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                family,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Portez ce vieux whisky', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'au juge blond qui fume. 0123456789',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'abcdefghijklmnopqrstuvwxyz',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
