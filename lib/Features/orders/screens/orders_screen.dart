import 'dart:ui';
import 'package:Tosell/Features/orders/screens/orders_list_tab.dart';
import 'package:Tosell/Features/orders/screens/shipment_list_tab.dart';
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
  const OrdersScreen({super.key, this.filter});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> with TickerProviderStateMixin{
  late OrderFilter? _currentFilter;
  late TabController _tabController;
  int _currentIndex = 0;

  @override
@override

void initState() {
  super.initState();
  _currentFilter = widget.filter ?? OrderFilter();
  
  _tabController.addListener(_handleTabChange);
}

void _handleTabChange() {
  if (_tabController.index != _currentIndex) {
    setState(() {
      _currentIndex = _tabController.index;
    });
  }
}

  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              Row(
                children: [
                  const Gap(10),
                  Expanded(
                    child: CustomTextFormField(
                      label: '',
                      showLabel: false,
                      hint: 'رقم الطلب',
                      prefixInner: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SvgPicture.asset(
                          'assets/svg/search.svg',
                          color: Theme.of(context).colorScheme.primary,
                          width: 3,
                          height: 3,
                        ),
                      ),
                    ),
                  ),
                  const Gap(AppSpaces.medium),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (_) => const OrdersFilterBottomSheet(),
                      );
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: widget.filter?.status == null
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
                        if (widget.filter != null)
                          Positioned(
                            top: 6,
                            right: 10,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(5),
              // ordersState.when(
              //   data: (data) => _buildUi(data),
              //   loading: () => const Center(child: CircularProgressIndicator()),
              //   error: (err, _) => Center(child: Text(err.toString())),
              // ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildBottomSheetSection() {
    return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Gap(20),
                _buildTabBar(),
                _buildTabBarView(),
              ],
            ),
          
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
          final String label = i == 0 ? "الطلبات" : "الشحنات";

          return Tab(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 8,
                  width: 160.w,
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
   Widget _buildTabBarView() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: TabBarView(
        controller: _tabController,
        children: const [
          OrdersListTab(),
          //DeliveryInfoTab(),
        ],
      ),
    );
  }

  // Expanded _buildUi(List<Order> data) {
  //   return Expanded(
  //     child: GenericPagedListView(
  //        key: ValueKey(widget.filter?.toJson()),
  //       noItemsFoundIndicatorBuilder: _buildNoItemsFound(),
  //       fetchPage: (pageKey, _) async {
  //         return await ref.read(ordersNotifierProvider.notifier).getAll(
  //           page: pageKey,
  //           queryParams: _currentFilter?.toJson(),
  //         );
  //       },
  //       itemBuilder: (context, order, index) => OrderCardItem(
  //         order: order,
  //         onTap: () => context.push(AppRoutes.orderDetails, extra: order.code),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildNoItemsFound() {
  //   return Column(
  //     children: [
  //       Image.asset('assets/svg/NoItemsFound.gif', width: 240, height: 240),
  //       Text(
  //         'لا توجد طلبات مضافة',
  //         style: context.textTheme.bodyLarge!.copyWith(
  //           fontWeight: FontWeight.w700,
  //           color: const Color(0xffE96363),
  //           fontSize: 24,
  //         ),
  //       ),
  //       const SizedBox(height: 7),
  //       Text(
  //         'اضغط على زر “جديد” لإضافة طلب جديد و ارساله الى زبونك',
  //         style: context.textTheme.bodySmall!.copyWith(
  //           fontWeight: FontWeight.w500,
  //           color: const Color(0xff698596),
  //           fontSize: 16,
  //         ),
  //       ),
  //       const SizedBox(height: 20),
  //       Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 10.0),
  //         child: FillButton(
  //           label: 'إضافة اول طلب',
  //           onPressed: () => context.push(AppRoutes.addOrder),
  //           icon: SvgPicture.asset('assets/svg/navigation_add.svg',
  //               color: const Color(0xffFAFEFD)),
  //           reverse: true,
  //         ),
  //       )
  //     ],
  //   );
  // }
}


// final selectedOrdersProvider = StateProvider<Set<String>>((ref) => <String>{});
// final isMultiSelectModeProvider = StateProvider<bool>((ref) => false);

// class OrdersScreen extends ConsumerStatefulWidget {
//   final OrderFilter? filter;
//   const OrdersScreen({super.key, this.filter});

//   @override
//   ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
// }

// class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  
//   late PageController _pageController;
//   late OrderFilter _currentFilter;
//   int _currentTabIndex = 0;
//   bool _isCreatingShipment = false;
  
//   final TextEditingController _searchController = TextEditingController();
//   final ShipmentsService _shipmentsService = ShipmentsService();

