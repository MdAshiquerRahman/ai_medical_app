import 'package:flutter/material.dart';

class UnitToggleButton extends StatelessWidget {
  final String unit1;
  final String unit2;
  final String selectedUnit;
  final ValueChanged<String> onUnitChanged;
  final bool enabled;

  const UnitToggleButton({
    super.key,
    required this.unit1,
    required this.unit2,
    required this.selectedUnit,
    required this.onUnitChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF3C3C3C)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildUnitButton(unit1),
          Container(width: 1, height: 32, color: const Color(0xFF3C3C3C)),
          _buildUnitButton(unit2),
        ],
      ),
    );
  }

  Widget _buildUnitButton(String unit) {
    final isSelected = selectedUnit == unit;
    return InkWell(
      onTap: enabled ? () => onUnitChanged(unit) : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDC143C) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          unit,
          style: TextStyle(
            color: enabled
                ? (isSelected ? Colors.white : const Color(0xFFB0B0B0))
                : const Color(0xFF505050),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
