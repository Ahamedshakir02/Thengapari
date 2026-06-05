import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Online/Offline pill on the Worker home screen.
///
/// The plan wires this to a `workerAvailabilityProvider` (Firestore-backed).
/// That provider does not exist yet, so this foundation widget is
/// self-contained: it manages its own state from [initialValue] and reports
/// changes via [onChanged]. When feature work begins, swap the internal state
/// for the provider without changing the visuals.
class WorkerAvailabilityToggle extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool>? onChanged;

  const WorkerAvailabilityToggle({
    this.initialValue = false,
    this.onChanged,
    super.key,
  });

  @override
  State<WorkerAvailabilityToggle> createState() =>
      _WorkerAvailabilityToggleState();
}

class _WorkerAvailabilityToggleState extends State<WorkerAvailabilityToggle> {
  late bool _isOnline = widget.initialValue;

  void _toggle() {
    setState(() => _isOnline = !_isOnline);
    widget.onChanged?.call(_isOnline);
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = _isOnline;
    return GestureDetector(
      onTap: _toggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isOnline ? AgriColors.green50 : AgriColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isOnline ? AgriColors.green100 : AgriColors.border,
            width: 0.5,
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline ? AgriColors.green400 : const Color(0xFFB4B2A9),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isOnline ? 'Online' : 'Offline',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isOnline ? AgriColors.green600 : const Color(0xFF5F5E5A),
            ),
          ),
        ]),
      ),
    );
  }
}
