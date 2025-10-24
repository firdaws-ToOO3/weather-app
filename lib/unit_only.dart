import 'package:flutter/material.dart';
import '../main.dart'; // ใช้ TempUnit, UnitScope, AppColors

/// เรียกใช้ได้จากทุกหน้า: await showUnitPicker(context);
Future<void> showUnitPicker(BuildContext context) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: false,
    backgroundColor: Colors.transparent,
    builder: (_) => const _UnitPickerSheet(),
  );
}

class _UnitPickerSheet extends StatelessWidget {
  const _UnitPickerSheet();

  @override
  Widget build(BuildContext context) {
    final notifier = UnitScope.of(context);
    final current = notifier.value;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0x22EA5CA0), Color(0x227D6EF0)], // โทนชมพู–ม่วงจาง ๆ
        ),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 24, offset: Offset(0, -8))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 44, height: 5,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.black12, borderRadius: BorderRadius.circular(100),
              ),
            ),
            const Text('Select Temperature Unit',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                selectionColor: Colors.black,
            ),
            const SizedBox(height: 12),
            SegmentedButton<TempUnit>(
              segments: const [
                ButtonSegment<TempUnit>(value: TempUnit.celsius,    label: Text('°C')),
                ButtonSegment<TempUnit>(value: TempUnit.fahrenheit, label: Text('°F')),
                ButtonSegment<TempUnit>(value: TempUnit.kelvin,     label: Text('K')),
              ],
              selected: {current},
            onSelectionChanged: (s) => notifier.value = s.first,
            style: ButtonStyle(
              // สีตัวอักษร
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return Colors.white;     // ขณะเลือก
                if (states.contains(WidgetState.disabled)) return Colors.white54;    // ถูกปิด
                return const Color(0xFFEA5CA0);                                      // ปกติ (ชมพู)
              }),
              // สีพื้นหลัง (ถ้าต้องการ)
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                return states.contains(WidgetState.selected)
                    ? const Color(0xFFB07BD9).withOpacity(.28)   // ม่วงอ่อนตอนเลือก
                    : Colors.white.withOpacity(.10);             // ปกติ
              }),
              // เส้นขอบ
              side: WidgetStateProperty.all(
                BorderSide(color: Colors.white.withOpacity(.35)),
              ),
            ),
                      ),
            const SizedBox(height: 12),
            Text('Current: ${notifier.value.label}',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