//   @override
//   void initState() {
//     super.initState();
//     _currentFilter = widget.filter ?? OrderFilter();
    
//     _pageController = PageController(initialPage: 0);
//     _pageController.addListener(_onPageChanged);
//   }

//   void _onPageChanged() {
//     final page = _pageController.page?.round() ?? 0;
//     if (page != _currentTabIndex) {
//       setState(() {
//         _currentTabIndex = page;
//       });
//       _clearMultiSelect();
//     }
//   }
//   void _clearMultiSelect() {
//     ref.read(selectedOrdersProvider.notifier).state = <String>{};
//     ref.read(isMultiSelectModeProvider.notifier).state = false;
//   }
//   void _handleSearch(String searchTerm) {
//     _clearMultiSelect();
//     _searchController.text = searchTerm;
    
//     final filter = OrderFilter(
//       code: searchTerm.isNotEmpty ? searchTerm : null,
//       shipmentCode: searchTerm.isNotEmpty ? searchTerm : null,
//     );
    
//     if (_currentTabIndex == 0) {
//       ref.read(ordersNotifierProvider.notifier).refresh(queryParams: filter.toJson());
//     } else {
//       ref.read(shipmentsNotifierProvider.notifier).refresh(queryParams: filter.toJson());
//     }
//   }

//   Future<void> _createShipment() async {
//     final selectedOrders = ref.read(selectedOrdersProvider);
//     if (selectedOrders.isEmpty) {
//       GlobalToast.show(message: 'يرجى تحديد طلبات للشحن');
//       return;
//     }

//     setState(() => _isCreatingShipment = true);

//     try {
//       final shipmentData = {
//         "orders": selectedOrders.map((id) => {"orderId": id}).toList(),
//       };

//       final result = await _shipmentsService.createShipment(Shipment.fromJson(shipmentData));

//       if (result.$1 != null) {
//         GlobalToast.showSuccess(message: 'تم إنشاء الشحنة بنجاح');
//         _clearMultiSelect();
        
//         // Refresh both tabs
//         ref.read(ordersNotifierProvider.notifier).refresh();
//         ref.read(shipmentsNotifierProvider.notifier).refresh();
//       } else {
//         GlobalToast.show(message: result.$2 ?? 'فشل في إنشاء الشحنة', backgroundColor: Colors.red);
//       }
//     } catch (e) {
//       GlobalToast.show(message: 'حدث خطأ: ${e.toString()}', backgroundColor: Colors.red);
//     } finally {
//       setState(() => _isCreatingShipment = false);
//     }
//   }

//   void _showFilterBottomSheet() {
//     _clearMultiSelect();
//     showModalBottomSheet(
//       isScrollControlled: true,
//       context: context,
//       builder: (_) => const OrdersFilterBottomSheet(),
//     ).then((result) {
//       if (result != null && result is OrderFilter) {
//         setState(() => _currentFilter = result);
//         ref.read(ordersNotifierProvider.notifier).refresh(queryParams: _currentFilter.toJson());
//         ref.read(shipmentsNotifierProvider.notifier).refresh(queryParams: _currentFilter.toJson());
//       }
//     });
//   }

//   void _selectAllOrders() {
//     final ordersState = ref.read(ordersNotifierProvider);
//     ordersState.whenData((orders) {
//       final allOrderIds = orders.where((order) => order.id != null).map((order) => order.id!).toSet();
//       ref.read(selectedOrdersProvider.notifier).state = allOrderIds;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isMultiSelectMode = ref.watch(isMultiSelectModeProvider);
//     final selectedOrders = ref.watch(selectedOrdersProvider);

//     // ✅ Clear multi-select on provider errors
//     ref.listen(ordersNotifierProvider, (previous, next) {
//       next.whenOrNull(error: (error, stackTrace) => _clearMultiSelect());
//     });

