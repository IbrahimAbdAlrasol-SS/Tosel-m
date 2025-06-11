import 'package:gap/gap.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Tosell/core/constants/spaces.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:Tosell/core/widgets/FillButton.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Tosell/Features/orders/models/Order.dart';
import 'package:Tosell/paging/generic_paged_list_view.dart';
import 'package:Tosell/Features/orders/models/order_enum.dart';
import 'package:Tosell/Features/orders/models/OrderFilter.dart';
import 'package:Tosell/Features/orders/widgets/order_card_item.dart';
import 'package:Tosell/Features/orders/providers/orders_provider.dart';

// Import the providers from the main orders screen
import 'package:Tosell/Features/orders/screens/orders_screen.dart';

class OrdersListTab extends ConsumerStatefulWidget {
  final OrderFilter? filter;
  const OrdersListTab({super.key, this.filter});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OrdersListTabState();
}

class _OrdersListTabState extends ConsumerState<OrdersListTab> {
  late OrderFilter? _currentFilter;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.filter;
  }

  @override
  void didUpdateWidget(covariant OrdersListTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filter != oldWidget.filter) {
      _currentFilter = widget.filter ?? OrderFilter();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(ordersNotifierProvider);
    final isMultiSelectMode = ref.watch(isMultiSelectModeProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(AppSpaces.small),
            
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.filter == null
                    ? 'جميع الطلبات'
                    : 'طلبات "${orderStatus[widget.filter?.status ?? 0].name}"',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const Gap(AppSpaces.small),
            
            // Orders list
            ordersState.when(
              data: (data) => _buildUi(data, isMultiSelectMode),
              loading: () => const Expanded(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Expanded(
                child: Center(child: Text(err.toString())),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Expanded _buildUi(List<Order> data, bool isMultiSelectMode) {
    return Expanded(
      child: GenericPagedListView(
        key: ValueKey('${widget.filter?.toJson()}_$isMultiSelectMode'),
        noItemsFoundIndicatorBuilder: _buildNoItemsFound(),
        fetchPage: (pageKey, _) async {
          return await ref.read(ordersNotifierProvider.notifier).getAll(
            page: pageKey,
            queryParams: _currentFilter?.toJson(),
          );
        },
        itemBuilder: (context, order, index) => EnhancedOrderCardItem(
          order: order,
          isMultiSelectMode: isMultiSelectMode,
          onTap: () {
            if (isMultiSelectMode) {
              _toggleOrderSelection(order.id!);
            } else {
              context.push(AppRoutes.orderDetails, extra: order.code);
            }
          },
        ),
      ),
    );
  }

  void _toggleOrderSelection(String orderId) {
    final selectedOrders = ref.read(selectedOrdersProvider);
    final newSelection = Set<String>.from(selectedOrders);
    
    if (newSelection.contains(orderId)) {
      newSelection.remove(orderId);
    } else {
      newSelection.add(orderId);
    }
    
    ref.read(selectedOrdersProvider.notifier).state = newSelection;
  }

  Widget _buildNoItemsFound() {
    return Column(
      children: [
        Image.asset('assets/svg/NoItemsFound.gif', width: 240, height: 240),
        Text(
          'لا توجد طلبات مضافة',
          style: context.textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xffE96363),
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'اضغط على زر "جديد" لإضافة طلب جديد و ارساله الى زبونك',
          style: context.textTheme.bodySmall!.copyWith(
            fontWeight: FontWeight.w500,
            color: const Color(0xff698596),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: FillButton(
            label: 'إضافة اول طلب',
            onPressed: () => context.push(AppRoutes.addOrder),
            icon: SvgPicture.asset('assets/svg/navigation_add.svg',
                color: const Color(0xffFAFEFD)),
            reverse: true,
          ),
        )
      ],
    );
  }
}

// Enhanced Order Card Item with multi-select support
class EnhancedOrderCardItem extends ConsumerWidget {
  final Order order;
  final bool isMultiSelectMode;
  final VoidCallback onTap;

  const EnhancedOrderCardItem({
    required this.order,
    required this.isMultiSelectMode,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedOrders = ref.watch(selectedOrdersProvider);
    final isSelected = selectedOrders.contains(order.id);
    final theme = Theme.of(context);
    
    DateTime date = DateTime.parse(order.creationDate ?? DateTime.now().toString());

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.05)
                : const Color(0xffEAEEF0),
            borderRadius: BorderRadius.circular(24),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        // Icon container
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(1000),
                            color: theme.colorScheme.surface,
                          ),
                          child: SvgPicture.asset(
                            "assets/svg/box.svg",
                            width: 24,
                            height: 24,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.primary,
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Order info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.code ?? "لايوجد",
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
                        
                        // Status badge
                        _buildOrderStatus(order.status ?? 0),
                        
                        const Gap(AppSpaces.small),
                      ],
                    ),
                  ),
                  
                  // Order details container
                  Container(
                    margin: const EdgeInsets.only(left: 2, right: 2, bottom: 2),
                    padding: const EdgeInsets.all(12),
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
                              _buildSection(
                                order.customerName ?? "لايوجد",
                                "assets/svg/User.svg",
                                theme,
                              ),
                              VerticalDivider(
                                width: 1,
                                thickness: 1,
                                color: theme.colorScheme.outline,
                              ),
                              const Gap(AppSpaces.small),
                              _buildSection(
                                order.content ?? "لايوجد",
                                "assets/svg/box.svg",
                                theme,
                              ),
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
                              _buildSection(
                                order.deliveryZone?.governorate?.name ?? "لايوجد",
                                "assets/svg/MapPinLine.svg",
                                theme,
                              ),
                              VerticalDivider(
                                width: 1,
                                thickness: 1,
                                color: theme.colorScheme.outline,
                              ),
                              const Gap(AppSpaces.small),
                              _buildSection(
                                order.deliveryZone?.name ?? "لايوجد",
                                "assets/svg/MapPinArea.svg",
                                theme,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Selection indicator
              if (isMultiSelectMode)
                Positioned(
                  top: 8,
                  right: 8,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderStatus(int index) {
    return Container(
      width: 100,
      height: 26,
      decoration: BoxDecoration(
        color: orderStatus[index].color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          orderStatus[index].name!,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String iconPath, ThemeData theme) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              width: 24,
              height: 24,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
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
          ],
        ),
      ),
    );
  }
}