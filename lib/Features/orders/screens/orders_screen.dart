import 'dart:ui';
import 'package:Tosell/Features/auth/register/screens/user_info_tab.dart';
import 'package:Tosell/Features/orders/screens/orders_list_tab.dart';
import 'package:Tosell/Features/orders/screens/shipment_list_tab.dart';
import 'package:Tosell/paging/generic_paged_list_view.dart';
import 'package:Tosell/Features/orders/widgets/shipment_cart_Item.dart';
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

// StateProvider for multi-select functionality
final selectedOrdersProvider = StateProvider<Set<String>>((ref) => <String>{});
final isMultiSelectModeProvider = StateProvider<bool>((ref) => false);

class OrdersScreen extends ConsumerStatefulWidget {
  final OrderFilter? filter;
  const OrdersScreen({super.key, this.filter});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with TickerProviderStateMixin {
  late OrderFilter? _currentFilter;
  late TabController _tabController;
  int _currentIndex = 0;
  final ShipmentsService _shipmentsService = ShipmentsService();
  bool _isCreatingShipment = false;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.filter;
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _fetchInitialData();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentIndex = _tabController.index;
      });
    }
  }

  void _fetchInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch orders
      ref.read(ordersNotifierProvider.notifier).getAll(
            page: 1,
            queryParams: _currentFilter?.toJson(),
          );
      // Fetch shipments
      ref.read(shipmentsNotifierProvider.notifier).getAll(
            page: 1,
            queryParams: _currentFilter?.toJson(),
          );
    });
  }

  @override
  void didUpdateWidget(covariant OrdersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filter != oldWidget.filter) {
      _currentFilter = widget.filter ?? OrderFilter();
      _fetchInitialData();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _createShipment() async {
    final selectedOrders = ref.read(selectedOrdersProvider);
    
    if (selectedOrders.isEmpty) {
      GlobalToast.show(message: 'يرجى تحديد طلبات للشحن');
      return;
    }

    setState(() {
      _isCreatingShipment = true;
    });

    try {
      // استخدام البيانات بنفس الشكل المطلوب في API
      final shipmentData = {
        "delivered": false,
        "orders": selectedOrders
            .map((orderId) => {"orderId": orderId})
            .toList(),
        "priority": 0
      };

      final result = await _shipmentsService.createPickupShipment(shipmentData);
      
      if (result.$1 != null) {
        GlobalToast.showSuccess(message: 'تم إنشاء الشحنة بنجاح');
        
        // Clear selection and exit multi-select mode
        ref.read(selectedOrdersProvider.notifier).state = <String>{};
        ref.read(isMultiSelectModeProvider.notifier).state = false;
        
        // Refresh data
        _fetchInitialData();
      } else {
        GlobalToast.show(
          message: result.$2 ?? 'فشل في إنشاء الشحنة',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      GlobalToast.show(
        message: 'حدث خطأ: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() {
        _isCreatingShipment = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMultiSelectMode = ref.watch(isMultiSelectModeProvider);
    final selectedOrders = ref.watch(selectedOrdersProvider);

    return PopScope(
      canPop: !isMultiSelectMode,
      onPopInvoked: (didPop) {
        if (!didPop && isMultiSelectMode) {
          // Clear selection and exit multi-select mode
          ref.read(selectedOrdersProvider.notifier).state = <String>{};
          ref.read(isMultiSelectModeProvider.notifier).state = false;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(AppSpaces.large),
              
              // Search and Filter Row
              _buildSearchAndFilterRow(isMultiSelectMode),
              
              const Gap(AppSpaces.small),
              
              // Multi-select header or Tab bar
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isMultiSelectMode
                    ? _buildMultiSelectHeader(selectedOrders)
                    : _buildTabBar(),
              ),
              
              const Gap(AppSpaces.small),
              
              // Tab content
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
                _buildCreateShipmentButton(selectedOrders),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterRow(bool isMultiSelectMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: CustomTextFormField(
              label: '',
              showLabel: false,
              hint: _currentIndex == 0 ? 'رقم الطلب' : 'رقم الوصل',
              prefixInner: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(
                  'assets/svg/search.svg',
                  color: Theme.of(context).colorScheme.primary,
                  width: 24,
                  height: 24,
                ),
              ),
            ),
          ),
          
          const Gap(AppSpaces.small),
          
          // Multi-select button (only show for orders tab)
          if (_currentIndex == 0)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: GestureDetector(
                onTap: () {
                  ref.read(isMultiSelectModeProvider.notifier).state = !isMultiSelectMode;
                  if (!isMultiSelectMode) {
                    ref.read(selectedOrdersProvider.notifier).state = <String>{};
                  }
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
                      width: isMultiSelectMode ? 2 : 1,
                    ),
                  ),
                  child: Icon(
                    isMultiSelectMode ? Icons.close : Icons.checklist,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
              ),
            ),
            
          const Gap(AppSpaces.small),
          
          // Filter button
          GestureDetector(
            onTap: _showFilterBottomSheet,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.filter?.status != null
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SvgPicture.asset(
                      'assets/svg/Funnel.svg',
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                if (widget.filter?.status != null)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiSelectHeader(Set<String> selectedOrders) {
    return Container(
      key: const ValueKey('multiselect'),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.checklist,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const Gap(AppSpaces.small),
          Expanded(
            child: Text(
              'تم تحديد ${selectedOrders.length} طلب',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // Get all orders and select them
              final ordersState = ref.read(ordersNotifierProvider);
              ordersState.whenData((orders) {
                final allOrderIds = orders.map((order) => order.id!).toSet();
                ref.read(selectedOrdersProvider.notifier).state = allOrderIds;
              });
            },
            child: Text(
              'تحديد الكل',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(selectedOrdersProvider.notifier).state = <String>{};
            },
            child: Text(
              'إلغاء الكل',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      key: const ValueKey('tabbar'),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(2, (i) {
          final bool isSelected = _currentIndex == i;
          final String label = i == 0 ? "الطلبات" : "الشحنات";

          return Expanded(
            child: GestureDetector(
              onTap: () {
                _tabController.animateTo(i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: EdgeInsets.only(
                  right: i == 0 ? 0 : 4,
                  left: i == 1 ? 0 : 4,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 4,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Gap(AppSpaces.small),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.secondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 16,
                      ),
                      child: Text(label),
                    ),
                    const Gap(AppSpaces.small),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCreateShipmentButton(Set<String> selectedOrders) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: FillButton(
        label: _isCreatingShipment 
            ? 'جاري إنشاء الشحنة...' 
            : 'إنشاء شحنة (${selectedOrders.length})',
        onPressed:  _createShipment,
        isLoading: _isCreatingShipment,
        icon: _isCreatingShipment
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.local_shipping, color: Colors.white),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (_) => const OrdersFilterBottomSheet(),
    );
  }
}