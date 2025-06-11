import 'dart:ui';
// في أعلى orders_screen.dart أضف:
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
// Import for shipments
import 'package:Tosell/Features/orders/models/Shipment.dart';
import 'package:Tosell/Features/orders/providers/shipments_provider.dart';
import 'package:Tosell/Features/orders/services/shipments_service.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  final OrderFilter? filter;
  const OrdersScreen({super.key, this.filter});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  late OrderFilter? _currentFilter;
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.filter;
    _fetchInitialOrders();
  }

  void _fetchInitialOrders() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ordersNotifierProvider.notifier).getAll(
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
      _fetchInitialOrders();
    }
  }

  Widget build(BuildContext context) {
    final ordersState = ref.watch(ordersNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: AppSpaces.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(5),
              _buildTabBar(),
              _buildTabBarView(),

              const Gap(5),
              _buildTabBarView(),

              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBarView() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: TabBarView(
        controller: _tabController,
        children: const [
          OrdersListTab(),
          shipmentInfoTab(),
        ],
      ),
    );
  }



  // Flag to track if initial data has been loaded
  bool _initialDataLoaded = false;

    Future<void> _refresh() async {
    await ref.read(ordersNotifierProvider.notifier).getAll(
          page: 1,
          queryParams: widget.filter?.toJson(),
        );
  }


  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: TabBar(
        physics: const NeverScrollableScrollPhysics(),
        controller: _tabController,
        indicator: const BoxDecoration(),
        labelPadding: EdgeInsets.zero,
        dividerColor: Colors.transparent,
        tabs: List.generate(2, (i) {
          final bool isSelected = _currentIndex == i;
          final bool isCompleted = _currentIndex > i;
          final String label = i == 0 ? "الطلبات" : "الشحنتات";

          return Tab(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 8,
                  width: 160,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : isCompleted
                            ? const Color(0xff8CD98C)
                            : const Color(0xffE1E7EA),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const Gap(5),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : isCompleted
                            ? const Color(0xff8CD98C)
                            : Theme.of(context).colorScheme.secondary,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
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
        _fetchInitialData();
      }
    });
  }


}