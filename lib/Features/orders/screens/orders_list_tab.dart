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
import 'package:Tosell/Features/orders/screens/orders_screen.dart';

class OrdersListTab extends ConsumerStatefulWidget {
  final OrderFilter? filter;
  const OrdersListTab({super.key, this.filter});

  @override
  ConsumerState<OrdersListTab> createState() => _OrdersListTabState();
}

class _OrdersListTabState extends ConsumerState<OrdersListTab> {
  late OrderFilter _currentFilter;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.filter ?? OrderFilter();
  }

  @override
  void didUpdateWidget(covariant OrdersListTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filter != oldWidget.filter) {
      _currentFilter = widget.filter ?? OrderFilter();
      _clearMultiSelectMode();
    }
  }

  void _clearMultiSelectMode() {
    if (mounted) {
      ref.read(selectedOrdersProvider.notifier).state = <String>{};
      ref.read(isMultiSelectModeProvider.notifier).state = false;
    }
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

  void _handleOrderTap(Order order) {
    final isMultiSelectMode = ref.read(isMultiSelectModeProvider);
    
    if (isMultiSelectMode) {
      _toggleOrderSelection(order.id ?? '');
    } else {
      if (order.code != null) {
        context.push(AppRoutes.orderDetails, extra: order.code);
      }
    }
  }

  void _handleOrderLongPress(Order order) {
    if (!ref.read(isMultiSelectModeProvider) && _canSelectOrder(order)) {
      ref.read(isMultiSelectModeProvider.notifier).state = true;
      ref.read(selectedOrdersProvider.notifier).state = {order.id ?? ''};
    }
  }

  bool _canSelectOrder(Order order) {
    return order.id != null && order.status != null;
  }

  String _getSectionTitle() {
    if (_currentFilter.status != null && _currentFilter.status! < orderStatus.length) {
      final statusName = orderStatus[_currentFilter.status!].name ?? '';
      return 'الطلبات "$statusName"';
    } else if (_currentFilter.shipmentId != null) {
      return 'طلبات الشحنة';
    } else {
      return 'جميع الطلبات';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(ordersNotifierProvider);
    final isMultiSelectMode = ref.watch(isMultiSelectModeProvider);
    final selectedOrders = ref.watch(selectedOrdersProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            _buildSectionTitle(ordersState, isMultiSelectMode),
            
            const Gap(AppSpaces.small),
            
            // Multi-select helper text
            if (isMultiSelectMode) _buildMultiSelectHelperText(),
            
            // Orders list
            Expanded(
              child: ordersState.when(
                data: (orders) => _buildOrdersList(orders, isMultiSelectMode, selectedOrders),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => _buildErrorState(err.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(AsyncValue<List<Order>> ordersState, bool isMultiSelectMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ordersState.when(
              data: (orders) {
                final filteredCount = orders.length;
                final selectableCount = orders.where(_canSelectOrder).length;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getSectionTitle()} ($filteredCount)',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (isMultiSelectMode && selectableCount > 0)
                      Text(
                        'يمكن تحديد $selectableCount طلب',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                  ],
                );
              },
              loading: () => Text(
                '${_getSectionTitle()} (جاري التحميل...)',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              error: (_, __) => Text(
                _getSectionTitle(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (isMultiSelectMode)
            IconButton(
              onPressed: _clearMultiSelectMode,
              icon: Icon(Icons.close, color: Theme.of(context).colorScheme.primary),
              tooltip: 'إلغاء التحديد',
            ),
        ],
      ),
    );
  }

  Widget _buildMultiSelectHelperText() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: Theme.of(context).colorScheme.primary),
          const Gap(AppSpaces.small),
          Expanded(
            child: Text(
              'اضغط على الطلبات لتحديدها، أو اضغط مطولاً على أي طلب للدخول في وضع التحديد',
              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<Order> orders, bool isMultiSelectMode, Set<String> selectedOrders) {
    if (orders.isEmpty) return _buildNoItemsFound();

    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) => _buildOrderItem(orders[index], isMultiSelectMode, selectedOrders),
    );
  }

  Widget _buildOrderItem(Order order, bool isMultiSelectMode, Set<String> selectedOrders) {
    final isSelected = selectedOrders.contains(order.id);
    final canSelect = _canSelectOrder(order);
    
    return OrderCardItem(
      order: order,
      isMultiSelectMode: isMultiSelectMode,
      isSelected: isSelected && isMultiSelectMode,
      onTap: canSelect ? () => _handleOrderTap(order) : null,
      onSelectionToggle: canSelect && isMultiSelectMode ? () => _toggleOrderSelection(order.id ?? '') : null,
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
          const Gap(AppSpaces.medium),
          Text('حدث خطأ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.error)),
          const Gap(AppSpaces.small),
          Text(error, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
          const Gap(AppSpaces.medium),
          FillButton(
            label: 'إعادة المحاولة',
            onPressed: () {
              _clearMultiSelectMode();
              ref.read(ordersNotifierProvider.notifier).refresh();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNoItemsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/svg/NoItemsFound.gif', width: 240, height: 240),
          const Gap(AppSpaces.medium),
          Text(
            'لا توجد طلبات مضافة',
            style: context.textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xffE96363),
              fontSize: 24,
            ),
          ),
          const Gap(AppSpaces.small),
          Text(
            'اضغط على زر "جديد" لإضافة طلب جديد و ارساله الى زبونك',
            textAlign: TextAlign.center,
            style: context.textTheme.bodySmall!.copyWith(
              fontWeight: FontWeight.w500,
              color: const Color(0xff698596),
              fontSize: 16,
            ),
          ),
          const Gap(AppSpaces.large),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: FillButton(
              label: 'إضافة أول طلب',
              onPressed: () {
                _clearMultiSelectMode();
                context.push(AppRoutes.addOrder);
              },
              icon: SvgPicture.asset('assets/svg/navigation_add.svg', color: const Color(0xffFAFEFD)),
              reverse: true,
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}