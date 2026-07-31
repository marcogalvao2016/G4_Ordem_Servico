import 'package:flutter/material.dart';

class ElegantBadge extends StatelessWidget {
  const ElegantBadge({
    super.key,
    required this.label,
    this.icon,
    this.emphasis = false,
  });

  final String label;
  final IconData? icon;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = emphasis
        ? scheme.primaryContainer
        : scheme.surfaceContainerHighest;
    final foreground = emphasis
        ? scheme.onPrimaryContainer
        : scheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class ElegantListCard extends StatelessWidget {
  const ElegantListCard({
    super.key,
    required this.icon,
    required this.title,
    required this.badges,
    required this.onTap,
    required this.onDelete,
  });

  final IconData icon;
  final String title;
  final List<Widget> badges;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: scheme.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    if (badges.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 9),
                      Wrap(spacing: 7, runSpacing: 7, children: badges),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Excluir',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