//     return PopScope(
//       canPop: !isMultiSelectMode,
//       onPopInvoked: (didPop) {
//         if (!didPop && isMultiSelectMode) _clearMultiSelect();
//       },
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         body: SafeArea(
//           child: Column(
//             children: [
//               const Gap(AppSpaces.large),

//               // Search Row
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: CustomTextFormField(
//                         controller: _searchController,
//                         label: '',
//                         showLabel: false,
//                         hint: _currentTabIndex == 0 ? 'رقم الطلب' : 'رقم الوصل',
//                         prefixInner: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: SvgPicture.asset(
//                             'assets/svg/search.svg',
//                             color: Theme.of(context).colorScheme.primary,
//                             width: 24,
//                             height: 24,
//                           ),
//                         ),
//                         onChanged: _handleSearch,
//                       ),
//                     ),
//                     const Gap(AppSpaces.small),
                    
//                     // Multi-select button (orders tab only)
//                     if (_currentTabIndex == 0)
//                       GestureDetector(
//                         onTap: () {
//                           final current = ref.read(isMultiSelectModeProvider);
//                           ref.read(isMultiSelectModeProvider.notifier).state = !current;
//                           if (current) _clearMultiSelect();
//                         },
//                         child: AnimatedContainer(
//                           duration: const Duration(milliseconds: 200),
//                           width: 50,
//                           height: 50,
//                           decoration: BoxDecoration(
//                             color: isMultiSelectMode
//                                 ? Theme.of(context).colorScheme.primary
//                                 : Colors.white,
//                             shape: BoxShape.circle,
//                             border: Border.all(
//                               color: isMultiSelectMode
//                                   ? Theme.of(context).colorScheme.primary
//                                   : Theme.of(context).colorScheme.outline,
//                             ),
//                             boxShadow: isMultiSelectMode ? [
//                               BoxShadow(
//                                 color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
//                                 blurRadius: 8,
//                                 spreadRadius: 2,
//                               )
//                             ] : null,
//                           ),
//                           child: Icon(
//                             isMultiSelectMode ? Icons.close : Icons.checklist_rounded,
//                             color: isMultiSelectMode 
//                                 ? Colors.white 
//                                 : Theme.of(context).colorScheme.primary,
//                             size: 24,
//                           ),
//                         ),
//                       ),
                    
//                     const Gap(AppSpaces.small),
                    
//                     // Filter button
//                     GestureDetector(
//                       onTap: _showFilterBottomSheet,
//                       child: Container(
//                         width: 50,
//                         height: 50,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           shape: BoxShape.circle,
//                           border: Border.all(color: Theme.of(context).colorScheme.outline),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(12.0),
//                           child: SvgPicture.asset(
//                             'assets/svg/Funnel.svg',
//                             color: Theme.of(context).colorScheme.primary,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const Gap(AppSpaces.exSmall),

//               // Tab Bar or Multi-select Header
//               AnimatedSwitcher(
//                 duration: const Duration(milliseconds: 300),
//                 child: isMultiSelectMode
//                     ? Container(
//                         key: const ValueKey('multiselect'),
//                         margin: const EdgeInsets.symmetric(horizontal: 16),
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [
//                               Theme.of(context).colorScheme.primary.withOpacity(0.1),
//                               Theme.of(context).colorScheme.primary.withOpacity(0.05),
//                             ],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                           borderRadius: BorderRadius.circular(16),
//                           border: Border.all(
//                             color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(8),
//                               decoration: BoxDecoration(
//                                 color: Theme.of(context).colorScheme.primary,
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: const Icon(
//                                 Icons.checklist_rounded,
//                                 color: Colors.white,
//                                 size: 20,
//                               ),
//                             ),
//                             const Gap(AppSpaces.medium),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
                                  
//                                   Text(
//                                     'تم تحديد ${selectedOrders.length} طلب',
//                                     style: TextStyle(
//                                       color: Theme.of(context).colorScheme.secondary,
//                                       fontSize: 10,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             // تحديد الكل - حجم صغير
//                             Container(
//                               height: 32,
//                               padding: const EdgeInsets.symmetric(horizontal: 8),
//                               decoration: BoxDecoration(
//                                 color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(16),
//                                 border: Border.all(
//                                   color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
//                                 ),
//                               ),
//                               child: InkWell(
//                                 onTap: _selectAllOrders,
//                                 borderRadius: BorderRadius.circular(16),
//                                 child: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Icon(
//                                       Icons.select_all,
//                                       size: 16,
//                                       color: Theme.of(context).colorScheme.primary,
//                                     ),
//                                     const SizedBox(width: 4),
//                                     Text(
//                                       'تحديد الكل',
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: Theme.of(context).colorScheme.primary,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             // إلغاء الكل - حجم صغير
//                             Container(
//                               height: 32,
//                               padding: const EdgeInsets.symmetric(horizontal: 8),
//                               decoration: BoxDecoration(
//                                 color: Theme.of(context).colorScheme.error.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(16),
//                                 border: Border.all(
//                                   color: Theme.of(context).colorScheme.error.withOpacity(0.3),
//                                 ),
//                               ),
//                               child: InkWell(
//                                 onTap: () => ref.read(selectedOrdersProvider.notifier).state = <String>{},
//                                 borderRadius: BorderRadius.circular(16),
//                                 child: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Icon(
//                                       Icons.clear_all,
//                                       size: 16,
//                                       color: Theme.of(context).colorScheme.error,
//                                     ),
//                                     const SizedBox(width: 4),
//                                     Text(
//                                       'إلغاء الكل',
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: Theme.of(context).colorScheme.error,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             // زر الإغلاق - حجم صغير
//                             Container(
//                               width: 32,
//                               height: 32,
//                               decoration: BoxDecoration(
//                                 color: Theme.of(context).colorScheme.error.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(16),
//                                 border: Border.all(
//                                   color: Theme.of(context).colorScheme.error.withOpacity(0.3),
//                                 ),
//                               ),
//                               child: InkWell(
//                                 onTap: _clearMultiSelect,
//                                 borderRadius: BorderRadius.circular(16),
//                                 child: Icon(
//                                   Icons.close_rounded,
//                                   size: 18,
//                                   color: Theme.of(context).colorScheme.error,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       )
//                     : Container(
//                         key: const ValueKey('tabbar'),
//                         margin: const EdgeInsets.symmetric(horizontal: 16),
//                         child: Row(
//                           children: [
//                             Expanded(child: _buildTab(0, "الطلبات")),
//                             Expanded(child: _buildTab(1, "الشحنات")),
//                           ],
//                         ),
//                       ),
//               ),

//               const Gap(AppSpaces.medium),

//               // Tab Content مع PageView للتزامن
//               Expanded(
//                 child: PageView(
//                   controller: _pageController,
//                   children: [
//                     OrdersListTab(filter: _currentFilter),
//                     shipmentInfoTab(filter: _currentFilter),
//                   ],
//                 ),
//               ),

//               // Create shipment button
//               if (isMultiSelectMode && selectedOrders.isNotEmpty)
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: const BorderRadius.only(
//                       topLeft: Radius.circular(20),
//                       topRight: Radius.circular(20),
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.1),
//                         blurRadius: 10,
//                         spreadRadius: 2,
//                         offset: const Offset(0, -2),
//                       ),
//                     ],
//                   ),
//                   child: SafeArea(
//                     top: false,
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: OutlinedButton(
//                             onPressed: _clearMultiSelect,
//                             style: OutlinedButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(vertical: 16),
//                               side: BorderSide(
//                                 color: Theme.of(context).colorScheme.outline,
//                               ),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             child: const Text('إلغاء'),
//                           ),
//                         ),
//                         const Gap(AppSpaces.medium),
//                         Expanded(
//                           flex: 2,
//                           child: Container(
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(12),
//                               gradient: LinearGradient(
//                                 colors: [
//                                   Theme.of(context).colorScheme.primary,
//                                   Theme.of(context).colorScheme.primary.withOpacity(0.8),
//                                 ],
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                               ),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
//                                   blurRadius: 8,
//                                   spreadRadius: 2,
//                                   offset: const Offset(0, 4),
//                                 ),
//                               ],
//                             ),
//                             child: Material(
//                               color: Colors.transparent,
//                               child: InkWell(
//                                 onTap: _isCreatingShipment ? null : _createShipment,
//                                 borderRadius: BorderRadius.circular(12),
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(vertical: 16),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       if (_isCreatingShipment)
//                                         const SizedBox(
//                                           width: 20,
//                                           height: 20,
//                                           child: CircularProgressIndicator(
//                                             strokeWidth: 2,
//                                             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                                           ),
//                                         )
//                                       else
//                                         const Icon(
//                                           Icons.local_shipping_rounded,
//                                           color: Colors.white,
//                                           size: 20,
//                                         ),
//                                       const Gap(AppSpaces.small),
//                                       Text(
//                                         _isCreatingShipment
//                                             ? 'جاري إنشاء الشحنة...'
//                                             : 'إنشاء شحنة (${selectedOrders.length})',
//                                         style: const TextStyle(
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 16,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTab(int index, String label) {
//     final isSelected = _currentTabIndex == index;
    
//     return GestureDetector(
//       onTap: () {
//         _pageController.animateToPage(
//           index,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeInOut,
//         );
//       },
//       child: Column(
//         children: [
//           AnimatedContainer(
//             duration: const Duration(milliseconds: 200),
//             height: 4,
//             decoration: BoxDecoration(
//               color: isSelected
//                   ? Theme.of(context).colorScheme.primary
//                   : Theme.of(context).colorScheme.outline,
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//           const Gap(AppSpaces.small),
//           AnimatedDefaultTextStyle(
//             duration: const Duration(milliseconds: 200),
//             style: TextStyle(
//               color: isSelected
//                   ? Theme.of(context).colorScheme.primary
//                   : Theme.of(context).colorScheme.secondary,
//               fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//               fontSize: 16,
//             ),
//             child: Text(label),
//           ),
//           const Gap(AppSpaces.small),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _pageController.removeListener(_onPageChanged);
//     _pageController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }
// }