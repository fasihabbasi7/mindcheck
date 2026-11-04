import 'package:flutter/material.dart';

import '../app/theme/app_theme.dart';
import '../utils/app_strings.dart';
import '../utils/constants.dart';

/// One tab in the bottom navigation bar.
class NavItem {
  const NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// The four main tabs of MindCheck.
const List<NavItem> mainNavItems = <NavItem>[
  NavItem(
    label: AppStrings.tabHome,
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
  ),
  NavItem(
    label: AppStrings.tabAssessments,
    icon: Icons.grid_view_outlined,
    selectedIcon: Icons.grid_view_rounded,
  ),
  NavItem(
    label: AppStrings.tabHistory,
    icon: Icons.history_rounded,
    selectedIcon: Icons.history_rounded,
  ),
  NavItem(
    label: AppStrings.tabSettings,
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings_rounded,
  ),
];

/// Floating, pill-shaped bottom navigation bar.
/// The selected tab expands into a purple pill showing its label.
class MindBottomNav extends StatelessWidget {
  const MindBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items = mainNavItems,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavItem> items;

  @override
  Widget build(BuildContext context) {
    final MindColors mind = context.mind;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
        child: Container(
          height: 68,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: mind.glassBorder),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: mind.cardShadow,
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              for (int i = 0; i < items.length; i++)
                Expanded(
                  // The selected tab gets more room for its label.
                  flex: i == currentIndex ? 2 : 1,
                  child: _NavButton(
                    item: items[i],
                    selected: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDurations.medium,
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: selected ? colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                selected ? item.selectedIcon : item.icon,
                size: 22,
                color: selected ? colors.onPrimary : colors.onSurfaceVariant,
              ),
              if (selected) ...<Widget>[
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: context.textStyles.labelMedium?.copyWith(
                      color: colors.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
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
