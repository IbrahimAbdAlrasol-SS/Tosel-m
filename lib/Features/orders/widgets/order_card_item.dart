import 'package:gap/gap.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:Tosell/core/constants/spaces.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Tosell/Features/orders/models/Order.dart';
import 'package:Tosell/Features/orders/models/order_enum.dart';
import 'package:Tosell/Features/orders/screens/orders_screen.dart';

class OrderCardItem extends ConsumerWidget {
  final Order order;
  final Function? onTap;
  final bool isMultiSelectMode;
  final bool isSelected;
  final VoidCallback? onSelectionToggle;

  const OrderCardItem({
    required this.order,
    this.onTap,
    this.isMultiSelectMode = false,
    this.isSelected = false,
    this.onSelectionToggle,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = Theme.of(context);
    DateTime date = DateTime.parse(order.creationDate ?? DateTime.now().toString());
    
    final canSelect = order.id != null && order.status != null;

    return GestureDetector(
      onTap: () {
        if (isMultiSelectMode && canSelect) {
          onSelectionToggle?.call();
        } else {
          onTap?.call();
        }
      },
      onLongPress: canSelect ? onSelectionToggle : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2), // Reduce spacing
        padding: const EdgeInsets.only(right: 2, left: 2, bottom: 2),
        decoration: BoxDecoration(
          border: Border.all(
            color: isMultiSelectMode && isSelected 
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: isMultiSelectMode && isSelected ? 2 : 1,
          ),
          color: isMultiSelectMode && isSelected 
              ? theme.colorScheme.primary.withOpacity(0.1)
              : const Color(0xffEAEEF0),
          borderRadius: BorderRadius.circular(24),
          boxShadow: isMultiSelectMode && isSelected ? [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 2,
            )
          ] : null,
        ),
        child: Stack(
          children: [
            // Main content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1000),
                              color: theme.colorScheme.surface,
                            ),
                            child: SvgPicture.asset(
                              "assets/svg/box.svg",
                              width: 24,
                              height: 24,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.code ?? "N/A",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Tajawal",
                                  ),
                                ),
                                Text(
                                  "${date.day}.${date.month}.${date.year}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.colorScheme.secondary,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "Tajawal",
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildOrderStatus(order.status ?? 0),
                          const Gap(AppSpaces.small),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildSection(
                              order.customerName ?? "N/A",
                              "assets/svg/User.svg",
                              theme,
                            ),
                            VerticalDivider(
                              width: 1,
                              thickness: 1,
                              color: theme.colorScheme.outline,
                            ),
                            const Gap(AppSpaces.small),
                            buildSection(order.content ?? "N/A",
                                "assets/svg/box.svg", theme),
                          ],
                        ),
                      ),
                      Container(
                        height: 1,
                        width: double.infinity,
                        color: theme.colorScheme.outline,
                      ),
                      IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildSection(
                                order.deliveryZone?.governorate?.name ?? "N/A",
                                "assets/svg/MapPinLine.svg",
                                theme),
                            VerticalDivider(
                              width: 1,
                              thickness: 1,
                              color: theme.colorScheme.outline,
                            ),
                            const Gap(AppSpaces.small),
                            buildSection(order.deliveryZone?.name ?? "N/A",
                                "assets/svg/MapPinArea.svg", theme),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Multi-select checkbox
            if (isMultiSelectMode)
              Positioned(
                top: 8,
                right: 8,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected 
                        ? theme.colorScheme.primary
                        : Colors.white,
                    border: Border.all(
                      color: isSelected 
                          ? theme.colorScheme.primary
                          : canSelect
                              ? theme.colorScheme.outline
                              : theme.colorScheme.outline.withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                      : canSelect
                          ? null
                          : Icon(
                              Icons.block,
                              size: 18,
                              color: theme.colorScheme.outline.withOpacity(0.5),
                            ),
                ),
              ),
              
            // Non-selectable overlay
            if (isMultiSelectMode && !canSelect)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatus(int index) {
    // Ensure index is within bounds
    int statusIndex = index;
    if (statusIndex < 0 || statusIndex >= orderStatus.length) {
      statusIndex = 0; // Use default status
    }
    
    // Debug print for status
    print('Order status index: $index, using statusIndex: $statusIndex, status name: ${orderStatus[statusIndex].name}');
    
    return Container(
      width: 100,
      height: 26,
      decoration: BoxDecoration(
        color: orderStatus[statusIndex].color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          orderStatus[statusIndex].name!,
          style: TextStyle(
            color: orderStatus[statusIndex].textColor ?? Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

Widget buildSection(
  String title,
  String iconPath,
  ThemeData theme, {
  bool isRed = false,
  bool isGray = false,
  void Function()? onTap,
  EdgeInsets? padding,
  double? textWidth,
}) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Padding(
              padding: padding ?? const EdgeInsets.all(0),
              child: SvgPicture.asset(
                iconPath,
                width: 24,
                height: 24,
                color: isRed
                    ? theme.colorScheme.error
                    : isGray
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                width: textWidth,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: theme.colorScheme.secondary,
                    fontFamily: "Tajawal",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}