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

// ✅ Global providers for multi-select functionality
final selectedOrdersProvider = StateProvider<Set<String>>((ref) => <String>{});
final isMultiSelectModeProvider = StateProvider<bool>((ref) => false);

// ✅ Provider to track if initial data has been loaded for both tabs
final dataLoadedProvider = StateProvider<bool>((ref) => false);

// ✅ Provider to track current search terms for both tabs
final ordersSearchProvider = StateProvider<String>((ref) => '');
final shipmentsSearchProvider = StateProvider<String>((ref) => '');

class OrdersScreen extends ConsumerStatefulWidget {
  final OrderFilter? filter;
  const OrdersScreen({super.key, this.filter});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with SingleTickerProviderStateMixin {
  // ✅ UI State Variables
  late TabController _tabController;
  late OrderFilter _currentFilter;
  int _currentTabIndex = 0;
  
  // ✅ Service instances
  final ShipmentsService _shipmentsService = ShipmentsService();
  
  // ✅ UI State flags
  bool _isCreatingShipment = false;
  
  // ✅ Search controllers for both tabs
  final TextEditingController _ordersSearchController = TextEditingController();
  final TextEditingController _shipmentsSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  /// ✅ Initialize all state variables and controllers
  void _initializeState() {
    _currentFilter = widget.filter ?? OrderFilter();
    
    // Initialize TabController
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: 0,
    );
    
    // Add tab listener
    _tabController.addListener(_onTabChanged);
    
    // Load data for both tabs simultaneously on screen entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialDataParallel();
    });
  }

  /// ✅ Handle tab changes without reloading data
  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentTabIndex = _tabController.index;
      });

      // Clear multi-select mode when switching tabs
      if (ref.read(isMultiSelectModeProvider)) {
        ref.read(selectedOrdersProvider.notifier).state = <String>{};
        ref.read(isMultiSelectModeProvider.notifier).state = false;
      }
    }
  }

  /// ✅ Load data for both tabs simultaneously - only once per session
  Future<void> _loadInitialDataParallel() async {
    final dataLoaded = ref.read(dataLoadedProvider);
    
    if (!dataLoaded) {
      try {
        // ✅ Load both orders and shipments in parallel
        await Future.wait([
          _loadOrdersData(),
          _loadShipmentsData(),
        ]);
        
        // Mark data as loaded to prevent reload on tab switches
        ref.read(dataLoadedProvider.notifier).state = true;
      } catch (e) {
        GlobalToast.show(
          message: 'خطأ في تحميل البيانات: ${e.toString()}',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  /// ✅ Load orders data via provider
  Future<void> _loadOrdersData() async {
    await ref.read(ordersNotifierProvider.notifier).getAll(
      page: 1,
      queryParams: _currentFilter.toJson(),
    );
  }

  /// ✅ Load shipments data via provider
  Future<void> _loadShipmentsData() async {
    await ref.read(shipmentsNotifierProvider.notifier).getAll(
      page: 1,
      queryParams: _currentFilter.toJson(),
    );
  }

  /// ✅ Handle search for active tab
  void _handleSearch(String searchTerm) {
    if (_currentTabIndex == 0) {
      // Orders search
      ref.read(ordersSearchProvider.notifier).state = searchTerm;
      _performOrdersSearch(searchTerm);
    } else {
      // Shipments search
      ref.read(shipmentsSearchProvider.notifier).state = searchTerm;
      _performShipmentsSearch(searchTerm);
    }
  }

  /// ✅ Perform orders search
  void _performOrdersSearch(String searchTerm) {
    final searchFilter = OrderFilter(
      code: searchTerm.isNotEmpty ? searchTerm : null,
    );
    
    ref.read(ordersNotifierProvider.notifier).refresh(
      queryParams: searchFilter.toJson(),
    );
  }

  /// ✅ Perform shipments search
  void _performShipmentsSearch(String searchTerm) {
    final searchFilter = OrderFilter(
      shipmentCode: searchTerm.isNotEmpty ? searchTerm : null,
    );
    
    ref.read(shipmentsNotifierProvider.notifier).getAll(
      page: 1,
      queryParams: searchFilter.toJson(),
    );
  }

  @override
  void didUpdateWidget(covariant OrdersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // ✅ Only reload if filter actually changed
    if (widget.filter != oldWidget.filter) {
      _currentFilter = widget.filter ?? OrderFilter();
      
      // Reset data loaded flag and reload both tabs
      ref.read(dataLoadedProvider.notifier).state = false;
      _loadInitialDataParallel();
      
      // Clear search controllers
      _ordersSearchController.clear();
      _shipmentsSearchController.clear();
      ref.read(ordersSearchProvider.notifier).state = '';
      ref.read(shipmentsSearchProvider.notifier).state = '';
    }
  }

  /// ✅ Create shipment from selected orders
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
      final shipmentData = {
        "delivered": false,
        "orders": selectedOrders.map((orderId) => {"orderId": orderId}).toList(),
        "priority": 0
      };

      // ✅ Create shipment via service
      final result = await _shipmentsService.createPickupShipment(shipmentData);

      if (result.$1 != null) {
        GlobalToast.showSuccess(message: 'تم إنشاء الشحنة بنجاح');

        // Clear selection and exit multi-select mode
        ref.read(selectedOrdersProvider.notifier).state = <String>{};
        ref.read(isMultiSelectModeProvider.notifier).state = false;

        // ✅ Refresh both tabs after successful shipment creation
        await _refreshBothTabs();
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

  /// ✅ Refresh both tabs data
  Future<void> _refreshBothTabs() async {
    await Future.wait([
      ref.read(ordersNotifierProvider.notifier).refresh(
        queryParams: _currentFilter.toJson(),
      ),
      ref.read(shipmentsNotifierProvider.notifier).getAll(
        page: 1,
        queryParams: _currentFilter.toJson(),
      ),
    ]);
  }

  /// ✅ Show filter bottom sheet
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (_) => const OrdersFilterBottomSheet(),
    ).then((result) {
      if (result != null && result is OrderFilter) {
        setState(() {
          _currentFilter = result;
        });
        
        // Reset data loaded flag and reload
        ref.read(dataLoadedProvider.notifier).state = false;
        _loadInitialDataParallel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMultiSelectMode = ref.watch(isMultiSelectModeProvider);
    final selectedOrders = ref.watch(selectedOrdersProvider);

    return PopScope(
      canPop: !isMultiSelectMode,
      onPopInvoked: (didPop) {
        if (!didPop && isMultiSelectMode) {
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

              // ✅ Search and Filter Row
              _buildSearchAndFilterRow(isMultiSelectMode),

              const Gap(AppSpaces.medium),

              // ✅ Tab Bar (below search as requested)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isMultiSelectMode
                    ? _buildMultiSelectHeader(selectedOrders)
                    : _buildTabBar(),
              ),

              const Gap(AppSpaces.medium),

              // ✅ Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // ✅ Orders tab with filter
                    OrdersListTab(filter: _currentFilter),
                    
                    // ✅ Shipments tab with filter
                    shipmentInfoTab(filter: _currentFilter),
                  ],
                ),
              ),

              // ✅ Create shipment button (only in multi-select mode)
              if (isMultiSelectMode && selectedOrders.isNotEmpty)
                _buildCreateShipmentButton(selectedOrders),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ Build search and filter row
  Widget _buildSearchAndFilterRow(bool isMultiSelectMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // ✅ Search field with dynamic hint and controller
          Expanded(
            child: CustomTextFormField(
              controller: _currentTabIndex == 0 
                  ? _ordersSearchController 
                  : _shipmentsSearchController,
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

          // ✅ Multi-select button (only for orders tab)
          if (_currentTabIndex == 0)
            _buildMultiSelectToggleButton(isMultiSelectMode),

          const Gap(AppSpaces.small),

          // ✅ Filter button
          _buildFilterButton(),
        ],
      ),
    );
  }

  /// ✅ Build multi-select toggle button
  Widget _buildMultiSelectToggleButton(bool isMultiSelectMode) {
    return AnimatedContainer(
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
    );
  }

  /// ✅ Build filter button
  Widget _buildFilterButton() {
    final hasActiveFilter = _currentFilter.status != null ||
        _currentFilter.zoneId != null ||
        _currentFilter.shipmentId != null;

    return GestureDetector(
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
                color: hasActiveFilter
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
          if (hasActiveFilter)
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
    );
  }

  /// ✅ Build multi-select header
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
            onPressed: _selectAllOrders,
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

  /// ✅ Select all orders from current state
  void _selectAllOrders() {
    final ordersState = ref.read(ordersNotifierProvider);
    ordersState.whenData((orders) {
      final allOrderIds = orders
          .where((order) => order.id != null)
          .map((order) => order.id!)
          .toSet();
      ref.read(selectedOrdersProvider.notifier).state = allOrderIds;
    });
  }

  /// ✅ Build tab bar
  Widget _buildTabBar() {
    return Container(
      key: const ValueKey('tabbar'),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(2, (index) {
          final bool isSelected = _currentTabIndex == index;
          final String label = index == 0 ? "الطلبات" : "الشحنات";

          return Expanded(
            child: GestureDetector(
              onTap: () => _tabController.animateTo(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: EdgeInsets.only(
                  right: index == 0 ? 0 : 4,
                  left: index == 1 ? 0 : 4,
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

  /// ✅ Build create shipment button
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
        onPressed: _createShipment,
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

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _ordersSearchController.dispose();
    _shipmentsSearchController.dispose();
    
    // Clear state when leaving screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(selectedOrdersProvider.notifier).state = <String>{};
        ref.read(isMultiSelectModeProvider.notifier).state = false;
        ref.read(dataLoadedProvider.notifier).state = false;
        ref.read(ordersSearchProvider.notifier).state = '';
        ref.read(shipmentsSearchProvider.notifier).state = '';
      }
    });
    super.dispose();
  }
}