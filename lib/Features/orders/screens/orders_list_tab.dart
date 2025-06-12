import 'package:Tosell/Features/orders/models/OrderFilter.dart';
import 'package:Tosell/paging/generic_paged_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Tosell/Features/orders/models/Order.dart';
import 'package:Tosell/Features/orders/models/OrderFilter.dart';
import 'package:Tosell/Features/orders/models/Shipment.dart';
import 'package:Tosell/Features/orders/widgets/order_card_item.dart';
import 'package:Tosell/paging/generic_paged_list_view.dart';
import 'package:Tosell/paging/generic_paged_grid_view.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Tosell/Features/orders/providers/shipments_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:Tosell/core/constants/spaces.dart';

class OrdersListTab extends ConsumerStatefulWidget {
  final FetchPage<Order> fetchPage;
  final OrderFilter? filter;
  const OrdersListTab({super.key, this.filter, required this.fetchPage});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OrdersListTabState();
}

class _OrdersListTabState extends ConsumerState<OrdersListTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  
  bool _isMultiSelectMode = false;
  final Set<String> _selectedOrderIds = {};
  List<Order> _allOrders = [];
  
  void _toggleMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      if (!_isMultiSelectMode) {
        _selectedOrderIds.clear();
      }
    });
  }
  
  void _toggleOrderSelection(String orderId) {
    setState(() {
      if (_selectedOrderIds.contains(orderId)) {
        _selectedOrderIds.remove(orderId);
      } else {
        _selectedOrderIds.add(orderId);
      }
    });
  }
  
  void _selectAll() {
    setState(() {
      _selectedOrderIds.clear();
      for (var order in _allOrders) {
        if (order.id != null && order.status != null) {
          _selectedOrderIds.add(order.id!);
        }
      }
    });
  }
  
  void _clearAll() {
    setState(() {
      _selectedOrderIds.clear();
    });
  }
  
  void _createShipment() async {
    if (_selectedOrderIds.isEmpty) return;
    
    try {
      final result = await ref.read(shipmentsNotifierProvider.notifier).createNewShipment(
        orderIds: _selectedOrderIds.toList(),
      );
      
      if (result.$1 != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إنشاء الشحنة بنجاح مع ${_selectedOrderIds.length} طلب'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Reset state
        setState(() {
          _isMultiSelectMode = false;
          _selectedOrderIds.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.$2 ?? 'فشل في إنشاء الشحنة'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // مهم جداً لـ AutomaticKeepAliveClientMixin

    return Scaffold(
      body: Column(
        children: [
          // Multi-select header
          if (_isMultiSelectMode)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Select all button
                  GestureDetector(
                    onTap: _selectAll,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/svg/CheckSquare.svg',
                            width: 16,
                            height: 16,
                            color: Colors.white,
                          ),
                          const Gap(AppSpaces.exSmall),
                          Text(
                            'تحديد الكل',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(AppSpaces.small),
                  // Clear all button
                  GestureDetector(
                    onTap: _clearAll,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/svg/x.svg',
                            width: 16,
                            height: 16,
                            color: Colors.white,
                          ),
                          const Gap(AppSpaces.exSmall),
                          Text(
                            'إلغاء الكل',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Selected count
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    child: Text(
                      'محدد: ${_selectedOrderIds.length}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Orders list
          Expanded(
            child: GenericPagedListView<Order>(
              itemBuilder: (context, order, index) {
                // Update all orders list for select all functionality
                if (!_allOrders.any((o) => o.id == order.id)) {
                  _allOrders.add(order);
                }
                
                return OrderCardItem(
                  order: order,
                  isMultiSelectMode: _isMultiSelectMode,
                  isSelected: _selectedOrderIds.contains(order.id),
                  onSelectionToggle: () => _toggleOrderSelection(order.id ?? ''),
                  onTap: () {
                    if (!_isMultiSelectMode) {
                      context.push(AppRoutes.orderDetails, extra: order.code);
                    }
                  },
                );
              },
              fetchPage: (page, filter) async {
                final result = await widget.fetchPage(page);
                // Update all orders list when new page is fetched
                if (result.data != null) {
                  for (var order in result.data!) {
                    if (!_allOrders.any((o) => o.id == order.id)) {
                      _allOrders.add(order);
                    }
                  }
                }
                return result;
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isMultiSelectMode && _selectedOrderIds.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: FloatingActionButton.extended(
                onPressed: _createShipment,
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 8,
                icon: SvgPicture.asset(
                  'assets/svg/Truck.svg',
                  width: 20,
                  height: 20,
                  color: Colors.white,
                ),
                label: Text(
                  'إرسال شحنة (${_selectedOrderIds.length})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          // Multi-select toggle button
          FloatingActionButton(
            onPressed: _toggleMultiSelectMode,
            backgroundColor: _isMultiSelectMode 
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            elevation: 8,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _isMultiSelectMode
                  ? const Icon(
                      Icons.close,
                      key: ValueKey('close'),
                    )
                  : SvgPicture.asset(
                      'assets/svg/CheckSquare.svg',
                      key: const ValueKey('select'),
                      width: 24,
                      height: 24,
                      color: Colors.white,
                    ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
