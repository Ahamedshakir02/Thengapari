import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Definition for a single bottom-nav destination.
class _NavSpec {
  final IconData icon;
  final String label;
  const _NavSpec(this.icon, this.label);
}

/// Shared bottom-nav renderer used by all four role-specific bars. Keeps the
/// layout/interaction identical while each role passes its own palette and
/// destinations.
class _RoleNavBar extends StatelessWidget {
  final List<_NavSpec> items;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final Color background;
  final Color activeColor;
  final Color inactiveColor;
  final Color borderColor;

  const _RoleNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.background,
    required this.activeColor,
    required this.inactiveColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: background,
        border: Border(top: BorderSide(color: borderColor, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: [
              for (int i = 0; i < items.length; i++)
                Expanded(
                  child: _NavItem(
                    spec: items[i],
                    active: i == currentIndex,
                    activeColor: activeColor,
                    inactiveColor: inactiveColor,
                    onTap: onTap == null ? null : () => onTap!(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final _NavSpec spec;
  final bool active;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback? onTap;

  const _NavItem({
    required this.spec,
    required this.active,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : inactiveColor;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(spec.icon, size: 22, color: color),
          const SizedBox(height: 3),
          Text(
            spec.label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Homeowner: Home · Schedule · Reports · Profile (light, green accent).
class HomeownerBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  const HomeownerBottomNav({this.currentIndex = 0, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return _RoleNavBar(
      currentIndex: currentIndex,
      onTap: onTap,
      background: Colors.white,
      activeColor: AgriColors.green600,
      inactiveColor: const Color(0xFF908C7E),
      borderColor: AgriColors.border,
      items: const [
        _NavSpec(Icons.home_outlined, 'Home'),
        _NavSpec(Icons.calendar_today_outlined, 'Schedule'),
        _NavSpec(Icons.description_outlined, 'Reports'),
        _NavSpec(Icons.person_outline, 'Profile'),
      ],
    );
  }
}

/// Worker: Home · Jobs · Wallet · Profile (dark teal theme).
class WorkerBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  const WorkerBottomNav({this.currentIndex = 0, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return _RoleNavBar(
      currentIndex: currentIndex,
      onTap: onTap,
      background: const Color(0xFF0E5249),
      activeColor: const Color(0xFF9FE1CB),
      inactiveColor: Colors.white.withValues(alpha: 0.45),
      borderColor: Colors.white.withValues(alpha: 0.08),
      items: const [
        _NavSpec(Icons.home_outlined, 'Home'),
        _NavSpec(Icons.work_outline, 'Jobs'),
        _NavSpec(Icons.account_balance_wallet_outlined, 'Wallet'),
        _NavSpec(Icons.person_outline, 'Profile'),
      ],
    );
  }
}

/// Site Manager: Today · On-site · Earnings · Profile (light, green accent).
class SiteManagerBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  const SiteManagerBottomNav({this.currentIndex = 0, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return _RoleNavBar(
      currentIndex: currentIndex,
      onTap: onTap,
      background: Colors.white,
      activeColor: AgriColors.green600,
      inactiveColor: const Color(0xFF908C7E),
      borderColor: AgriColors.border,
      items: const [
        _NavSpec(Icons.today_outlined, 'Today'),
        _NavSpec(Icons.location_on_outlined, 'On-site'),
        _NavSpec(Icons.account_balance_wallet_outlined, 'Earnings'),
        _NavSpec(Icons.person_outline, 'Profile'),
      ],
    );
  }
}

/// B2B: Market · Orders · Savings (light, deep-blue accent).
class B2BBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  const B2BBottomNav({this.currentIndex = 0, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return _RoleNavBar(
      currentIndex: currentIndex,
      onTap: onTap,
      background: Colors.white,
      activeColor: AgriColors.blue600,
      inactiveColor: const Color(0xFF908C7E),
      borderColor: AgriColors.border,
      items: const [
        _NavSpec(Icons.storefront_outlined, 'Market'),
        _NavSpec(Icons.receipt_long_outlined, 'Orders'),
        _NavSpec(Icons.bar_chart_outlined, 'Savings'),
      ],
    );
  }
}
