import 'dart:ui';
import 'package:Tosell/Features/orders/screens/orders_list_tab.dart';
import 'package:Tosell/Features/orders/screens/shipment_list_tab.dart';
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
import 'package:Tosell/core/widgets/CustomTextFormField.dart';
import 'package:Tosell/Features/orders/models/order_enum.dart';
import 'package:Tosell/Features/orders/models/OrderFilter.dart';
import 'package:Tosell/Features/orders/widgets/order_card_item.dart';
import 'package:Tosell/Features/orders/providers/orders_provider.dart';
import 'package:Tosell/Features/orders/screens/orders_filter_bottom_sheet.dart';
import 'package:Tosell/Features/orders/models/Shipment.dart';
import 'package:Tosell/Features/orders/providers/shipments_provider.dart';
import 'package:Tosell/Features/orders/services/shipments_service.dart';
import 'package:Tosell/core/utils/GlobalToast.dart';

// ✅ Simplified Global Providers
final selectedOrdersProvider = StateProvider<Set<String>>((ref) => <String>{});
final isMultiSelectModeProvider = StateProvider<bool>((ref) => false);

class OrdersScreen extends ConsumerStatefulWidget {
  final OrderFilter? filter;
  const OrdersScreen({super.key, this.filter});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with SingleTickerProviderStateMixin {
  
  late TabController _tabController;
  late OrderFilter _currentFilter;
  int _currentTabIndex = 0;
  bool _isCreatingShipment = false;
  
  final TextEditingController _searchController = TextEditingController();
  final ShipmentsService _shipmentsService = ShipmentsService();

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.filter ?? OrderFilter();
    
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
      _clearMultiSelect();
    }
  }

  void _clearMultiSelect() {
    ref.read(selectedOrdersProvider.notifier).state = <String>{};
    ref.read(isMultiSelectModeProvider.notifier).state = false;
  }

  void _handleSearch(String searchTerm) {
    _clearMultiSelect();
    _searchController.text = searchTerm;
    
    final filter = OrderFilter(
      code: searchTerm.isNotEmpty ? searchTerm : null,
      shipmentCode: searchTerm.isNotEmpty ? searchTerm : null,
    );
    
    if (_currentTabIndex == 0) {
      ref.read(ordersNotifierProvider.notifier).refresh(queryParams: filter.toJson());
    } else {
      ref.read(shipmentsNotifierProvider.notifier).refresh(queryParams: filter.toJson());
    }
  }

  Future<void> _createShipment() async {
    final selectedOrders = ref.read(selectedOrdersProvider);
    if (selectedOrders.isEmpty) {
      GlobalToast.show(message: 'يرجى تحديد طلبات للشحن');
      return;
    }

    setState(() => _isCreatingShipment = true);

    try {
      final shipmentData = {
        "delivered": false,
        "orders": selectedOrders.map((id) => {"orderId": id}).toList(),
        "priority": 0
      };

      final result = await _shipmentsService.createPickupShipment(shipmentData);

      if (result.$1 != null) {
        GlobalToast.showSuccess(message: 'تم إنشاء الشحنة بنجاح');
        _clearMultiSelect();
        
        // Refresh both tabs
        ref.read(ordersNotifierProvider.notifier).refresh();
        ref.read(shipmentsNotifierProvider.notifier).refresh();
      } else {
        GlobalToast.show(message: result.$2 ?? 'فشل في إنشاء الشحنة', backgroundColor: Colors.red);
      }
    } catch (e) {
      GlobalToast.show(message: 'حدث خطأ: ${e.toString()}', backgroundColor: Colors.red);
    } finally {
      setState(() => _isCreatingShipment = false);
    }
  }

  void _showFilterBottomSheet() {
    _clearMultiSelect();
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (_) => const OrdersFilterBottomSheet(),
    ).then((result) {
      if (result != null && result is OrderFilter) {
        setState(() => _currentFilter = result);
        ref.read(ordersNotifierProvider.notifier).refresh(queryParams: _currentFilter.toJson());
        ref.read(shipmentsNotifierProvider.notifier).refresh(queryParams: _currentFilter.toJson());
      }
    });
  }

  void _selectAllOrders() {
    final ordersState = ref.read(ordersNotifierProvider);
    ordersState.whenData((orders) {
      final allOrderIds = orders.where((order) => order.id != null).map((order) => order.id!).toSet();
      ref.read(selectedOrdersProvider.notifier).state = allOrderIds;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMultiSelectMode = ref.watch(isMultiSelectModeProvider);
    final selectedOrders = ref.watch(selectedOrdersProvider);

    // ✅ Clear multi-select on provider errors
    ref.listen(ordersNotifierProvider, (previous, next) {
      next.whenOrNull(error: (error, stackTrace) => _clearMultiSelect());
    });

    return PopScope(
      canPop: !isMultiSelectMode,
      onPopInvoked: (didPop) {
        if (!didPop && isMultiSelectMode) _clearMultiSelect();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              const Gap(AppSpaces.large),

              // Search Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomTextFormField(
                        controller: _searchController,
                        label: '',
                        showLabel: false,
                        hint: _currentTabIndex == 0 ? 'رقم الطلب' : 'رقم الوصل',
                        prefixInner: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            'assets/svg/search.svg',
                            color: Theme.of(context).colorScheme.primary,
                            width: 24,
                            height: 24,
                          ),
                        ),
                        onChanged: _handleSearch,
                      ),
                    ),
                    const Gap(AppSpaces.small),
                    
                    // Multi-select button (orders tab only)
                    if (_currentTabIndex == 0)
                      GestureDetector(
                        onTap: () {
                          final current = ref.read(isMultiSelectModeProvider);
                          ref.read(isMultiSelectModeProvider.notifier).state = !current;
                          if (current) _clearMultiSelect();
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: isMultiSelectMode
                                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                                : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isMultiSelectMode
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          child: Icon(
                            isMultiSelectMode ? Icons.close : Icons.checklist,
                            color: Theme.of(context).colorScheme.primary,
                            size: 24,
                          ),
                        ),
                      ),
                    
                    const Gap(AppSpaces.small),
                    
                    // Filter button
                    GestureDetector(
                      onTap: _showFilterBottomSheet,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).colorScheme.outline),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SvgPicture.asset(
                            'assets/svg/Funnel.svg',
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(AppSpaces.medium),

              // Tab Bar or Multi-select Header
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isMultiSelectMode
                    ? Container(
                        key: const ValueKey('multiselect'),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.checklist, color: Theme.of(context).colorScheme.primary),
                            const Gap(AppSpaces.small),
                            Expanded(child: Text('تم تحديد ${selectedOrders.length} طلب')),
                            TextButton(onPressed: _selectAllOrders, child: const Text('تحديد الكل')),
                            TextButton(
                              onPressed: () => ref.read(selectedOrdersProvider.notifier).state = <String>{},
                              child: const Text('إلغاء الكل'),
                            ),
                            IconButton(onPressed: _clearMultiSelect, icon: const Icon(Icons.close)),
                          ],
                        ),
                      )
                    : Container(
                        key: const ValueKey('tabbar'),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(child: _buildTab(0, "الطلبات")),
                            Expanded(child: _buildTab(1, "الشحنات")),
                          ],
                        ),
                      ),
              ),

              const Gap(AppSpaces.medium),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    OrdersListTab(filter: _currentFilter),
                    shipmentInfoTab(filter: _currentFilter),
                  ],
                ),
              ),

              // Create shipment button
              if (isMultiSelectMode && selectedOrders.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _clearMultiSelect,
                          child: const Text('إلغاء'),
                        ),
                      ),
                      const Gap(AppSpaces.medium),
                      Expanded(
                        flex: 2,
                        child: FillButton(
                          label: _isCreatingShipment
                              ? 'جاري إنشاء الشحنة...'
                              : 'إنشاء شحنة (${selectedOrders.length})',
                          onPressed: _createShipment,
                          icon: _isCreatingShipment
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                )
                              : const Icon(Icons.local_shipping, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    final isSelected = _currentTabIndex == index;
    
    return GestureDetector(
      onTap: () => _tabController.animateTo(index),
      child: Column(
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(AppSpaces.small),
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.secondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
          const Gap(AppSpaces.small),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}