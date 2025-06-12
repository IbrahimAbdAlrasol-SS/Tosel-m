import 'dart:ui';
import 'package:Tosell/Features/orders/screens/orders_list_tab.dart';
import 'package:Tosell/Features/orders/screens/shipment_list_tab.dart';
import 'package:Tosell/core/Client/ApiResponse.dart';
import 'package:Tosell/paging/generic_paged_list_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

class OrdersScreen extends ConsumerStatefulWidget {
  final OrderFilter? filter;
  final int? initialTab;
  const OrdersScreen({super.key, this.filter, this.initialTab});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with TickerProviderStateMixin {
  late OrderFilter? _currentFilter;
  late TabController _tabController;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  
  bool _isFocused = false;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(
      initialIndex: widget.initialTab ?? 0,
      length: 2, 
      vsync: this,
    );
    
    _currentTabIndex = _tabController.index;
    
    _tabController.addListener(() {
      if (_tabController.indexIsChanging == false) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
        // Optional: Print or log the current tab
        debugPrint('Current tab: $_currentTabIndex');
      }
    });
    
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
    
    _currentFilter = widget.filter;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(ordersNotifierProvider);

    return Scaffold(
      backgroundColor: context.colorScheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: context.colorScheme.background,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  controller: _controller,
                  focusNode: _focusNode,
                  radius: 15,
                  label: '',
                  hint: _currentTabIndex == 0 ? 'رقم الطلب' : 'رقم الشحنة',
                  showLabel: false,
                  //fillColor: Colors.white,
                  //showBorder: true,
                  prefixInner: Padding(
                    padding: const EdgeInsets.all(13.0),
                    child: SvgPicture.asset(
                      'assets/svg/search.svg',
                      color: context.colorScheme.secondary,
                    ),
                  ),
                ),
              ),
              if (_isFocused)
                GestureDetector(
                  onTap: () {
                    _controller.clear();
                    _focusNode.unfocus();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15, top: 5),
                    child: Text(
                      'إلغاء',
                      style: context.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w500,
                        color: context.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              if (!_isFocused)
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (_) => const OrdersFilterBottomSheet(),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _currentFilter?.status == null
                              ? Theme.of(context).colorScheme.outline
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SvgPicture.asset(
                          'assets/svg/Funnel.svg',
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: context.colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: context.colorScheme.primary,
          dividerColor: Colors.transparent,
          tabAlignment: TabAlignment.center,
          labelStyle: context.textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: context.textTheme.titleMedium,
          tabs: const [
            Tab(text: 'الطلبات'),
            Tab(text: 'الشحنات'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          OrdersListTab(
            fetchPage: (page) async {
              final response =  await ref.read(ordersNotifierProvider.notifier).getAll(
                page: page,
                queryParams: _currentFilter?.toJson(),
              );
              return ApiResponse<Order>(
                data: response.data,
                pagination: response.pagination
              );
            },
            
          ),
          shipmentInfoTab(
            fetchPage: (page) async {
              final response =  await ref.read(shipmentsNotifierProvider.notifier).getAll(
                page: page,
                queryParams: _currentFilter?.toJson(),
                
              );
              return ApiResponse<Shipment>(
                data: response.data,
                pagination: response.pagination
              );
            },            //searchQuery: _controller.text,
          ),
        ],
      ),
    );
  }
}