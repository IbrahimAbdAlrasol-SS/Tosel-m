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

// ✅ Import the global providers from orders_screen.dart
final selectedOrdersProvider = StateProvider<Set<String>>((ref) => <String>{});
final isMultiSelectModeProvider = StateProvider<bool>((ref) => false);
final ordersSearchProvider = StateProvider<String>((ref) => '');

class OrdersListTab extends ConsumerStatefulWidget {
  final OrderFilter? filter;
  const OrdersListTab({super.key, this.filter});

  @override
  ConsumerState<OrdersListTab> createState() => _OrdersListTabState();
}

class _OrdersListTabState extends ConsumerState<OrdersListTab> {
  // ✅ Current filter - updated from parent screen
  late OrderFilter _currentFilter;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.filter ?? OrderFilter();
  }

  @override
  void didUpdateWidget(covariant OrdersListTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // ✅ Update filter when parent changes it
    if (widget.filter != oldWidget.filter) {
      _currentFilter = widget.filter ?? OrderFilter();
    }
  }

  /// ✅ Toggle order selection in multi-select mode
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

  /// ✅ Get section title based on current filter
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
    final searchTerm = ref.watch(ordersSearchProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Section title with orders count
            _buildSectionTitle(ordersState),
            
            const Gap(AppSpaces.small),
            
            // ✅ Orders list
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

  /// ✅ Build section title with orders count
  Widget _buildSectionTitle(AsyncValue<List<Order>> ordersState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ordersState.when(
        data: (orders) {
          final filteredCount = orders.length;
          return Text(
            '${_getSectionTitle()} ($filteredCount)',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          );
        },
        loading: () => Text(
          '${_getSectionTitle()} (جاري التحميل...)',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        error: (_, __) => Text(
          _getSectionTitle(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// ✅ Build orders list with multi-select support
  Widget _buildOrdersList(
    List<Order> orders, 
    bool isMultiSelectMode, 
    Set<String> selectedOrders
  ) {
    if (orders.isEmpty) {
      return _buildNoItemsFound();
    }

    return GenericPagedListView<Order>(
      key: ValueKey('${_currentFilter.toJson()}_${isMultiSelectMode}'),
      fetchPage: (pageKey, _) async {
        return await ref.read(ordersNotifierProvider.notifier).getAll(
          page: pageKey,
          queryParams: _currentFilter.toJson(),
        );
      },
      itemBuilder: (context, order, index) => _buildOrderItem(
        order, 
        isMultiSelectMode, 
        selectedOrders
      ),
      noItemsFoundIndicatorBuilder: _buildNoItemsFound(),
    );
  }

  /// ✅ Build individual order item with selection support
  Widget _buildOrderItem(
    Order order, 
    bool isMultiSelectMode, 
    Set<String> selectedOrders
  ) {
    final isSelected = selectedOrders.contains(order.id);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMultiSelectMode && isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          // ✅ Main order card
          OrderCardItem(
            order: order,
            onTap: isMultiSelectMode 
                ? () => _toggleOrderSelection(order.id ?? '')
                : () => context.push(AppRoutes.orderDetails, extra: order.code),
          ),
          
          // ✅ Selection indicator in multi-select mode
          if (isMultiSelectMode)
            Positioned(
              top: 8,
              right: 8,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white,
                  border: Border.all(
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
        ],
      ),
    );
  }

  /// ✅ Build error state
  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const Gap(AppSpaces.medium),
          Text(
            'حدث خطأ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const Gap(AppSpaces.small),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const Gap(AppSpaces.medium),
          FillButton(
            label: 'إعادة المحاولة',
            onPressed: () {
              // ✅ Retry loading via provider
              ref.read(ordersNotifierProvider.notifier).refresh(
                queryParams: _currentFilter.toJson(),
              );
            },
          ),
        ],
      ),
    );
  }

  /// ✅ Build no items found state
  Widget _buildNoItemsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/svg/NoItemsFound.gif', 
            width: 240, 
            height: 240
          ),
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
              onPressed: () => context.push(AppRoutes.addOrder),
              icon: SvgPicture.asset(
                'assets/svg/navigation_add.svg',
                color: const Color(0xffFAFEFD)
              ),
              reverse: true,
            ),
          )
        ],
      ),
    );
  }
}