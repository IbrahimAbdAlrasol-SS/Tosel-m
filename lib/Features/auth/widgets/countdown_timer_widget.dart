import 'package:flutter/material.dart';
import '../models/AccountLockStatus.dart';

class CountdownTimerWidget extends StatelessWidget {
  final AccountLockStatus lockStatus;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final double? borderRadius;

  const CountdownTimerWidget({
    super.key,
    required this.lockStatus,
    this.textStyle,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = lockStatus.remainingTime;

    if (remaining == Duration.zero) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
          border: Border.all(color: Colors.red, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'تم رفض طلبك',
              style: textStyle?.copyWith(color: Colors.red) ??
                  const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
            ),
          ],
        ),
      );
    }

    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTimeUnit(hours.toString().padLeft(2, '0'), 'ساعة'),
          _buildSeparator(),
          _buildTimeUnit(minutes.toString().padLeft(2, '0'), 'دقيقة'),
          _buildSeparator(),
          _buildTimeUnit(seconds.toString().padLeft(2, '0'), 'ثانية'),
        ],
      ),
    );
  }

  Widget _buildTimeUnit(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            value,
            style: textStyle?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ) ??
                TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator() {
    return const Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 50,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
