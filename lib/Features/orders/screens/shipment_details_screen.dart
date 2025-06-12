import 'package:Tosell/paging/generic_paged_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Tosell/Features/orders/models/Shipment.dart';
import 'package:Tosell/Features/orders/models/Order.dart';
import 'package:Tosell/Features/orders/widgets/order_card_item.dart';
import 'package:Tosell/core/widgets/CustomAppBar.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:Tosell/Features/orders/providers/orders_provider.dart';

class ShipmentDetailsScreen extends ConsumerStatefulWidget {
  final String shipmentCode;
  
  const ShipmentDetailsScreen({super.key, required this.shipmentCode});

  @override
  ConsumerState<ShipmentDetailsScreen> createState() => _ShipmentDetailsScreenState();
}

class _ShipmentDetailsScreenState extends ConsumerState<ShipmentDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GenericPagedListView<Order>(
          itemBuilder: (context, order, index) => OrderCardItem(
            order: order,
            onTap: () {
              context.push(AppRoutes.orderDetails, extra: order.code);
            },
          ),
          fetchPage: (page, filter) async {
            // جلب الطلبات الخاصة بهذه الشحنة
            return await ref.read(ordersNotifierProvider.notifier).getOrdersByShipment(
              widget.shipmentCode,
              page,
            );
          },
        ),
      ),
    );
  }
}