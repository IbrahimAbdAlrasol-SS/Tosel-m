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

class _shipmentInfoTabState extends ConsumerState<shipmentInfoTab>
    with AutomaticKeepAliveClientMixin {
  late OrderFilter? _currentFilter;

  @override
  bool get wantKeepAlive => true; // Keep state alive to prevent rebuilds

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.filter;
  }

  @override
  void didUpdateWidget(covariant shipmentInfoTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update if filter actually changed
    if (widget.filter != oldWidget.filter) {
      _currentFilter = widget.filter ?? OrderFilter();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
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
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.error,
                        size: 48,
                      ),
                      const Gap(AppSpaces.medium),
                      Text(
                        'حدث خطأ في تحميل الشحنات',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap(AppSpaces.small),
                      Text(
                        err.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
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
        key: ValueKey('shipments_${widget.filter?.toJson()}_stable'),
        noItemsFoundIndicatorBuilder: _buildNoItemsFound(),
        fetchPage: (pageKey, _) async {
          // Only fetch if it's the first page and we need more data
          if (pageKey == 1 && data.isNotEmpty) {
            // Return existing data without making new API call for navigation
            return await ref.read(shipmentsNotifierProvider.notifier).getAll(
              page: pageKey,
              queryParams: _currentFilter?.toJson(),
            );
          }
          
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