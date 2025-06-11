import 'package:Tosell/Features/orders/models/OrderFilter.dart';
import 'package:Tosell/Features/orders/models/Shipment.dart';
import 'package:Tosell/Features/orders/models/order_enum.dart';
import 'package:Tosell/Features/orders/providers/shipments_provider.dart';
import 'package:Tosell/Features/orders/widgets/shipment_cart_Item.dart';
import 'package:gap/gap.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Tosell/core/constants/spaces.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Tosell/paging/generic_paged_list_view.dart';

class shipmentInfoTab extends ConsumerStatefulWidget {
  final OrderFilter? filter;
  const shipmentInfoTab({super.key, this.filter});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _shipmentInfoTabState();
}

class _shipmentInfoTabState extends ConsumerState<shipmentInfoTab> {
  late OrderFilter? _currentFilter;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.filter;
  }

  @override
  void didUpdateWidget(covariant shipmentInfoTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filter != oldWidget.filter) {
      _currentFilter = widget.filter ?? OrderFilter();
    }
  }

  @override
  Widget build(BuildContext context) {
    final shipmentsState = ref.watch(shipmentsNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(AppSpaces.small),
            
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.filter == null
                    ? 'جميع الشحنات'
                    : 'شحنات "${orderStatus[widget.filter?.status ?? 0].name}"',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const Gap(AppSpaces.small),
            
            // Shipments list
            shipmentsState.when(
              data: _buildUi,
              loading: () => const Expanded(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Expanded(
                child: Center(child: Text(err.toString())),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Expanded _buildUi(List<Shipment> data) {
    return Expanded(
      child: GenericPagedListView(
        key: ValueKey(widget.filter?.toJson()),
        noItemsFoundIndicatorBuilder: _buildNoItemsFound(),
        fetchPage: (pageKey, _) async {
          return await ref.read(shipmentsNotifierProvider.notifier).getAll(
            page: pageKey,
            queryParams: _currentFilter?.toJson(),
          );
        },
        itemBuilder: (context, shipment, index) => ShipmentCartItem(
          shipment: shipment,
          onTap: () => context.push(
            AppRoutes.shipmentOrders,
            extra: {
              'shipmentId': shipment.id,
              'shipmentCode': shipment.code,
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNoItemsFound() {
    return Column(
      children: [
        Image.asset(
          'assets/svg/NoItemsFound.gif',
          width: 240,
          height: 240,
        ),
        const Gap(AppSpaces.medium),
        Text(
          'لا توجد شحنات',
          style: context.textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xffE96363),
            fontSize: 24,
          ),
        ),
        const Gap(AppSpaces.small),
        Text(
          'قم بتحديد طلبات لإنشاء شحنة جديدة',
          style: context.textTheme.bodySmall!.copyWith(
            fontWeight: FontWeight.w500,
            color: const Color(0xff698596),
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}